class TaskStreamRequest {
  const TaskStreamRequest({
    required this.taskId,
    required this.runId,
    this.lastEventId,
    this.onStreamExpired,
  });

  final String taskId;
  final String runId;
  final String? lastEventId;
  final void Function()? onStreamExpired;
}
