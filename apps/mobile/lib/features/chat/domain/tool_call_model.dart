/// Tool call row for chat UI.
class ToolCallModel {
  const ToolCallModel({
    required this.callId,
    required this.runId,
    required this.toolName,
    required this.status,
    required this.argsJson,
    this.resultJson,
    required this.startedAt,
    this.completedAt,
  });

  final String callId;
  final String runId;
  final String toolName;
  final String status;
  final String argsJson;
  final String? resultJson;
  final DateTime startedAt;
  final DateTime? completedAt;
}
