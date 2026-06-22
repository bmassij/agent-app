import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_failure.dart';
import 'package:cursor_mobile_commander/features/projects/presentation/projects_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Manual repository URL entry (GitHub API list deferred to Sprint 3/5).
class PinRepoScreen extends ConsumerStatefulWidget {
  const PinRepoScreen({super.key});

  @override
  ConsumerState<PinRepoScreen> createState() => _PinRepoScreenState();
}

class _PinRepoScreenState extends ConsumerState<PinRepoScreen> {
  final _urlController = TextEditingController(
    text: 'https://github.com/',
  );
  final _branchController = TextEditingController(text: 'main');

  @override
  void dispose() {
    _urlController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pinRepo() async {
    final ok = await ref.read(pinRepoProvider.notifier).pinFromUrl(
          repoUrl: _urlController.text,
          defaultBranch: _branchController.text,
        );
    if (ok && mounted) {
      context.go(Routes.firstAgent);
    }
  }

  String _failureMessage(ProjectFailure failure) {
    return switch (failure) {
      InvalidRepoUrlFailure(:final message) => message,
      ProjectStorageFailure(:final message) => message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinRepoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pin Repository')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pin a GitHub repository for your agents. '
              'Full repo browser arrives in Sprint 5.',
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Repository URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            TextField(
              controller: _branchController,
              decoration: const InputDecoration(
                labelText: 'Default branch',
                border: OutlineInputBorder(),
              ),
            ),
            if (pinState case AsyncData(:final value))
              value.fold(
                () => const SizedBox.shrink(),
                (failure) => Padding(
                  padding: const EdgeInsets.only(top: AppSizes.paddingSmall),
                  child: Text(
                    _failureMessage(failure),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: pinState.isLoading ? null : _pinRepo,
              child: const Text('Pin repository'),
            ),
            TextButton(
              onPressed: () => context.go(Routes.firstAgent),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}
