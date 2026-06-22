import 'dart:convert';

import 'package:cursor_api_stream/src/models/sse_event.dart';

/// Parses Server-Sent Events text into [SseEvent] instances.
class SseParser {
  const SseParser();

  /// Parses a complete SSE block (one or more events).
  List<SseEvent> parseChunk(String chunk) {
    final events = <SseEvent>[];
    final buffer = StringBuffer();
    buffer.write(chunk);
    final normalized = buffer.toString().replaceAll('\r\n', '\n');
    final blocks = normalized.split('\n\n');

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final parsed = _parseBlock(trimmed);
      if (parsed != null) {
        events.add(parsed);
      }
    }
    return events;
  }

  /// Converts a stream of text chunks into [SseEvent]s.
  Stream<SseEvent> parse(Stream<String> chunkStream) async* {
    var pending = '';
    await for (final chunk in chunkStream) {
      pending += chunk;
      final parts = pending.split('\n\n');
      if (parts.length > 1) {
        pending = parts.removeLast();
        for (final part in parts) {
          final event = _parseBlock(part.trim());
          if (event != null) {
            yield event;
          }
        }
      }
    }
    if (pending.trim().isNotEmpty) {
      final event = _parseBlock(pending.trim());
      if (event != null) {
        yield event;
      }
    }
  }

  SseEvent? _parseBlock(String block) {
    if (block.isEmpty) {
      return null;
    }
    var eventType = 'message';
    String? id;
    final dataLines = <String>[];

    for (final line in block.split('\n')) {
      if (line.isEmpty || line.startsWith(':')) {
        continue;
      }
      if (line.startsWith('event:')) {
        eventType = line.substring(6).trim();
      } else if (line.startsWith('id:')) {
        id = line.substring(3).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      }
    }

    if (dataLines.isEmpty && eventType == 'message') {
      return null;
    }

    final rawData = dataLines.join('\n');
    if (rawData.isEmpty && eventType == 'done') {
      return DoneEvent(id: id);
    }

    Map<String, dynamic> json;
    try {
      json = rawData.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(rawData) as Map<String, dynamic>;
    } catch (_) {
      return UnknownSseEvent(
        rawEventType: eventType,
        rawData: rawData,
        id: id,
      );
    }

    return switch (eventType) {
      'assistant' => AssistantDeltaEvent.fromData(json, id: id),
      'thinking' => ThinkingDeltaEvent.fromData(json, id: id),
      'tool_call' => ToolCallEvent.fromData(json, id: id),
      'status' => StatusEvent.fromData(json, id: id),
      'interaction_update' => InteractionUpdateEvent.fromData(json, id: id),
      'result' => ResultEvent.fromData(json, id: id),
      'done' => DoneEvent(id: id),
      'error' => ErrorEvent.fromData(json, id: id),
      _ => UnknownSseEvent(rawEventType: eventType, rawData: rawData, id: id),
    };
  }
}
