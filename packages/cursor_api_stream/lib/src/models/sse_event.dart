// SSE event types aligned with live Cursor Cloud Agents API v1 (Sprint 4.1).

/// Base type for parsed SSE events from GET /v1/agents/{id}/runs/{runId}/stream.
sealed class SseEvent {
  const SseEvent({this.id, this.eventType = ''});

  final String? id;
  final String eventType;
}

String _textOrDelta(Map<String, dynamic> json) =>
    json['text'] as String? ?? json['delta'] as String? ?? '';

class AssistantDeltaEvent extends SseEvent {
  const AssistantDeltaEvent({
    required this.delta,
    super.id,
  }) : super(eventType: 'assistant');

  factory AssistantDeltaEvent.fromData(Map<String, dynamic> json,
      {String? id}) {
    return AssistantDeltaEvent(
      delta: _textOrDelta(json),
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
      delta: _textOrDelta(json),
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
    this.truncated,
    super.id,
  }) : super(eventType: 'tool_call');

  factory ToolCallEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ToolCallEvent(
      callId: json['callId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      args: json['args'],
      result: json['result'],
      truncated: json['truncated'] as Map<String, dynamic>?,
      id: id,
    );
  }

  final String callId;
  final String name;
  final String status;
  final Object? args;
  final Object? result;
  final Map<String, dynamic>? truncated;
}

class StatusEvent extends SseEvent {
  const StatusEvent({
    required this.status,
    this.runId,
    super.id,
  }) : super(eventType: 'status');

  factory StatusEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return StatusEvent(
      status: json['status'] as String? ?? '',
      runId: json['runId'] as String?,
      id: id,
    );
  }

  final String status;
  final String? runId;
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
    this.runId,
    this.status,
    this.durationMs,
    this.git,
    super.id,
  }) : super(eventType: 'result');

  factory ResultEvent.fromData(Map<String, dynamic> json, {String? id}) {
    return ResultEvent(
      text: json['text'] as String? ?? '',
      runId: json['runId'] as String?,
      status: json['status'] as String?,
      durationMs: json['durationMs'] as int?,
      git: json['git'] as Map<String, dynamic>?,
      id: id,
    );
  }

  final String text;
  final String? runId;
  final String? status;
  final int? durationMs;
  final Map<String, dynamic>? git;
}

class HeartbeatEvent extends SseEvent {
  const HeartbeatEvent({super.id}) : super(eventType: 'heartbeat');
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
