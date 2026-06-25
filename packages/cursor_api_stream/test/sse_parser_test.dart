import 'dart:io';

import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:test/test.dart';

void main() {
  const parser = SseParser();

  group('live SSE contract — sprint4 capture', () {
    late String rawCapture;

    setUp(() {
      rawCapture =
          File('test/fixtures/sprint4_sse_capture.log').readAsStringSync();
    });

    test('parses all observed event types from live capture', () {
      final events = parser.parseChunk(rawCapture);
      final types = events.map((e) => e.eventType).toSet();

      expect(
        types,
        containsAll([
          'status',
          'heartbeat',
          'interaction_update',
          'assistant',
          'result',
          'done',
        ]),
      );
      expect(types.contains('unknown'), isFalse);
    });

    test('assistant fragments concatenate to final validation text', () {
      final events = parser.parseChunk(rawCapture);
      final assistantText =
          events.whereType<AssistantDeltaEvent>().map((e) => e.delta).join();

      expect(assistantText, 'SPRINT4_VALIDATION_OK');
    });

    test('heartbeat is explicit HeartbeatEvent', () {
      final events = parser.parseChunk(rawCapture);
      expect(events.whereType<HeartbeatEvent>(), hasLength(1));
    });

    test('result event includes live metadata fields', () {
      final result =
          parser.parseChunk(rawCapture).whereType<ResultEvent>().single;

      expect(result.text, 'SPRINT4_VALIDATION_OK');
      expect(result.runId, 'run-33670876-265f-4f39-9fb7-67253c272300');
      expect(result.status, 'FINISHED');
      expect(result.durationMs, 3740);
      expect(result.git?['branches'], isNotEmpty);
    });

    test('status events include runId from live capture', () {
      final statuses = parser.parseChunk(rawCapture).whereType<StatusEvent>();

      expect(statuses, isNotEmpty);
      expect(statuses.first.runId, 'run-33670876-265f-4f39-9fb7-67253c272300');
    });
  });

  group('SSE parser regression', () {
    test('parses assistant text field from live API', () {
      final events = parser.parseChunk(
        'event: assistant\n'
        'data: {"text":"SPR"}\n\n',
      );
      expect(events.single, isA<AssistantDeltaEvent>());
      expect((events.single as AssistantDeltaEvent).delta, 'SPR');
    });

    test('parses assistant delta field for backward compatibility', () {
      final events = parser.parseChunk(
        'event: assistant\n'
        'data: {"delta":"Hello"}\n\n',
      );
      expect((events.single as AssistantDeltaEvent).delta, 'Hello');
    });

    test('parses thinking text field from live API', () {
      final events = parser.parseChunk(
        'event: thinking\n'
        'data: {"text":"hmm"}\n\n',
      );
      expect((events.single as ThinkingDeltaEvent).delta, 'hmm');
    });

    test('parses tool_call with multiline data', () {
      final events = parser.parseChunk(
        'event: tool_call\n'
        'id: evt-1\n'
        'data: {"callId":"c1","name":"read_file","status":"running"}\n\n',
      );
      expect(events.single, isA<ToolCallEvent>());
      final tool = events.single as ToolCallEvent;
      expect(tool.callId, 'c1');
      expect(tool.id, 'evt-1');
    });

    test('skips keep-alive comments and empty blocks', () {
      final events = parser.parseChunk(
        ': keep-alive\n\n'
        'event: done\n'
        'data: {}\n\n',
      );
      expect(events.single, isA<DoneEvent>());
    });

    test('parses error event', () {
      final events = parser.parseChunk(
        'event: error\n'
        'data: {"code":"agent_busy","message":"busy"}\n\n',
      );
      expect(events.single, isA<ErrorEvent>());
    });

    test('unknown event types become UnknownSseEvent', () {
      final events = parser.parseChunk(
        'event: future_type\n'
        'data: {"foo":"bar"}\n\n',
      );
      expect(events.single, isA<UnknownSseEvent>());
    });

    test('parse stream handles chunked UTF-8', () async {
      final events = await parser
          .parse(
            Stream.fromIterable([
              'event: assistant\n',
              'data: {"text":"hi"}\n\n',
            ]),
          )
          .toList();
      expect(events.single, isA<AssistantDeltaEvent>());
      expect((events.single as AssistantDeltaEvent).delta, 'hi');
    });

    test('parses thinking status interaction and result events', () {
      final events = parser.parseChunk(
        'event: thinking\n'
        'data: {"text":"hmm"}\n\n'
        'event: status\n'
        'data: {"runId":"r1","status":"RUNNING"}\n\n'
        'event: interaction_update\n'
        'data: {"type":"step-started"}\n\n'
        'event: result\n'
        'data: {"text":"done","runId":"r1","status":"FINISHED"}\n\n',
      );
      expect(events[0], isA<ThinkingDeltaEvent>());
      expect(events[1], isA<StatusEvent>());
      expect((events[1] as StatusEvent).runId, 'r1');
      expect(events[2], isA<InteractionUpdateEvent>());
      expect(events[3], isA<ResultEvent>());
    });

    test('done event without data body', () {
      final events = parser.parseChunk('event: done\n\n');
      expect(events.single, isA<DoneEvent>());
    });

    test('invalid json becomes UnknownSseEvent', () {
      final events = parser.parseChunk(
        'event: assistant\n'
        'data: not-json\n\n',
      );
      expect(events.single, isA<UnknownSseEvent>());
    });

    test('parse stream flushes trailing block', () async {
      final events = await parser
          .parse(Stream.value('event: done\ndata: {}\n\n'))
          .toList();
      expect(events.single, isA<DoneEvent>());
    });
  });
}
