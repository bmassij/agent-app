import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Routes to workspace connection setup (QR scan or manual paste).
class ConnectCursorScreen extends StatelessWidget {
  const ConnectCursorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect workspace')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan the QR code from your computer — fastest way to connect.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Your connection is stored securely on this device and used to '
              'run tasks on your behalf via your digital workers.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            FilledButton.icon(
              onPressed: () => context.push(Routes.keySetupScan),
              icon: const Icon(Icons.qr_code_scanner, size: 28),
              label: const Text('Scan QR code'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              'On your computer, generate a QR code with:\n'
              'dart run tools/generate_key_qr.dart --key=YOUR_KEY',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => context.push(Routes.keySetup),
              child: const Text('Enter connection manually'),
            ),
          ],
        ),
      ),
    );
  }
}
