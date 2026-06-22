class AgentModel {
  const AgentModel({
    required this.agentId,
    required this.status,
    this.name,
    this.latestRunId,
    this.createdAt,
    this.updatedAt,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      agentId: json['agentId'] as String? ?? json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      name: json['name'] as String?,
      latestRunId: json['latestRunId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  final String agentId;
  final String status;
  final String? name;
  final String? latestRunId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

class AgentListPage {
  const AgentListPage({
    required this.agents,
    this.nextCursor,
  });

  factory AgentListPage.fromJson(Map<String, dynamic> json) {
    final items = json['agents'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return AgentListPage(
      agents: items
          .whereType<Map<String, dynamic>>()
          .map(AgentModel.fromJson)
          .toList(),
      nextCursor: json['nextCursor'] as String? ?? json['cursor'] as String?,
    );
  }

  final List<AgentModel> agents;
  final String? nextCursor;
}
