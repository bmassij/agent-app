import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';

/// Placeholder — Sprint 2 implements API key paste and QR scan.
class ConnectCursorScreen extends StatelessWidget {
  const ConnectCursorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect Cursor')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('API key setup — Sprint 2'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.connectGithub),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
