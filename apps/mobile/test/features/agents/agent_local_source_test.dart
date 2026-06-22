import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';

void main() {
  late AppDatabase db;
  late AgentLocalSource source;

  setUp(() {
    db = AppDatabase.inMemory();
    source = AgentLocalSource(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertAgent and watchAgents emit sessions', () async {
    await source.upsertAgent(
      agentId: 'a1',
      projectId: 'org/repo',
      name: 'Fix bug',
      status: 'running',
      latestRunId: 'r1',
    );

    final agents = await source.listAgents();
    expect(agents, hasLength(1));
    expect(agents.single, isA<AgentSession>());
    expect(agents.single.name, 'Fix bug');
  });

  test('upsertRun stores run summary', () async {
    await source.upsertRun(
      runId: 'r1',
      agentId: 'a1',
      status: 'running',
    );

    final runs = await source.listRunsForAgent('a1');
    expect(runs.single.runId, 'r1');
    expect(runs.single.isRunning, isTrue);
  });
}
