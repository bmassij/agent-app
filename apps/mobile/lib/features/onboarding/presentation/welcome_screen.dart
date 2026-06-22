import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';

/// Onboarding entry screen (Sprint 1 placeholder).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cursor Mobile Commander'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.connectCursor),
              child: const Text('Get started'),
            ),
          ],
        ),
      ),
    );
  }
}
