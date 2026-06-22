import 'dart:convert';

import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:drift/drift.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';

/// Persists SSE events to Drift tables.
class ChatSsePersister {
  ChatSsePersister({
    required AppDatabase database,
    required AgentLocalSource agentLocal,
  })  : _db = database,
        _agentLocal = agentLocal;

  final AppDatabase _db;
  final AgentLocalSource _agentLocal;
  int _sequence = 0;

  Future<void> persist({
    required String agentId,
    required String runId,
    required SseEvent event,
  }) async {
    _sequence++;
    final now = DateTime.now().toUtc();

    switch (event) {
      case AssistantDeltaEvent(:final delta):
        await _appendDelta(
          runId: runId,
          role: 'assistant',
          eventType: 'assistant',
          delta: delta,
          sequence: _sequence,
          timestamp: now,
        );
      case ThinkingDeltaEvent(:final delta):
        await _appendDelta(
          runId: runId,
          role: 'thinking',
          eventType: 'thinking',
          delta: delta,
          sequence: _sequence,
          timestamp: now,
        );
      case ToolCallEvent(
          :final callId,
          :final name,
          :final status,
          :final args,
          :final result,
        ):
        await _db.into(_db.toolCallLogs).insertOnConflictUpdate(
              ToolCallLogsCompanion.insert(
                callId: callId.isEmpty ? '${runId}_tool_$_sequence' : callId,
                runId: runId,
                toolName: name,
                status: status,
                argsJson: jsonEncode(args ?? {}),
                resultJson: Value(result == null ? null : jsonEncode(result)),
                startedAt: now,
                completedAt: Value(
                  status == 'completed' || status == 'done' ? now : null,
                ),
              ),
            );
      case ResultEvent(:final text):
        await _upsertMessage(
          id: '${runId}_result',
          runId: runId,
          role: 'result',
          eventType: 'result',
          content: text,
          sequence: _sequence,
          timestamp: now,
        );
      case StatusEvent(:final status):
        await _upsertMessage(
          id: '${runId}_status_$_sequence',
          runId: runId,
          role: 'status',
          eventType: 'status',
          content: status,
          sequence: _sequence,
          timestamp: now,
        );
      case InteractionUpdateEvent(:final payload):
        final label = payload['message'] as String? ??
            payload['kind'] as String? ??
            jsonEncode(payload);
        await _upsertMessage(
          id: '${runId}_interaction_$_sequence',
          runId: runId,
          role: 'interaction_update',
          eventType: 'interaction_update',
          content: label,
          sequence: _sequence,
          timestamp: now,
        );
      case DoneEvent():
        await _agentLocal.upsertRun(
          runId: runId,
          agentId: agentId,
          status: 'finished',
          completedAt: now,
        );
        final agent = await _agentLocal.getAgent(agentId);
        if (agent != null) {
          await _agentLocal.upsertAgent(
            agentId: agentId,
            projectId: agent.projectId,
            name: agent.name,
            status: 'finished',
            latestRunId: runId,
            updatedAt: now,
          );
        }
      case ErrorEvent(:final code, :final message):
        await _agentLocal.upsertRun(
          runId: runId,
          agentId: agentId,
          status: 'error',
          errorCode: code,
          errorMessage: message,
          completedAt: now,
        );
      case UnknownSseEvent():
        break;
    }
  }

  Future<void> _appendDelta({
    required String runId,
    required String role,
    required String eventType,
    required String delta,
    required int sequence,
    required DateTime timestamp,
  }) async {
    final messageId = '${runId}_$role';
    final existing = await (_db.select(_db.chatMessages)
          ..where((t) => t.id.equals(messageId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.chatMessages).insert(
            ChatMessagesCompanion.insert(
              id: messageId,
              runId: runId,
              role: role,
              content: delta,
              eventType: eventType,
              sequenceIndex: sequence,
              timestamp: timestamp,
            ),
          );
    } else {
      await (_db.update(_db.chatMessages)..where((t) => t.id.equals(messageId)))
          .write(
        ChatMessagesCompanion(
          content: Value(existing.content + delta),
          sequenceIndex: Value(sequence),
          timestamp: Value(timestamp),
        ),
      );
    }
  }

  Future<void> _upsertMessage({
    required String id,
    required String runId,
    required String role,
    required String eventType,
    required String content,
    required int sequence,
    required DateTime timestamp,
  }) async {
    await _db.into(_db.chatMessages).insertOnConflictUpdate(
          ChatMessagesCompanion.insert(
            id: id,
            runId: runId,
            role: role,
            content: content,
            eventType: eventType,
            sequenceIndex: sequence,
            timestamp: timestamp,
          ),
        );
  }
}
