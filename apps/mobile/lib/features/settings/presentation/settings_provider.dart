import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/settings/data/app_update_service.dart';
import 'package:cursor_mobile_commander/features/settings/domain/app_update_info.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final updateServerUrlProvider =
    AsyncNotifierProvider<UpdateServerUrlNotifier, String?>(
  UpdateServerUrlNotifier.new,
);

class UpdateServerUrlNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.watch(secureStorageServiceProvider);
    return storage.readKey(SecureStorageKeys.updateServerUrl);
  }

  Future<void> save(String url) async {
    final storage = ref.read(secureStorageServiceProvider);
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      await storage.deleteKey(SecureStorageKeys.updateServerUrl);
      state = const AsyncData(null);
      return;
    }
    await storage.writeKey(SecureStorageKeys.updateServerUrl, trimmed);
    state = AsyncData(trimmed);
  }
}

final appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateUiState>(
  AppUpdateController.new,
);

class AppUpdateUiState {
  const AppUpdateUiState({
    this.isBusy = false,
    this.progress,
    this.availableUpdate,
    this.infoMessage,
    this.errorMessage,
  });

  final bool isBusy;
  final AppUpdateProgress? progress;
  final AppUpdateInfo? availableUpdate;
  final String? infoMessage;
  final String? errorMessage;

  AppUpdateUiState copyWith({
    bool? isBusy,
    AppUpdateProgress? progress,
    AppUpdateInfo? availableUpdate,
    String? infoMessage,
    String? errorMessage,
    bool clearUpdate = false,
    bool clearMessages = false,
  }) {
    return AppUpdateUiState(
      isBusy: isBusy ?? this.isBusy,
      progress: progress ?? this.progress,
      availableUpdate:
          clearUpdate ? null : (availableUpdate ?? this.availableUpdate),
      infoMessage: clearMessages ? null : (infoMessage ?? this.infoMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AppUpdateController extends Notifier<AppUpdateUiState> {
  @override
  AppUpdateUiState build() => const AppUpdateUiState();

  Future<void> checkForUpdate() async {
    final serverUrl = await ref.read(updateServerUrlProvider.future);
    if (serverUrl == null || serverUrl.trim().isEmpty) {
      state = state.copyWith(
        clearMessages: true,
        errorMessage: 'Set your PC update server URL first (same Wi‑Fi).',
      );
      return;
    }

    state = state.copyWith(
      isBusy: true,
      clearMessages: true,
      clearUpdate: true,
      progress: const AppUpdateProgress(
        kind: AppUpdateProgressKind.checking,
        message: 'Checking for updates…',
      ),
    );

    try {
      final service = ref.read(appUpdateServiceProvider);
      final update = await service.checkForUpdate(serverUrl);
      if (update == null) {
        state = state.copyWith(
          isBusy: false,
          progress: null,
          infoMessage: 'You already have the latest version.',
        );
        return;
      }

      state = state.copyWith(
        isBusy: false,
        progress: null,
        availableUpdate: update,
        infoMessage:
            'Update ${update.versionName} (build ${update.versionCode}) available.',
      );
    } on AppUpdateException catch (e) {
      state = state.copyWith(
        isBusy: false,
        progress: null,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        progress: null,
        errorMessage: 'Could not reach update server: $e',
      );
    }
  }

  Future<void> installAvailableUpdate() async {
    final update = state.availableUpdate;
    if (update == null) {
      return;
    }

    state = state.copyWith(
      isBusy: true,
      clearMessages: true,
      errorMessage: null,
    );

    try {
      final service = ref.read(appUpdateServiceProvider);
      await for (final progress in service.downloadAndInstall(update.apkUrl)) {
        if (progress.kind == AppUpdateProgressKind.error) {
          state = state.copyWith(
            isBusy: false,
            progress: null,
            errorMessage: progress.message,
          );
          return;
        }
        state = state.copyWith(progress: progress);
      }
      state = state.copyWith(
        isBusy: false,
        progress: null,
        infoMessage: 'Follow the Android installer to finish.',
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        progress: null,
        errorMessage: 'Update failed: $e',
      );
    }
  }
}
