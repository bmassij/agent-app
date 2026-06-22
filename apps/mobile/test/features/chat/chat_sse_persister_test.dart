import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/chat/data/chat_sse_persister.dart';

void main() {
  late AppDatabase db;
  late ChatSsePersister persister;

  setUp(() {
    db = AppDatabase.inMemory();
    persister = ChatSsePersister(
      database: db,
      agentLocal: AgentLocalSource(db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('persists assistant delta and done updates run', () async {
    await db.into(db.agentSessions).insert(
          AgentSessionsCompanion.insert(
            agentId: 'a1',
            projectId: 'p1',
            name: 'Test',
            status: 'running',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await db.into(db.runRecords).insert(
          RunRecordsCompanion.insert(
            runId: 'r1',
            agentId: 'a1',
            status: 'running',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        );

    await persister.persist(
      agentId: 'a1',
      runId: 'r1',
      event: const AssistantDeltaEvent(delta: 'Hello'),
    );
    await persister.persist(
      agentId: 'a1',
      runId: 'r1',
      event: const DoneEvent(),
    );

    final messages = await db.select(db.chatMessages).get();
    expect(messages, hasLength(1));
    expect(messages.single.content, 'Hello');

    final run = await db.select(db.runRecords).getSingle();
    expect(run.status, 'finished');
  });

  test('persists tool call event', () async {
    await persister.persist(
      agentId: 'a1',
      runId: 'r1',
      event: const ToolCallEvent(
        callId: 'tc1',
        name: 'grep',
        status: 'running',
        args: {'pattern': 'foo'},
      ),
    );

    final tools = await db.select(db.toolCallLogs).get();
    expect(tools.single.toolName, 'grep');
  });
}
