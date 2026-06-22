class CreateAgentRequest {
  const CreateAgentRequest({
    required this.repos,
    required this.messages,
    this.model,
    this.mode,
    this.autoCreatePr,
    this.workOnCurrentBranch,
  });

  Map<String, dynamic> toJson() {
    return {
      'repos': repos.map((r) => {'url': r}).toList(),
      'messages': messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
      if (model != null) 'model': model,
      if (mode != null) 'mode': mode,
      'options': {
        if (autoCreatePr != null) 'autoCreatePr': autoCreatePr,
        if (workOnCurrentBranch != null)
          'workOnCurrentBranch': workOnCurrentBranch,
      },
    };
  }

  final List<String> repos;
  final List<AgentMessage> messages;
  final String? model;
  final String? mode;
  final bool? autoCreatePr;
  final bool? workOnCurrentBranch;
}

class AgentMessage {
  const AgentMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class CreateAgentResult {
  const CreateAgentResult({
    required this.agentId,
    required this.runId,
    this.status,
  });

  factory CreateAgentResult.fromJson(Map<String, dynamic> json) {
    return CreateAgentResult(
      agentId: json['agentId'] as String? ?? '',
      runId: json['runId'] as String? ?? '',
      status: json['status'] as String?,
    );
  }

  final String agentId;
  final String runId;
  final String? status;
}
