import 'dart:async';

import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:test/test.dart';

void main() {
  const parser = SseParser();

  test('parses assistant event', () {
    final events = parser.parseChunk(
      'event: assistant\n'
      'data: {"delta":"Hello"}\n\n',
    );
    expect(events, hasLength(1));
    expect(events.first, isA<AssistantDeltaEvent>());
    expect((events.first as AssistantDeltaEvent).delta, 'Hello');
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
    final controller = StreamController<String>();
    final future = parser.parse(controller.stream).toList();
    controller
      ..add('event: assistant\n')
      ..add('data: {"delta":"hi"}\n\n')
      ..close();
    final events = await future;
    expect(events.single, isA<AssistantDeltaEvent>());
  });

  test('parses thinking status interaction and result events', () {
    final events = parser.parseChunk(
      'event: thinking\n'
      'data: {"delta":"hmm"}\n\n'
      'event: status\n'
      'data: {"status":"running"}\n\n'
      'event: interaction_update\n'
      'data: {"kind":"approval"}\n\n'
      'event: result\n'
      'data: {"text":"done"}\n\n',
    );
    expect(events[0], isA<ThinkingDeltaEvent>());
    expect(events[1], isA<StatusEvent>());
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
    final events =
        await parser.parse(Stream.value('event: done\ndata: {}\n\n')).toList();
    expect(events.single, isA<DoneEvent>());
  });
}
