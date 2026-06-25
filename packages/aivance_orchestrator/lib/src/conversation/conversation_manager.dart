import 'package:aivance_orchestrator/src/models/command_models.dart';
import 'package:aivance_orchestrator/src/models/repo_context_bundle.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';

/// Decides whether to reuse agents and tracks preferences.
class ConversationManager {
  ConversationManager({ExecutionProvider? execution}) : _execution = execution;

  final ExecutionProvider? _execution;
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
    if (forceNew || prUrl == null || _execution == null) {
      return null;
    }
    final result = await _execution.listTasks(
      prUrl: prUrl,
      includeArchived: false,
    );
    return result.fold((_) => null, (page) {
      final active = page.tasks.where((task) {
        final status = task.status.toUpperCase();
        return status == 'ACTIVE' || status == 'RUNNING';
      });
      return active.isNotEmpty ? active.first.taskId : null;
    });
  }
}
