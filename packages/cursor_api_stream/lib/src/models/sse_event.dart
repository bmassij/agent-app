// SSE event types per docs/API_GUIDE.md.
// AGENT_NOTE: Verify event names against raw SSE from live Cursor API before Sprint 4.
// Logged samples should be attached in SPRINT3_COMPLETION_REPORT.md when available.

/// Base type for parsed SSE events from GET /v1/agents/{id}/runs/{runId}/stream.
sealed class SseEvent {
  const SseEvent({this.id, this.eventType = ''});

  final String? id;
  final String eventType;
}

class AssistantDeltaEvent extends SseEvent {
  const AssistantDeltaEvent({
    required this.delta,
    super.id,
  }) : super(eventType: 'assistant');

  factory AssistantDeltaEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return AssistantDeltaEvent(
      delta: json['delta'] as String? ?? '',
      id: id,
    );
  }

  final String delta;
}

class ThinkingDeltaEvent extends SseEvent {
  const ThinkingDeltaEvent({
    required this.delta,
    super.id,
  }) : super(eventType: 'thinking');

  factory ThinkingDeltaEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ThinkingDeltaEvent(
      delta: json['delta'] as String? ?? '',
      id: id,
    );
  }

  final String delta;
}

class ToolCallEvent extends SseEvent {
  const ToolCallEvent({
    required this.callId,
    required this.name,
    required this.status,
    this.args,
    this.result,
    super.id,
  }) : super(eventType: 'tool_call');

  factory ToolCallEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ToolCallEvent(
      callId: json['callId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      args: json['args'],
      result: json['result'],
      id: id,
    );
  }

  final String callId;
  final String name;
  final String status;
  final Object? args;
  final Object? result;
}

class StatusEvent extends SseEvent {
  const StatusEvent({
    required this.status,
    super.id,
  }) : super(eventType: 'status');

  factory StatusEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return StatusEvent(
      status: json['status'] as String? ?? '',
      id: id,
    );
  }

  final String status;
}

class InteractionUpdateEvent extends SseEvent {
  const InteractionUpdateEvent({
    required this.payload,
    super.id,
  }) : super(eventType: 'interaction_update');

  factory InteractionUpdateEvent.fromData(
    Map<String, dynamic> json, {
    String? id,
  }) {
    return InteractionUpdateEvent(payload: json, id: id);
  }

  final Map<String, dynamic> payload;
}

class ResultEvent extends SseEvent {
  const ResultEvent({
    required this.text,
    super.id,
  }) : super(eventType: 'result');

  factory ResultEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ResultEvent(
      text: json['text'] as String? ?? '',
      id: id,
    );
  }

  final String text;
}

class DoneEvent extends SseEvent {
  const DoneEvent({super.id}) : super(eventType: 'done');
}

class ErrorEvent extends SseEvent {
  const ErrorEvent({
    required this.code,
    required this.message,
    super.id,
  }) : super(eventType: 'error');

  factory ErrorEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ErrorEvent(
      code: json['code'] as String? ?? 'error',
      message: json['message'] as String? ?? '',
      id: id,
    );
  }

  final String code;
  final String message;
}

class UnknownSseEvent extends SseEvent {
  const UnknownSseEvent({
    required this.rawEventType,
    required this.rawData,
    super.id,
  }) : super(eventType: 'unknown');

  final String rawEventType;
  final String rawData;
}
