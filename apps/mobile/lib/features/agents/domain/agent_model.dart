/// Local agent session combined with API metadata.
class AgentSession {
  const AgentSession({
    required this.agentId,
    required this.projectId,
    required this.name,
    required this.status,
    this.latestRunId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  final String agentId;
  final String projectId;
  final String name;
  final String status;
  final String? latestRunId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;

  bool get isActive {
    final s = status.toLowerCase();
    return s == 'running' || s == 'busy' || s == 'creating';
  }
}
