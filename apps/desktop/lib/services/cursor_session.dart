import 'package:commander_orchestrator/commander_orchestrator.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:github_api/github_api.dart';

/// Facade over Cursor API + command orchestrator for desktop.
class CursorSession {
  CursorSession({
    required this.apiKey,
    String? githubToken,
  })  : client = CursorHttpClient(apiKey: apiKey),
        agents = AgentRepositoryImpl(CursorHttpClient(apiKey: apiKey)),
        stream = RunStreamService(apiKey: apiKey),
        orchestrator = AgentCommandOrchestrator(
          agents: AgentRepositoryImpl(CursorHttpClient(apiKey: apiKey)),
          github: githubToken != null && githubToken.isNotEmpty
              ? GithubRepositoryImpl(
                  GithubHttpClient(accessToken: githubToken),
                )
              : null,
        );

  final String apiKey;
  final CursorHttpClient client;
  final AgentRepositoryImpl agents;
  final RunStreamService stream;
  final AgentCommandOrchestrator orchestrator;

  Future<CursorMeModel> validate() => client.fetchMe();

  Future<List<String>> listRepoUrls() async {
    final result = await agents.listRepositories();
    return result.fold(
      (_) => <String>[],
      (page) => page.repositories
          .map((r) => RepositoryModel.normalizeRepoUrl(r.url))
          .where((u) => u.isNotEmpty)
          .toList(),
    );
  }

  Future<List<AgentModel>> listAgents() async {
    final result = await agents.listAgents();
    return result.fold((_) => <AgentModel>[], (page) => page.agents);
  }

  Future<CommandDispatchResult> dispatchCommand(CommandInput input) async {
    final result = await orchestrator.dispatch(input);
    return result.fold(
      (msg) => throw Exception(msg),
      (r) => r,
    );
  }

  Future<CommandDispatchResult> sendFollowUp({
    required String agentId,
    required String prompt,
    required String repoUrl,
    List<PromptImage>? images,
    String? mode,
  }) async {
    return dispatchCommand(
      CommandInput(
        userPrompt: prompt,
        repoUrl: repoUrl,
        images: images,
        mode: mode,
        existingAgentId: agentId,
      ),
    );
  }

  Stream<SseEvent> watchRun({
    required String agentId,
    required String runId,
  }) {
    return stream.connectRun(agentId: agentId, runId: runId);
  }

  Future<List<ArtifactModel>> listArtifacts(String agentId) async {
    final result = await orchestrator.fetchArtifacts(agentId);
    return result.fold((msg) => throw Exception(msg), (a) => a);
  }
}
