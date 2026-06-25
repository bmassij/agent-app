import 'package:cursor_api_agents/src/models/agent_repo_config.dart';
import 'package:cursor_api_agents/src/models/cloud_env_config.dart';
import 'package:cursor_api_agents/src/models/model_param.dart';
import 'package:cursor_api_agents/src/models/prompt_image.dart';

class CreateAgentRequest {
  const CreateAgentRequest({
    required this.repos,
    required this.prompt,
    this.images,
    this.name,
    this.env,
    this.envVars,
    this.modelId,
    this.modelParams,
    this.mode,
    this.autoCreatePr,
    this.workOnCurrentBranch,
    this.skipReviewerRequest,
    this.mcpServers,
    this.agentId,
  });

  /// Convenience constructor for a single-repo agent.
  factory CreateAgentRequest.singleRepo({
    required String repoUrl,
    required String prompt,
    String? startingRef,
    String? prUrl,
    List<PromptImage>? images,
    String? name,
    CloudEnvConfig? env,
    Map<String, String>? envVars,
    String? modelId,
    List<ModelParam>? modelParams,
    String? mode,
    bool? autoCreatePr,
    bool? workOnCurrentBranch,
    bool? skipReviewerRequest,
    List<Map<String, dynamic>>? mcpServers,
    String? agentId,
  }) {
    return CreateAgentRequest(
      repos: [
        AgentRepoConfig(
          url: repoUrl,
          startingRef: startingRef,
          prUrl: prUrl,
        ),
      ],
      prompt: prompt,
      images: images,
      name: name,
      env: env,
      envVars: envVars,
      modelId: modelId,
      modelParams: modelParams,
      mode: mode,
      autoCreatePr: autoCreatePr,
      workOnCurrentBranch: workOnCurrentBranch,
      skipReviewerRequest: skipReviewerRequest,
      mcpServers: mcpServers,
      agentId: agentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prompt': {
        'text': prompt,
        if (images != null && images!.isNotEmpty)
          'images': images!.map((i) => i.toJson()).toList(),
      },
      if (repos.isNotEmpty) 'repos': repos.map((r) => r.toJson()).toList(),
      if (env != null) 'env': env!.toJson(),
      if (envVars != null && envVars!.isNotEmpty) 'envVars': envVars,
      if (modelId != null)
        'model': {
          'id': modelId,
          if (modelParams != null && modelParams!.isNotEmpty)
            'params': modelParams!.map((p) => p.toJson()).toList(),
        },
      if (name != null) 'name': name,
      if (mode != null) 'mode': mode,
      if (autoCreatePr != null) 'autoCreatePR': autoCreatePr,
      if (workOnCurrentBranch != null)
        'workOnCurrentBranch': workOnCurrentBranch,
      if (skipReviewerRequest != null)
        'skipReviewerRequest': skipReviewerRequest,
      if (mcpServers != null && mcpServers!.isNotEmpty)
        'mcpServers': mcpServers,
      if (agentId != null) 'agentId': agentId,
    };
  }

  final List<AgentRepoConfig> repos;
  final String prompt;
  final List<PromptImage>? images;
  final String? name;
  final CloudEnvConfig? env;
  final Map<String, String>? envVars;
  final String? modelId;
  final List<ModelParam>? modelParams;
  final String? mode;
  final bool? autoCreatePr;
  final bool? workOnCurrentBranch;
  final bool? skipReviewerRequest;
  final List<Map<String, dynamic>>? mcpServers;
  final String? agentId;
}

class CreateAgentResult {
  const CreateAgentResult({
    required this.agentId,
    required this.runId,
    this.status,
  });

  factory CreateAgentResult.fromJson(Map<String, dynamic> json) {
    final agent = json['agent'] as Map<String, dynamic>?;
    final run = json['run'] as Map<String, dynamic>?;

    return CreateAgentResult(
      agentId: json['agentId'] as String? ?? agent?['id'] as String? ?? '',
      runId: json['runId'] as String? ?? run?['id'] as String? ?? '',
      status: json['status'] as String? ??
          run?['status'] as String? ??
          agent?['status'] as String?,
    );
  }

  final String agentId;
  final String runId;
  final String? status;
}
