import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
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
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _pinRepo() async {
    final url = _urlController.text.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('github.com')) {
      setState(() => _error = 'Enter a valid GitHub repository URL');
      return;
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) {
      setState(() => _error = 'URL must be https://github.com/owner/repo');
      return;
    }
    final owner = segments[0];
    final name = segments[1];
    final db = await ref.read(appDatabaseFutureProvider.future);
    await db.into(db.pinnedProjects).insertOnConflictUpdate(
          PinnedProjectsCompanion.insert(
            id: '$owner/$name',
            repoUrl: url,
            owner: owner,
            name: name,
            defaultBranch: _branchController.text.trim().isEmpty
                ? 'main'
                : _branchController.text.trim(),
            sortOrder: const Value(0),
          ),
        );
    ref.invalidate(pinnedProjectCountProvider);
    if (mounted) {
      context.go(Routes.firstAgent);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            if (_error != null) ...[
              const SizedBox(height: AppSizes.paddingSmall),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            FilledButton(
              onPressed: _pinRepo,
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
