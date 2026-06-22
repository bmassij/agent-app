import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Final onboarding step — enable biometrics and enter the app.
class FirstAgentScreen extends ConsumerWidget {
  const FirstAgentScreen({super.key});

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref, {
    required bool enableBiometric,
  }) async {
    if (enableBiometric) {
      final repo = await ref.read(authRepositoryProvider.future);
      await repo.setBiometricEnabled(true);
    }
    await ref.read(onboardingCompletedProvider.notifier).markCompleted();
    if (context.mounted) {
      context.go(Routes.homeProjects);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ready')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "You're set up! Create your first agent from the Agents tab "
              'once Sprint 4 ships. For now, explore your project dashboard.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _finish(context, ref, enableBiometric: true),
              child: const Text('Enable biometrics & finish'),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            OutlinedButton(
              onPressed: () => _finish(context, ref, enableBiometric: false),
              child: const Text('Finish without biometrics'),
            ),
          ],
        ),
      ),
    );
  }
}
