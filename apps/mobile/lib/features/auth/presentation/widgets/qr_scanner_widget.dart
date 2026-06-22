import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// QR scanner for Cursor API key transfer (`cursormc://auth?key=...`).
class QrScannerWidget extends StatelessWidget {
  const QrScannerWidget({
    required this.onDetect,
    super.key,
  });

  final void Function(BarcodeCapture capture) onDetect;

  /// Parses API key from QR payload URL or raw key string.
  static String? parseApiKeyFromPayload(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('cursormc://') || trimmed.startsWith('cursor://')) {
      final uri = Uri.tryParse(trimmed);
      final key = uri?.queryParameters['key'];
      if (key != null && key.isNotEmpty) {
        return key;
      }
    }
    if (trimmed.startsWith('cursor_') && trimmed.length > 20) {
      return trimmed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MobileScanner(onDetect: onDetect),
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
