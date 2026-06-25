import 'package:aivance_provider_contract/src/models/task_image.dart';

/// Provider-agnostic follow-up on an existing task session.
class ContinueTaskRequest {
  const ContinueTaskRequest({
    required this.taskId,
    required this.prompt,
    this.images,
    this.mode,
    this.mcpServers,
  });

  final String taskId;
  final String prompt;
  final List<TaskImage>? images;
  final String? mode;
  final List<Map<String, dynamic>>? mcpServers;
}

class ContinueTaskResult {
  const ContinueTaskResult({
    required this.taskId,
    required this.runId,
    this.status,
  });

  final String taskId;
  final String runId;
  final String? status;
}
