import 'package:aivance_orchestrator/src/models/command_models.dart';
import 'package:aivance_orchestrator/src/models/repo_context_bundle.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart';

/// Decides whether to reuse agents and tracks preferences.
class ConversationManager {
  ConversationManager({AgentRepository? agents}) : _agents = agents;

  final AgentRepository? _agents;
  final Map<String, UserRepoPreferences> _prefs = {};

  UserRepoPreferences preferencesFor(String repoUrl) =>
      _prefs[repoUrl] ?? const UserRepoPreferences();

  void recordDispatch({
    required String repoUrl,
    required String branch,
    String? prUrl,
    String? modelId,
    String? mode,
    bool? autoCreatePr,
  }) {
    final existing = preferencesFor(repoUrl);
    _prefs[repoUrl] = UserRepoPreferences(
      lastBranch: branch,
      lastPrUrl: prUrl ?? existing.lastPrUrl,
      preferredModelId: modelId ?? existing.preferredModelId,
      preferPlanMode: mode == 'plan' || existing.preferPlanMode,
      autoCreatePr: autoCreatePr ?? existing.autoCreatePr,
      cloudEnvName: existing.cloudEnvName,
    );
  }

  /// Returns an active agent id for follow-up when appropriate.
  Future<String?> resolveAgentForFollowUp(CommandInput input) async {
    if (input.existingAgentId != null) {
      return input.existingAgentId;
    }
    return null;
  }

  /// Finds an existing agent for the same PR when not forcing new.
  Future<String?> findReusableAgent({
    required String? prUrl,
    bool forceNew = false,
  }) async {
    if (forceNew || prUrl == null || _agents == null) {
      return null;
    }
    final result =
        await _agents.listAgents(prUrl: prUrl, includeArchived: false);
    return result.fold((_) => null, (page) {
      final active = page.agents.where((a) {
        final status = a.status.toUpperCase();
        return status == 'ACTIVE' || status == 'RUNNING';
      });
      return active.isNotEmpty ? active.first.agentId : null;
    });
  }
}
