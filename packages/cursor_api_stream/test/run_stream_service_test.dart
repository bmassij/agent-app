import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:test/test.dart';

void main() {
  test('SseEventLogger redacts bearer lines', () {
    final lines = <String>[];
    final logger = SseEventLogger(sink: lines.add);
    logger.logRawLine('Authorization: Bearer secret');
    logger.logRawLine('event: assistant');
    expect(lines, ['[SSE] event: assistant']);
  });

  test('RunStreamTracker records sequence and completion', () {
    final tracker = RunStreamTracker(agentId: 'a1', runId: 'r1');
    tracker.record(const AssistantDeltaEvent(delta: 'x', id: 'e1'));
    tracker.record(const DoneEvent(id: 'e2'));
    expect(tracker.sequenceIndex, 2);
    expect(tracker.lastEventId, 'e2');
    expect(tracker.isComplete, isTrue);
  });

  test('RunStreamService logs and parses raw stream', () async {
    final logger = SseEventLogger(sink: (_) {});
    final service = RunStreamService(
      apiKey: 'cursor_test',
      logger: logger,
    );
    final events = await service
        .parseRawStream(
          Stream.value(
            'event: assistant\ndata: {"delta":"ok"}\n\n',
          ),
          agentId: 'a1',
          runId: 'r1',
        )
        .toList();
    expect(events.single, isA<AssistantDeltaEvent>());
    expect(logger.loggedLines, isNotEmpty);
  });
}
