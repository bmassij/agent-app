import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Repositories linked to the Cursor account.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(repositoriesProvider);

    return reposAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _MessageCard(
        title: 'Repositories',
        body: 'Could not load repositories.\n\n$e',
        actionLabel: 'Go to Workers',
        onAction: () => context.go(Routes.homeWorkers),
      ),
      data: (repos) {
        if (repos.isEmpty) {
          return _MessageCard(
            title: 'No repositories yet',
            body: 'Connect GitHub in your workspace settings, '
                'or paste a repo URL when starting a command.',
            actionLabel: 'New command',
            onAction: () => context.go(Routes.homeWorkers),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            Text(
              'Repositories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'These repositories are available for your digital workers.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            ...repos.map(
              (url) => Card(
                child: ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(
                    url,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(body, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.paddingLarge),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
