import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// QR scanner for Cursor API key transfer (`cursormc://auth?key=...`).
class QrScannerWidget extends StatelessWidget {
  const QrScannerWidget({
    required this.onDetect,
    required this.controller,
    super.key,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;

  /// Parses API key from QR payload URL or raw key string.
  static String? parseApiKeyFromPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('cursormc://') || trimmed.startsWith('cursor://')) {
      final uri = Uri.tryParse(trimmed);
      var key = uri?.queryParameters['key'];
      if (key != null && key.isNotEmpty) {
        return Uri.decodeComponent(key);
      }
      final match = RegExp(r'[?&]key=([^&\s]+)').firstMatch(trimmed);
      if (match != null) {
        key = Uri.decodeComponent(match.group(1)!);
        if (key.isNotEmpty) {
          return key;
        }
      }
    }
    if ((trimmed.startsWith('cursor_') || trimmed.startsWith('crsr_')) &&
        trimmed.length > 20) {
      return trimmed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(
            controller: controller,
            onDetect: onDetect,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Text(
            'Scan the QR code from your desktop helper or Cursor dashboard.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
