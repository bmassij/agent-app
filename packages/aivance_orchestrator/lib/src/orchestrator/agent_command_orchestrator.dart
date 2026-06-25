import 'package:aivance_orchestrator/src/builder/context_builder.dart';
import 'package:aivance_orchestrator/src/models/repo_context_bundle.dart';
import 'package:aivance_orchestrator/src/builder/prompt_builder.dart';
import 'package:aivance_orchestrator/src/conversation/conversation_manager.dart';
import 'package:aivance_orchestrator/src/models/command_models.dart';
import 'package:aivance_orchestrator/src/scanner/repository_scanner.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:fpdart/fpdart.dart';
import 'package:github_api/github_api.dart';

/// Central façade: context → prompt → Cursor API.
class AgentCommandOrchestrator {
  AgentCommandOrchestrator({
    required AgentRepository agents,
    GithubRepository? github,
    ContextBuilder? contextBuilder,
    PromptBuilder? promptBuilder,
    ConversationManager? conversationManager,
  })  : _agents = agents,
        _contextBuilder = contextBuilder ??
            ContextBuilder(scanner: RepositoryScanner(github: github)),
        _promptBuilder = promptBuilder ?? const PromptBuilder(),
        _conversation =
            conversationManager ?? ConversationManager(agents: agents);

  final AgentRepository _agents;
  final ContextBuilder _contextBuilder;
  final PromptBuilder _promptBuilder;
  final ConversationManager _conversation;

  ConversationManager get conversation => _conversation;

  Future<Either<String, CommandDispatchResult>> dispatch(
    CommandInput input,
  ) async {
    try {
      final prefs = _conversation.preferencesFor(input.repoUrl);
      final context = await _contextBuilder.build(input, prefs: prefs);
      final built = _promptBuilder.build(input, context);

      final followUpAgent = await _conversation.resolveAgentForFollowUp(input);
      if (followUpAgent != null) {
        return _sendFollowUp(
          agentId: followUpAgent,
          input: input,
          context: context,
          built: built,
        );
      }

      if (!input.forceNewAgent) {
        final reusable = await _conversation.findReusableAgent(
          prUrl: built.resolvedPrUrl,
          forceNew: input.forceNewAgent,
        );
        if (reusable != null) {
          return _sendFollowUp(
            agentId: reusable,
            input: input,
            context: context,
            built: built,
            reused: true,
          );
        }
      }

      final result = await _agents.createAgent(built.request);
      return result.fold(
        (f) => left(f.toString()),
        (created) {
          _conversation.recordDispatch(
            repoUrl: input.repoUrl,
            branch: built.resolvedBranch,
            prUrl: built.resolvedPrUrl,
            modelId: input.modelId,
            mode: built.resolvedMode,
            autoCreatePr: built.request.autoCreatePr,
          );
          return right(
            CommandDispatchResult(
              agentId: created.agentId,
              runId: created.runId,
              userPrompt: input.userPrompt,
              enrichedPrompt: built.enrichedPrompt,
              status: created.status,
              contextSummary: built.contextSummary,
            ),
          );
        },
      );
    } catch (e) {
      return left(e.toString());
    }
  }

  Future<Either<String, CommandDispatchResult>> _sendFollowUp({
    required String agentId,
    required CommandInput input,
    required RepoContextBundle context,
    required BuiltCommand built,
    bool reused = false,
  }) async {
    final runRequest = _promptBuilder.buildFollowUp(input, context);
    final result = await _agents.createRun(agentId, runRequest);
    return result.fold(
      (f) => left(f.toString()),
      (run) => right(
        CommandDispatchResult(
          agentId: agentId,
          runId: run.runId,
          userPrompt: input.userPrompt,
          enrichedPrompt: runRequest.prompt,
          status: run.status,
          reusedAgent: reused,
          contextSummary: built.contextSummary,
        ),
      ),
    );
  }

  Future<Either<String, List<ArtifactModel>>> fetchArtifacts(
    String agentId,
  ) async {
    final result = await _agents.listArtifacts(agentId);
    return result.fold(
      (f) => left(f.toString()),
      (page) => right(page.artifacts),
    );
  }

  Future<Either<String, String>> downloadArtifactUrl(
    String agentId,
    String path,
  ) async {
    final result = await _agents.downloadArtifact(agentId, path);
    return result.fold(
      (f) => left(f.toString()),
      (dl) => right(dl.url),
    );
  }
}
