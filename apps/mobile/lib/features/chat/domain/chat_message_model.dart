/// Chat message for UI timeline.
class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.runId,
    required this.role,
    required this.content,
    required this.eventType,
    required this.sequenceIndex,
    required this.timestamp,
  });

  final String id;
  final String runId;
  final String role;
  final String content;
  final String eventType;
  final int sequenceIndex;
  final DateTime timestamp;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isThinking => role == 'thinking';
  bool get isMilestone =>
      role == 'status' || role == 'interaction_update' || role == 'milestone';
}
