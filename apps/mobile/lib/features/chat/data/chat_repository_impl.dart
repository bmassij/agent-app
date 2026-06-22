import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_sse_persister.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_repository.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required AppDatabase database,
    required RunStreamService streamService,
    required api.AgentRepository apiRepository,
    required ChatLocalSource localSource,
    required AgentLocalSource agentLocal,
  })  : _db = database,
        _stream = streamService,
        _api = apiRepository,
        _local = localSource,
        _persister = ChatSsePersister(database: database, agentLocal: agentLocal);

  final AppDatabase _db;
  final RunStreamService _stream;
  final api.AgentRepository _api;
  final ChatLocalSource _local;
  final ChatSsePersister _persister;
  bool _liveSseLogged = false;

  @override
  bool get hasLoggedLiveSse => _liveSseLogged;

  @override
  List<String> get rawSseLogLines => _stream.logger.loggedLines;

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
  Stream<SseEvent> streamRun({
    required String agentId,
    required String runId,
    String? lastEventId,
  }) {
    return _stream
        .connectRun(
          agentId: agentId,
          runId: runId,
          lastEventId: lastEventId,
          onStreamExpired: () {},
        )
        .map((event) {
          if (!_liveSseLogged && _stream.logger.loggedLines.isNotEmpty) {
            _liveSseLogged = true;
          }
          return event;
        });
  }

  @override
  Future<void> persistSseEvent({
    required String agentId,
    required String runId,
    required SseEvent event,
  }) {
    return _persister.persist(agentId: agentId, runId: runId, event: event);
  }

  @override
  Future<Either<api.AgentFailure, Unit>> fetchUsageForRun({
    required String agentId,
    required String runId,
  }) async {
    final result = await _api.getUsage(agentId);
    return result.fold(
      left,
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
