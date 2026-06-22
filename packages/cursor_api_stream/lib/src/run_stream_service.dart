import 'dart:async';

import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:cursor_api_stream/src/logging/sse_event_logger.dart';
import 'package:cursor_api_stream/src/models/sse_event.dart';
import 'package:cursor_api_stream/src/parser/sse_parser.dart';
import 'package:cursor_api_stream/src/reconnection/reconnection_manager.dart';
import 'package:cursor_api_stream/src/tracking/run_stream_tracker.dart';

/// Streams parsed SSE events for a Cursor agent run.
class RunStreamService {
  RunStreamService({
    required String apiKey,
    SseParser? parser,
    SseEventLogger? logger,
    ReconnectionManager? reconnectionManager,
    String baseUrl = CursorApiConfig.baseUrl,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl,
        _parser = parser ?? const SseParser(),
        _logger = logger ?? SseEventLogger(),
        _reconnection = reconnectionManager ?? ReconnectionManager();

  final String _apiKey;
  final String _baseUrl;
  final SseParser _parser;
  final SseEventLogger _logger;
  final ReconnectionManager _reconnection;

  SseEventLogger get logger => _logger;

  ReconnectionManager get reconnectionManager => _reconnection;

  /// Parses SSE from a raw text stream (used in tests and HTTP integration).
  Stream<SseEvent> parseRawStream(
    Stream<String> rawStream, {
    required String agentId,
    required String runId,
  }) {
    final tracker = RunStreamTracker(agentId: agentId, runId: runId);
    return rawStream
        .transform(
          StreamTransformer<String, String>.fromHandlers(
            handleData: (chunk, sink) {
              _logger.logChunk(chunk);
              sink.add(chunk);
            },
          ),
        )
        .asyncExpand(_parser.parse)
        .map((event) {
          tracker.record(event);
          if (event is DoneEvent) {
            _reconnection.markConnected();
          }
          return event;
        });
  }

  /// Builds stream URL for documentation and future HttpClient wiring.
  Uri streamUri(String agentId, String runId, {String? lastEventId}) {
    final uri = Uri.parse('$_baseUrl/agents/$agentId/runs/$runId/stream');
    return uri.replace(
      queryParameters:
          lastEventId != null ? {'lastEventId': lastEventId} : null,
    );
  }

  Map<String, String> streamHeaders({String? lastEventId}) {
    return {
      'Authorization': 'Bearer $_apiKey',
      'Accept': 'text/event-stream',
      if (lastEventId != null) 'Last-Event-ID': lastEventId,
    };
  }
}
