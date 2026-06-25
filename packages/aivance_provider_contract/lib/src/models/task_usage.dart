class TaskUsageRun {
  const TaskUsageRun({
    required this.runId,
    this.inputTokens,
    this.outputTokens,
  });

  final String runId;
  final int? inputTokens;
  final int? outputTokens;
}

class TaskUsage {
  const TaskUsage({required this.runs});

  final List<TaskUsageRun> runs;
}
