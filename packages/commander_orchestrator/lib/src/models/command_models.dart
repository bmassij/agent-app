import 'package:cursor_api_agents/cursor_api_agents.dart';

/// User command before orchestration.
class CommandInput {
  const CommandInput({
    required this.userPrompt,
    required this.repoUrl,
    this.branch,
    this.prUrl,
    this.prNumber,
    this.images,
    this.modelId,
    this.modelParams,
    this.mode,
    this.autoCreatePr,
    this.workOnCurrentBranch,
    this.cloudEnv,
    this.envVars,
    this.existingAgentId,
    this.forceNewAgent = false,
    this.locale = 'nl',
  });

  final String userPrompt;
  final String repoUrl;
  final String? branch;
  final String? prUrl;
  final int? prNumber;
  final List<PromptImage>? images;
  final String? modelId;
  final List<ModelParam>? modelParams;
  final String? mode;
  final bool? autoCreatePr;
  final bool? workOnCurrentBranch;
  final CloudEnvConfig? cloudEnv;
  final Map<String, String>? envVars;
  final String? existingAgentId;
  final bool forceNewAgent;
  final String locale;
}

/// Outcome of orchestrated dispatch.
class CommandDispatchResult {
  const CommandDispatchResult({
    required this.agentId,
    required this.runId,
    required this.userPrompt,
    required this.enrichedPrompt,
    this.status,
    this.reusedAgent = false,
    this.contextSummary,
  });

  final String agentId;
  final String runId;
  final String userPrompt;
  final String enrichedPrompt;
  final String? status;
  final bool reusedAgent;
  final String? contextSummary;
}
