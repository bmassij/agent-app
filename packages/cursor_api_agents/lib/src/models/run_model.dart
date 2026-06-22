class RunModel {
  const RunModel({
    required this.runId,
    required this.agentId,
    required this.status,
    this.resultText,
    this.createdAt,
    this.completedAt,
  });

  factory RunModel.fromJson(Map<String, dynamic> json) {
    return RunModel(
      runId: json['runId'] as String? ?? json['id'] as String? ?? '',
      agentId: json['agentId'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      resultText: json['resultText'] as String? ?? json['result'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }

  final String runId;
  final String agentId;
  final String status;
  final String? resultText;
  final DateTime? createdAt;
  final DateTime? completedAt;
}

class RunListPage {
  const RunListPage({
    required this.runs,
    this.nextCursor,
  });

  factory RunListPage.fromJson(Map<String, dynamic> json) {
    final items =
        json['runs'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return RunListPage(
      runs: items
          .whereType<Map<String, dynamic>>()
          .map(RunModel.fromJson)
          .toList(),
      nextCursor: json['nextCursor'] as String? ?? json['cursor'] as String?,
    );
  }

  final List<RunModel> runs;
  final String? nextCursor;
}

class CreateRunResult {
  const CreateRunResult({
    required this.runId,
    required this.status,
  });

  factory CreateRunResult.fromJson(Map<String, dynamic> json) {
    return CreateRunResult(
      runId: json['runId'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'creating',
    );
  }

  final String runId;
  final String status;
}
