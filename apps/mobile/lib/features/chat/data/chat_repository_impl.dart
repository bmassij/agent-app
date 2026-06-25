import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_execution_provider/cursor_execution_provider.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/agents/data/execution_failure_mapper.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_failure.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_sse_persister.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_repository.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required AppDatabase database,
    required ExecutionProvider executionProvider,
    required ChatLocalSource localSource,
    required AgentLocalSource agentLocal,
  })  : _db = database,
        _execution = executionProvider,
        _local = localSource,
        _persister =
            ChatSsePersister(database: database, agentLocal: agentLocal);

  final AppDatabase _db;
  final ExecutionProvider _execution;
  final ChatLocalSource _local;
  final ChatSsePersister _persister;
  bool _liveSseLogged = false;

  @override
  bool get hasLoggedLiveSse => _liveSseLogged;

  @override
  List<String> get rawSseLogLines {
    final provider = _execution;
    if (provider is CursorExecutionProvider) {
      return provider.rawSseLogLines;
    }
    return const [];
  }

  @override
  Stream<List<ChatMessageModel>> watchMessagesForAgent(String agentId) {
    return _local.watchMessagesForAgent(agentId);
  }

  @override
  Stream<List<ToolCallModel>> watchToolCallsForAgent(String agentId) {
    return _local.watchToolCallsForAgent(agentId);
  }

  @override
  Future<void> insertUserMessage({
    required String runId,
    required String content,
  }) {
    return _local.insertUserMessage(runId: runId, content: content);
  }

  @override
  Stream<TaskStreamEvent> streamRun({
    required String agentId,
    required String runId,
    String? lastEventId,
  }) {
    return _execution
        .streamTask(
      TaskStreamRequest(
        taskId: agentId,
        runId: runId,
        lastEventId: lastEventId,
      ),
    )
        .map((event) {
      if (!_liveSseLogged && rawSseLogLines.isNotEmpty) {
        _liveSseLogged = true;
      }
      return event;
    });
  }

  @override
  Future<void> persistStreamEvent({
    required String agentId,
    required String runId,
    required TaskStreamEvent event,
  }) {
    return _persister.persist(agentId: agentId, runId: runId, event: event);
  }

  @override
  Future<Either<AgentFailure, Unit>> fetchUsageForRun({
    required String agentId,
    required String runId,
  }) async {
    final result = await _execution.getUsage(agentId);
    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (usage) async {
        final row = usage.runs.where((r) => r.runId == runId).firstOrNull;
        if (row != null) {
          final input = row.inputTokens ?? 0;
          final output = row.outputTokens ?? 0;
          await _db.into(_db.usageRecords).insertOnConflictUpdate(
                UsageRecordsCompanion.insert(
                  runId: runId,
                  inputTokens: Value(input),
                  outputTokens: Value(output),
                  totalTokens: Value(input + output),
                  recordedAt: DateTime.now().toUtc(),
                ),
              );
        }
        return right(unit);
      },
    );
  }
}
