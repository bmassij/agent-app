import 'package:aivance_orchestrator/aivance_orchestrator.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:cursor_execution_provider/cursor_execution_provider.dart';
import 'package:github_api/github_api.dart';

/// Facade over execution provider + orchestrator for desktop.
class CursorSession {
  CursorSession({
    required this.apiKey,
    String? githubToken,
  })  : client = CursorHttpClient(apiKey: apiKey),
        execution = CursorExecutionProvider(
          agents: AgentRepositoryImpl(CursorHttpClient(apiKey: apiKey)),
          streamService: RunStreamService(apiKey: apiKey),
        ),
        orchestrator = AgentCommandOrchestrator(
          execution: CursorExecutionProvider(
            agents: AgentRepositoryImpl(CursorHttpClient(apiKey: apiKey)),
            streamService: RunStreamService(apiKey: apiKey),
          ),
          github: githubToken != null && githubToken.isNotEmpty
              ? GithubRepositoryImpl(
                  GithubHttpClient(accessToken: githubToken),
                )
              : null,
        );

  final String apiKey;
  final CursorHttpClient client;
  final CursorExecutionProvider execution;
  final AgentCommandOrchestrator orchestrator;

  Future<CursorMeModel> validate() => client.fetchMe();

  Future<List<String>> listRepoUrls() async {
    final result = await execution.listRepositories();
    return result.fold(
      (_) => <String>[],
      (page) => page.repositories
          .map((r) => RepoUrlUtils.normalize(r.url))
          .where((u) => u.isNotEmpty)
          .toList(),
    );
  }

  Future<List<TaskInfo>> listAgents() async {
    final result = await execution.listTasks();
    return result.fold((_) => <TaskInfo>[], (page) => page.tasks);
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
    List<TaskImage>? images,
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

  Stream<TaskStreamEvent> watchRun({
    required String agentId,
    required String runId,
  }) {
    return execution.streamTask(
      TaskStreamRequest(taskId: agentId, runId: runId),
    );
  }

  Future<List<TaskArtifactDownload>> listArtifacts(String agentId) async {
    final result = await orchestrator.fetchArtifacts(agentId);
    return result.fold((msg) => throw Exception(msg), (a) => a);
  }
}
