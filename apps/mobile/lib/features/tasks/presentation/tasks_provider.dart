import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

class TaskBuckets {
  const TaskBuckets({
    required this.running,
    required this.completed,
    required this.failed,
  });

  final List<RunSummary> running;
  final List<RunSummary> completed;
  final List<RunSummary> failed;
}

final tasksProvider = FutureProvider<TaskBuckets>((ref) async {
  final local = await ref.watch(agentLocalSourceProvider.future);
  final runs = await local.listAllRuns();
  return TaskBuckets(
    running: runs.where((r) => r.isRunning).toList(),
    completed: runs.where((r) => r.isCompleted).toList(),
    failed: runs.where((r) => r.isFailed).toList(),
  );
});

class RunLogsData {
  const RunLogsData({
    required this.messages,
    required this.tools,
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
  });

  final List<ChatMessageModel> messages;
  final List<ToolCallModel> tools;
  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;
}

final runLogsProvider =
    FutureProvider.family<RunLogsData, String>((ref, runId) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  final chatLocal = ChatLocalSource(db);
  final messages = await chatLocal.messagesForRun(runId);
  final tools = await chatLocal.toolCallsForRun(runId);
  final usage = await (db.select(db.usageRecords)
        ..where((t) => t.runId.equals(runId)))
      .getSingleOrNull();
  return RunLogsData(
    messages: messages,
    tools: tools,
    inputTokens: usage?.inputTokens,
    outputTokens: usage?.outputTokens,
    totalTokens: usage?.totalTokens,
  );
});
