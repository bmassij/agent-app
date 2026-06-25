import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Onboarding entry — connect workspace, then delegate tasks.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'Delegate work from your phone',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingMedium),
              Text(
                'Connect your workspace, then delegate tasks to your '
                'digital workers — results delivered, technology invisible.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(Routes.connectCursor),
                child: const Text('Connect workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
