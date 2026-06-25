import 'package:dio/dio.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:cursor_mobile_commander/features/settings/domain/app_update_info.dart';

/// Checks a LAN/HTTP update server and installs newer APK builds.
class AppUpdateService {
  AppUpdateService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<PackageInfo> currentPackageInfo() => PackageInfo.fromPlatform();

  Future<AppUpdateInfo?> checkForUpdate(String serverBaseUrl) async {
    final base = _normalizeBaseUrl(serverBaseUrl);
    if (base == null) {
      throw const AppUpdateException('Enter a valid update server URL');
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '$base/update.json',
      options: Options(
        responseType: ResponseType.json,
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
      ),
    );

    final data = response.data;
    if (data == null) {
      throw const AppUpdateException('Update server returned empty manifest');
    }

    final remote = AppUpdateInfo.fromJson(data);
    if (remote.apkUrl.isEmpty) {
      throw const AppUpdateException('Manifest is missing apkUrl');
    }

    final local = await currentPackageInfo();
    final localBuild = int.tryParse(local.buildNumber) ?? 0;
    if (remote.versionCode <= localBuild) {
      return null;
    }

    return remote;
  }

  Stream<AppUpdateProgress> downloadAndInstall(String apkUrl) async* {
    yield const AppUpdateProgress(
      kind: AppUpdateProgressKind.downloading,
      value: 0,
      message: 'Downloading update…',
    );

    final stream = OtaUpdate().execute(
      apkUrl,
      destinationFilename: 'cursor_mobile_commander_update.apk',
    );

    await for (final event in stream) {
      switch (event.status) {
        case OtaStatus.DOWNLOADING:
          final progress = double.tryParse(event.value ?? '') ?? 0;
          yield AppUpdateProgress(
            kind: AppUpdateProgressKind.downloading,
            value: progress,
            message: 'Downloading… ${progress.toStringAsFixed(0)}%',
          );
        case OtaStatus.INSTALLING:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.installing,
            message: 'Opening installer…',
          );
        case OtaStatus.INSTALLATION_DONE:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.done,
            message: 'Install complete',
          );
        case OtaStatus.INSTALLATION_ERROR:
          yield AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: event.value ?? 'Installation failed',
          );
        case OtaStatus.ALREADY_RUNNING_ERROR:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: 'Installer already running. Close it and try again.',
          );
        case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message:
                'Allow installing apps from this source in Android settings.',
          );
        case OtaStatus.INTERNAL_ERROR:
          yield AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: event.value ?? 'Install failed',
          );
        case OtaStatus.DOWNLOAD_ERROR:
          yield AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: event.value ?? 'Download failed',
          );
        case OtaStatus.CHECKSUM_ERROR:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: 'Download checksum mismatch',
          );
        case OtaStatus.CANCELED:
          yield const AppUpdateProgress(
            kind: AppUpdateProgressKind.error,
            message: 'Update canceled',
          );
      }
    }
  }

  String? _normalizeBaseUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final withScheme = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) {
      return null;
    }
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}
