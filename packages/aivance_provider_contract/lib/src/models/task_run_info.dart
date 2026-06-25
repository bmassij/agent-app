class TaskRunInfo {
  const TaskRunInfo({
    required this.runId,
    required this.taskId,
    required this.status,
    this.resultText,
    this.createdAt,
    this.completedAt,
  });

  final String runId;
  final String taskId;
  final String status;
  final String? resultText;
  final DateTime? createdAt;
  final DateTime? completedAt;
}

class TaskRunListPage {
  const TaskRunListPage({
    required this.runs,
    this.nextCursor,
  });

  final List<TaskRunInfo> runs;
  final String? nextCursor;
}
