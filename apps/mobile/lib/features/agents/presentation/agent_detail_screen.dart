import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/widgets/agent_status_chip.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

class AgentDetailScreen extends ConsumerWidget {
  const AgentDetailScreen({
    required this.agentId,
    super.key,
  });

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(agentId));
    final runsAsync = ref.watch(agentRunsProvider(agentId));

    return Scaffold(
      appBar: AppBar(
        title: agentAsync.when(
          data: (a) => Text(a?.name ?? 'Agent'),
          loading: () => const Text('Agent'),
          error: (_, __) => const Text('Agent'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push(Routes.agentChat(agentId)),
          ),
        ],
      ),
      body: agentAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(agentProvider(agentId).notifier).refresh(),
        ),
        data: (agent) {
          if (agent == null) {
            return const ErrorView(message: 'Agent not found');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AgentStatusChip(status: agent.status),
              const SizedBox(height: 16),
              Text('ID: ${agent.agentId}'),
              Text('Project: ${agent.projectId}'),
              if (agent.latestRunId != null)
                Text('Latest run: ${agent.latestRunId}'),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.push(Routes.agentChat(agentId)),
                icon: const Icon(Icons.chat),
                label: const Text('Open chat'),
              ),
              const SizedBox(height: 24),
              Text(
                'Runs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              runsAsync.when(
                loading: () => const LoadingSpinner(),
                error: (e, _) => Text(e.toString()),
                data: (runs) {
                  if (runs.isEmpty) {
                    return const Text('No runs recorded yet.');
                  }
                  return Column(
                    children: runs
                        .map(
                          (run) => ListTile(
                            title: Text(run.runId),
                            subtitle: Text(run.status),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              Routes.runLogs(agentId, run.runId),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

final agentRunsProvider =
    FutureProvider.family<List<RunSummary>, String>((ref, agentId) async {
  final repo = await ref.watch(agentRepositoryProvider.future);
  return repo.listRunsLocal(agentId);
});
