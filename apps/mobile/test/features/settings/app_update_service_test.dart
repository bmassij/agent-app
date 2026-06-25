import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/settings/domain/app_update_info.dart';

void main() {
  test('AppUpdateInfo.fromJson parses manifest fields', () {
    final info = AppUpdateInfo.fromJson({
      'versionName': '0.1.0',
      'versionCode': 3,
      'apkUrl': 'http://192.168.0.5:8765/app-debug.apk',
      'releaseNotes': 'Test notes',
    });

    expect(info.versionName, '0.1.0');
    expect(info.versionCode, 3);
    expect(info.apkUrl, contains('app-debug.apk'));
    expect(info.releaseNotes, 'Test notes');
  });
}
