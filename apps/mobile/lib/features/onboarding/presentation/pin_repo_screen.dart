import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';

/// Placeholder — Sprint 2 implements repository pinning.
class PinRepoScreen extends StatelessWidget {
  const PinRepoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pin Repository')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pin a repo — Sprint 2'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.firstAgent),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
