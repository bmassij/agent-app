class UsageModel {
  const UsageModel({required this.runs});

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    final items = json['runs'] as List<dynamic>? ?? [];
    return UsageModel(
      runs: items
          .whereType<Map<String, dynamic>>()
          .map(RunUsage.fromJson)
          .toList(),
    );
  }

  final List<RunUsage> runs;
}

class RunUsage {
  const RunUsage({
    required this.runId,
    this.inputTokens,
    this.outputTokens,
  });

  factory RunUsage.fromJson(Map<String, dynamic> json) {
    return RunUsage(
      runId: json['runId'] as String? ?? '',
      inputTokens: json['inputTokens'] as int?,
      outputTokens: json['outputTokens'] as int?,
    );
  }

  final String runId;
  final int? inputTokens;
  final int? outputTokens;
}
