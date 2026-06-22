import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/auth/presentation/widgets/qr_scanner_widget.dart';

void main() {
  group('QrScannerWidget.parseApiKeyFromPayload', () {
    test('parses cursormc://auth?key= URL', () {
      const key = 'cursor_test_key_abcdefghijklmnopqrst';
      final parsed = QrScannerWidget.parseApiKeyFromPayload(
        'cursormc://auth?key=$key',
      );
      expect(parsed, key);
    });

    test('parses cursor://auth?key= URL', () {
      const key = 'cursor_raw_key_abcdefghijklmnopqrst';
      final parsed = QrScannerWidget.parseApiKeyFromPayload(
        'cursor://auth?key=$key',
      );
      expect(parsed, key);
    });

    test('accepts raw cursor_ key string', () {
      const key = 'cursor_direct_key_abcdefghijklmnopqrst';
      final parsed = QrScannerWidget.parseApiKeyFromPayload(key);
      expect(parsed, key);
    });

    test('returns null for invalid payload', () {
      expect(QrScannerWidget.parseApiKeyFromPayload('not-a-key'), isNull);
      expect(QrScannerWidget.parseApiKeyFromPayload('cursor_short'), isNull);
    });
  });
}
