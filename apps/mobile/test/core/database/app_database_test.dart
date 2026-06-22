import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test('getOrCreateSettings returns default row', () async {
    final settings = await db.getOrCreateSettings();
    expect(settings.onboardingCompleted, isFalse);
    expect(settings.biometricEnabled, isFalse);

    final again = await db.getOrCreateSettings();
    expect(again.id, settings.id);
  });

  test('persists pinned project and user settings updates', () async {
    await db.into(db.pinnedProjects).insert(
          PinnedProjectsCompanion.insert(
            id: 'proj-1',
            repoUrl: 'https://github.com/org/repo',
            owner: 'org',
            name: 'repo',
            defaultBranch: 'main',
          ),
        );

    final projects = await db.select(db.pinnedProjects).get();
    expect(projects, hasLength(1));
    expect(projects.first.name, 'repo');

    final settings = await db.getOrCreateSettings();
    await (db.update(db.userSettings)..where((t) => t.id.equals(settings.id)))
        .write(
      UserSettingsCompanion(
        onboardingCompleted: const Value(true),
        biometricEnabled: const Value(true),
        updatedAt: Value(DateTime.utc(2026, 1, 1)),
      ),
    );

    final updated = await db.getOrCreateSettings();
    expect(updated.onboardingCompleted, isTrue);
    expect(updated.biometricEnabled, isTrue);
  });

  test('persists agent session and chat message', () async {
    final now = DateTime.utc(2026, 6, 1, 12);
    await db.into(db.agentSessions).insert(
          AgentSessionsCompanion.insert(
            agentId: 'agent-1',
            projectId: 'proj-1',
            name: 'Test Agent',
            status: 'idle',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            id: 'msg-1',
            runId: 'run-1',
            role: 'user',
            content: 'Hello',
            eventType: 'message',
            sequenceIndex: 0,
            timestamp: now,
          ),
        );

    final sessions = await db.select(db.agentSessions).get();
    final messages = await db.select(db.chatMessages).get();
    expect(sessions.single.agentId, 'agent-1');
    expect(messages.single.content, 'Hello');
  });
}
