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
            'event: assistant\ndata: {"delta":"ok"}\n\n'
            'event: done\ndata: {}\n\n',
          ),
          agentId: 'a1',
          runId: 'r1',
        )
        .toList();
    expect(events.first, isA<AssistantDeltaEvent>());
    expect(events.last, isA<DoneEvent>());
    expect(logger.loggedLines, isNotEmpty);
    expect(service.reconnectionManager.state, StreamConnectionState.connected);
  });

  test('streamUri and streamHeaders include last event id', () {
    final service = RunStreamService(apiKey: 'cursor_key');
    final uri = service.streamUri('a1', 'r1', lastEventId: 'evt-9');
    expect(uri.path, contains('/agents/a1/runs/r1/stream'));
    expect(uri.queryParameters['lastEventId'], 'evt-9');

    final headers = service.streamHeaders(lastEventId: 'evt-9');
    expect(headers['Authorization'], 'Bearer cursor_key');
    expect(headers['Last-Event-ID'], 'evt-9');
    expect(headers['Accept'], 'text/event-stream');
  });

  test('SseEventLogger logChunk splits lines', () {
    final lines = <String>[];
    final logger = SseEventLogger(sink: lines.add);
    logger.logChunk('event: status\ndata: {}\n');
    expect(lines, isNotEmpty);
  });

  test('SseEventLogger disabled and clear', () {
    final lines = <String>[];
    final logger = SseEventLogger(enabled: false, sink: lines.add);
    logger.logRawLine('event: x');
    expect(lines, isEmpty);
    logger.clear();
    expect(logger.loggedLines, isEmpty);
  });

  test('RunStreamTracker tracks error events as terminal', () {
    final tracker = RunStreamTracker(agentId: 'a1', runId: 'r1');
    tracker.record(
      const ErrorEvent(code: 'x', message: 'fail', id: 'e1'),
    );
    expect(tracker.isComplete, isTrue);
    expect(tracker.lastEventId, 'e1');
    expect(tracker.toSnapshot()['sequenceIndex'], 1);
  });
}
