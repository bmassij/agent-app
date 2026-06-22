import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';
import 'package:cursor_mobile_commander/features/tasks/presentation/tasks_provider.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: tasksAsync.when(
        loading: () => const LoadingSpinner(message: 'Loading runs…'),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(tasksProvider),
        ),
        data: (buckets) => ListView(
          children: [
            _Section(
              title: 'Running',
              runs: buckets.running,
              onTap: (run) => context.push(
                Routes.runLogs(run.agentId, run.runId),
              ),
            ),
            _Section(
              title: 'Completed',
              runs: buckets.completed,
              onTap: (run) => context.push(
                Routes.runLogs(run.agentId, run.runId),
              ),
            ),
            _Section(
              title: 'Failed',
              runs: buckets.failed,
              onTap: (run) => context.push(
                Routes.runLogs(run.agentId, run.runId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.runs,
    required this.onTap,
  });

  final String title;
  final List<RunSummary> runs;
  final void Function(RunSummary run) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (runs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('None'),
          )
        else
          ...runs.map(
            (run) => ListTile(
              title: Text(run.runId),
              subtitle: Text('Agent ${run.agentId} · ${run.status}'),
              onTap: () => onTap(run),
            ),
          ),
      ],
    );
  }
}
