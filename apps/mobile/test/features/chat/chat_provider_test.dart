import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/features/chat/presentation/chat_provider.dart';

void main() {
  test('RunStreamKey equality uses all fields', () {
    const a = RunStreamKey(agentId: 'a1', runId: 'r1', lastEventId: 'e1');
    const b = RunStreamKey(agentId: 'a1', runId: 'r1', lastEventId: 'e1');
    const c = RunStreamKey(agentId: 'a1', runId: 'r2');

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  test('ChatState copyWith clears error and run id', () {
    const state = ChatState(
      composerText: 'hi',
      errorMessage: 'err',
      currentRunId: 'r1',
      isRunActive: true,
    );

    final cleared = state.copyWith(clearError: true, clearRunId: true);
    expect(cleared.errorMessage, isNull);
    expect(cleared.currentRunId, isNull);
    expect(cleared.composerText, 'hi');
  });
}
