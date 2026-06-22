import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Routes to API key setup.
class ConnectCursorScreen extends StatelessWidget {
  const ConnectCursorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Cursor')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cursor Mobile Commander uses your Cursor API key to manage '
              'Cloud Agents. Your key is stored securely on this device.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.push(Routes.keySetup),
              child: const Text('Enter API key'),
            ),
          ],
        ),
      ),
    );
  }
}
