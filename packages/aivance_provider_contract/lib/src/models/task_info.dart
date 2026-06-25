class TaskInfo {
  const TaskInfo({
    required this.taskId,
    this.name,
    this.status = 'unknown',
    this.latestRunId,
    this.createdAt,
    this.updatedAt,
  });

  final String taskId;
  final String? name;
  final String status;
  final String? latestRunId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class TaskListPage {
  const TaskListPage({
    required this.tasks,
    this.nextCursor,
  });

  final List<TaskInfo> tasks;
  final String? nextCursor;
}
