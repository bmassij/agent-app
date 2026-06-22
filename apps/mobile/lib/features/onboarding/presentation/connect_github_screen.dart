import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';

/// Placeholder — Sprint 2 implements GitHub OAuth PKCE.
class ConnectGithubScreen extends StatelessWidget {
  const ConnectGithubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect GitHub')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('GitHub OAuth — Sprint 2'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(Routes.pinRepo),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
