/// Provider-agnostic streaming events for task execution monitoring.
sealed class TaskStreamEvent {
  const TaskStreamEvent({this.id, this.eventType = ''});

  final String? id;
  final String eventType;
}

class AssistantDeltaStreamEvent extends TaskStreamEvent {
  const AssistantDeltaStreamEvent({
    required this.delta,
    super.id,
  }) : super(eventType: 'assistant');

  final String delta;
}

class ThinkingDeltaStreamEvent extends TaskStreamEvent {
  const ThinkingDeltaStreamEvent({
    required this.delta,
    super.id,
  }) : super(eventType: 'thinking');

  final String delta;
}

class ToolCallStreamEvent extends TaskStreamEvent {
  const ToolCallStreamEvent({
    required this.callId,
    required this.name,
    required this.status,
    this.args,
    this.result,
    this.truncated,
    super.id,
  }) : super(eventType: 'tool_call');

  final String callId;
  final String name;
  final String status;
  final Object? args;
  final Object? result;
  final Map<String, dynamic>? truncated;
}

class StatusStreamEvent extends TaskStreamEvent {
  const StatusStreamEvent({
    required this.status,
    this.runId,
    super.id,
  }) : super(eventType: 'status');

  final String status;
  final String? runId;
}

class InteractionUpdateStreamEvent extends TaskStreamEvent {
  const InteractionUpdateStreamEvent({
    required this.payload,
    super.id,
  }) : super(eventType: 'interaction_update');

  final Map<String, dynamic> payload;
}

class ResultStreamEvent extends TaskStreamEvent {
  const ResultStreamEvent({
    required this.text,
    this.runId,
    this.status,
    this.durationMs,
    this.git,
    super.id,
  }) : super(eventType: 'result');

  final String text;
  final String? runId;
  final String? status;
  final int? durationMs;
  final Map<String, dynamic>? git;
}

class HeartbeatStreamEvent extends TaskStreamEvent {
  const HeartbeatStreamEvent({super.id}) : super(eventType: 'heartbeat');
}

class DoneStreamEvent extends TaskStreamEvent {
  const DoneStreamEvent({super.id}) : super(eventType: 'done');
}

class ErrorStreamEvent extends TaskStreamEvent {
  const ErrorStreamEvent({
    required this.code,
    required this.message,
    super.id,
  }) : super(eventType: 'error');

  final String code;
  final String message;
}

class UnknownStreamEvent extends TaskStreamEvent {
  const UnknownStreamEvent({
    required this.rawEventType,
    required this.rawData,
    super.id,
  }) : super(eventType: 'unknown');

  final String rawEventType;
  final String rawData;
}
