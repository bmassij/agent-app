import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/chat/data/queued_prompt_service.dart';

void main() {
  late AppDatabase db;
  late QueuedPromptService service;

  setUp(() async {
    db = AppDatabase.inMemory();
    service = QueuedPromptService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('enqueue writes pending row to queued_prompts', () async {
    final id = await service.enqueue(
      repoUrl: 'https://github.com/o/r',
      promptText: 'Fix bug',
      agentId: 'agent-1',
    );

    final pending = await service.listPending();
    expect(pending, hasLength(1));
    expect(pending.single.id, id);
    expect(pending.single.promptText, 'Fix bug');
    expect(pending.single.status, 'pending');
  });

  test('markSent updates status', () async {
    final id = await service.enqueue(
      repoUrl: 'https://github.com/o/r',
      promptText: 'Hello',
    );
    await service.markSent(id);
    final pending = await service.listPending();
    expect(pending, isEmpty);
  });
}
