import 'dart:async';
import 'dart:convert';

import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:dio/dio.dart';
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
        .asyncExpand((chunk) async* {
          for (final event in _parser.parseChunk(chunk)) {
            yield event;
          }
        })
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

  /// Opens a live SSE connection with exponential backoff reconnection.
  ///
  /// On HTTP 410 / [CursorStreamExpiredError], marks stream expired and stops.
  /// Raw lines are logged via [SseEventLogger] on first connection.
  Stream<SseEvent> connectRun({
    required String agentId,
    required String runId,
    String? lastEventId,
    Dio? dio,
    void Function()? onStreamExpired,
  }) async* {
    var resumeId = lastEventId;
    final http = dio ??
        Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: CursorApiConfig.connectTimeout,
            receiveTimeout: Duration.zero,
          ),
        );

    _reconnection.reset();
    var afterFailure = false;

    while (true) {
      if (_reconnection.state == StreamConnectionState.expired) {
        onStreamExpired?.call();
        return;
      }

      if (afterFailure) {
        final delay = _reconnection.nextDelay();
        if (delay == null) {
          return;
        }
        await Future.delayed(delay);
      }

      try {
        final response = await http.get<ResponseBody>(
          '/agents/$agentId/runs/$runId/stream',
          queryParameters:
              resumeId != null ? {'lastEventId': resumeId} : null,
          options: Options(
            headers: streamHeaders(lastEventId: resumeId),
            responseType: ResponseType.stream,
            validateStatus: (code) => code != null && code < 500,
          ),
        );

        if (response.statusCode == 410) {
          _reconnection.markStreamExpired();
          onStreamExpired?.call();
          return;
        }

        if (response.statusCode != 200 || response.data == null) {
          throw DioException(
            requestOptions: RequestOptions(path: '/stream'),
            response: Response(
              requestOptions: RequestOptions(path: '/stream'),
              statusCode: response.statusCode,
            ),
          );
        }

        _reconnection.markConnected();
        afterFailure = false;

        final raw = response.data!.stream
            .map((chunk) => utf8.decode(chunk, allowMalformed: true));

        await for (final event in parseRawStream(
          raw,
          agentId: agentId,
          runId: runId,
        )) {
          if (event.id != null) {
            resumeId = event.id;
          }
          yield event;
          if (event is DoneEvent || event is ErrorEvent) {
            return;
          }
        }

        _reconnection.markDisconnected();
        afterFailure = true;
      } on DioException catch (e) {
        final mapped = CursorHttpClient.mapDioException(e);
        if (mapped is CursorStreamExpiredError) {
          _reconnection.markStreamExpired();
          onStreamExpired?.call();
          return;
        }
        _reconnection.markDisconnected();
        afterFailure = true;
        if (_reconnection.attempt >= _reconnection.maxAttempts) {
          yield ErrorEvent(
            code: 'stream_error',
            message: mapped.toString(),
          );
          return;
        }
      }
    }
  }
}
