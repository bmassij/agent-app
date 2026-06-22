export 'package:cursor_api_agents/cursor_api_agents.dart'
    show RunModel, RunListPage, CreateRunResult;

/// Local run record for UI and tasks grouping.
class RunSummary {
  const RunSummary({
    required this.runId,
    required this.agentId,
    required this.status,
    this.resultText,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  final String runId;
  final String agentId;
  final String status;
  final String? resultText;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage;

  bool get isRunning {
    final s = status.toLowerCase();
    return s == 'running' || s == 'creating' || s == 'pending';
  }

  bool get isFailed {
    final s = status.toLowerCase();
    return s == 'error' || s == 'failed' || s == 'cancelled';
  }

  bool get isCompleted {
    final s = status.toLowerCase();
    return s == 'finished' || s == 'completed' || s == 'done';
  }
}
