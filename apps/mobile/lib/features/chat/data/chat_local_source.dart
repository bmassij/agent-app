import 'package:drift/drift.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';

class ChatLocalSource {
  ChatLocalSource(this._db);

  final AppDatabase _db;

  Stream<List<ChatMessageModel>> watchMessagesForAgent(String agentId) {
    final runsQuery = _db.select(_db.runRecords)
      ..where((t) => t.agentId.equals(agentId));
    return runsQuery.watch().asyncMap((runs) async {
      if (runs.isEmpty) {
        return <ChatMessageModel>[];
      }
      final runIds = runs.map((r) => r.runId).toList();
      final messages = await (_db.select(_db.chatMessages)
            ..where((t) => t.runId.isIn(runIds))
            ..orderBy([
              (t) => OrderingTerm.asc(t.timestamp),
              (t) => OrderingTerm.asc(t.sequenceIndex),
            ]))
          .get();
      return messages.map(_mapMessage).toList();
    });
  }

  Stream<List<ToolCallModel>> watchToolCallsForAgent(String agentId) {
    final runsQuery = _db.select(_db.runRecords)
      ..where((t) => t.agentId.equals(agentId));
    return runsQuery.watch().asyncMap((runs) async {
      if (runs.isEmpty) {
        return <ToolCallModel>[];
      }
      final runIds = runs.map((r) => r.runId).toList();
      final tools = await (_db.select(_db.toolCallLogs)
            ..where((t) => t.runId.isIn(runIds))
            ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
          .get();
      return tools.map(_mapTool).toList();
    });
  }

  Future<List<ChatMessageModel>> messagesForRun(String runId) async {
    final rows = await (_db.select(_db.chatMessages)
          ..where((t) => t.runId.equals(runId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.timestamp),
            (t) => OrderingTerm.asc(t.sequenceIndex),
          ]))
        .get();
    return rows.map(_mapMessage).toList();
  }

  Future<List<ToolCallModel>> toolCallsForRun(String runId) async {
    final rows = await (_db.select(_db.toolCallLogs)
          ..where((t) => t.runId.equals(runId))
          ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
        .get();
    return rows.map(_mapTool).toList();
  }

  Future<void> insertUserMessage({
    required String runId,
    required String content,
  }) async {
    final now = DateTime.now().toUtc();
    final id = '${runId}_user_${now.microsecondsSinceEpoch}';
    await _db.into(_db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            id: id,
            runId: runId,
            role: 'user',
            content: content,
            eventType: 'user',
            sequenceIndex: now.millisecondsSinceEpoch,
            timestamp: now,
          ),
        );
  }

  ChatMessageModel _mapMessage(ChatMessageRow row) {
    return ChatMessageModel(
      id: row.id,
      runId: row.runId,
      role: row.role,
      content: row.content,
      eventType: row.eventType,
      sequenceIndex: row.sequenceIndex,
      timestamp: row.timestamp,
    );
  }

  ToolCallModel _mapTool(ToolCallLogRow row) {
    return ToolCallModel(
      callId: row.callId,
      runId: row.runId,
      toolName: row.toolName,
      status: row.status,
      argsJson: row.argsJson,
      resultJson: row.resultJson,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
    );
  }
}
