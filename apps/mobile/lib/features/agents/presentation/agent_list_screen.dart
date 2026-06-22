import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/widgets/agent_status_chip.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/new_agent_sheet.dart';
import 'package:cursor_mobile_commander/features/tasks/presentation/task_list_screen.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

class AgentListScreen extends ConsumerWidget {
  const AgentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.task_alt_outlined),
            tooltip: 'Tasks',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TaskListScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(agentListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showNewAgentSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New agent'),
      ),
      body: agentsAsync.when(
        loading: () => const LoadingSpinner(message: 'Loading agents…'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(agentListProvider.notifier).refresh(),
        ),
        data: (agents) {
          if (agents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No agents yet'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => showNewAgentSheet(context, ref),
                    child: const Text('Create your first agent'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(agentListProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: agents.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final agent = agents[index];
                return ListTile(
                  title: Text(agent.name),
                  subtitle: Text(agent.agentId),
                  trailing: AgentStatusChip(status: agent.status),
                  onTap: () => context.push(Routes.agentDetail(agent.agentId)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
