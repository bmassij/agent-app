import 'package:aivance_orchestrator/src/builder/context_builder.dart';
import 'package:aivance_orchestrator/src/models/repo_context_bundle.dart';
import 'package:aivance_orchestrator/src/builder/prompt_builder.dart';
import 'package:aivance_orchestrator/src/conversation/conversation_manager.dart';
import 'package:aivance_orchestrator/src/models/command_models.dart';
import 'package:aivance_orchestrator/src/scanner/repository_scanner.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:github_api/github_api.dart';

/// Central façade: context → prompt → execution provider dispatch.
class AgentCommandOrchestrator {
  AgentCommandOrchestrator({
    required ExecutionProvider execution,
    GithubRepository? github,
    ContextBuilder? contextBuilder,
    PromptBuilder? promptBuilder,
    ConversationManager? conversationManager,
  })  : _execution = execution,
        _contextBuilder = contextBuilder ??
            ContextBuilder(scanner: RepositoryScanner(github: github)),
        _promptBuilder = promptBuilder ?? const PromptBuilder(),
        _conversation =
            conversationManager ?? ConversationManager(execution: execution);

  final ExecutionProvider _execution;
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

      final result = await _execution.executeTask(built.request);
      return result.fold(
        (f) => left(f.message),
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
              agentId: created.taskId,
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
    final followUp = _promptBuilder.buildFollowUp(
      CommandInput(
        userPrompt: input.userPrompt,
        repoUrl: input.repoUrl,
        branch: input.branch,
        prUrl: input.prUrl,
        images: input.images,
        mode: input.mode,
        existingAgentId: agentId,
        locale: input.locale,
      ),
      context,
    );
    final runRequest = ContinueTaskRequest(
      taskId: agentId,
      prompt: followUp.prompt,
      images: followUp.images,
      mode: followUp.mode,
    );
    final result = await _execution.continueTask(runRequest);
    return result.fold(
      (f) => left(f.message),
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

  Future<Either<String, List<TaskArtifactDownload>>> fetchArtifacts(
    String agentId,
  ) async {
    final result = await _execution.downloadArtifacts(agentId);
    return result.fold((f) => left(f.message), right);
  }

  Future<Either<String, String>> downloadArtifactUrl(
    String agentId,
    String path,
  ) async {
    final result = await _execution.downloadArtifacts(agentId);
    return result.fold(
      (f) => left(f.message),
      (artifacts) {
        final match = artifacts.where((a) => a.path == path).firstOrNull;
        if (match == null) {
          return left('Artifact not found: $path');
        }
        return right(match.url);
      },
    );
  }
}
