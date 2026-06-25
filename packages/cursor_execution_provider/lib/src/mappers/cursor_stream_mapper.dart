import 'package:cursor_api_stream/cursor_api_stream.dart';

import 'package:aivance_provider_contract/aivance_provider_contract.dart';

abstract final class CursorStreamMapper {
  static TaskStreamEvent toTaskStreamEvent(SseEvent event) {
    return switch (event) {
      AssistantDeltaEvent(:final delta) => AssistantDeltaStreamEvent(
          delta: delta,
          id: event.id,
        ),
      ThinkingDeltaEvent(:final delta) => ThinkingDeltaStreamEvent(
          delta: delta,
          id: event.id,
        ),
      ToolCallEvent(
        :final callId,
        :final name,
        :final status,
        :final args,
        :final result,
        :final truncated,
      ) =>
        ToolCallStreamEvent(
          callId: callId,
          name: name,
          status: status,
          args: args,
          result: result,
          truncated: truncated,
          id: event.id,
        ),
      StatusEvent(:final status, :final runId) => StatusStreamEvent(
          status: status,
          runId: runId,
          id: event.id,
        ),
      InteractionUpdateEvent(:final payload) => InteractionUpdateStreamEvent(
          payload: payload,
          id: event.id,
        ),
      ResultEvent(
        :final text,
        :final runId,
        :final status,
        :final durationMs,
        :final git,
      ) =>
        ResultStreamEvent(
          text: text,
          runId: runId,
          status: status,
          durationMs: durationMs,
          git: git,
          id: event.id,
        ),
      HeartbeatEvent() => HeartbeatStreamEvent(id: event.id),
      DoneEvent() => DoneStreamEvent(id: event.id),
      ErrorEvent(:final code, :final message) => ErrorStreamEvent(
          code: code,
          message: message,
          id: event.id,
        ),
      UnknownSseEvent(:final rawEventType, :final rawData) =>
        UnknownStreamEvent(
          rawEventType: rawEventType,
          rawData: rawData,
          id: event.id,
        ),
    };
  }
}
