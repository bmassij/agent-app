/// Remote update manifest from the PC update server (`update.json`).
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    this.releaseNotes,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      versionName: json['versionName'] as String? ?? '0.0.0',
      versionCode: (json['versionCode'] as num?)?.toInt() ?? 0,
      apkUrl: json['apkUrl'] as String? ?? '',
      releaseNotes: json['releaseNotes'] as String?,
    );
  }

  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String? releaseNotes;
}

enum AppUpdateProgressKind {
  checking,
  downloading,
  installing,
  done,
  error,
}

class AppUpdateProgress {
  const AppUpdateProgress({
    required this.kind,
    this.value,
    this.message,
  });

  final AppUpdateProgressKind kind;
  final double? value;
  final String? message;
}
