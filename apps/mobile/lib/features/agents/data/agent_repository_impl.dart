import 'package:aivance_orchestrator/aivance_orchestrator.dart';

import 'package:aivance_provider_contract/aivance_provider_contract.dart';

import 'package:cursor_api_agents/cursor_api_agents.dart' as api;

import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';

import 'package:cursor_mobile_commander/features/agents/data/execution_failure_mapper.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_failure.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_repository.dart';

import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';

class AgentRepositoryImpl implements AgentRepository {
  AgentRepositoryImpl({
    required ExecutionProvider executionProvider,
    required AgentLocalSource localSource,
    AgentCommandOrchestrator? orchestrator,
  })  : _execution = executionProvider,
        _local = localSource,
        _orchestrator = orchestrator;

  final ExecutionProvider _execution;

  final AgentLocalSource _local;

  final AgentCommandOrchestrator? _orchestrator;

  @override
  Stream<List<AgentSession>> watchAgents() => _local.watchAgents();

  @override
  Future<List<AgentSession>> listAgentsLocal() => _local.listAgents();

  @override
  Future<Either<AgentFailure, Unit>> syncAgentsFromApi() async {
    final result = await _execution.listTasks();

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (page) async {
        for (final task in page.tasks) {
          final existing = await _local.getAgent(task.taskId);

          await _local.upsertAgent(
            agentId: task.taskId,
            projectId: existing?.projectId ?? 'default',
            name: task.name ?? existing?.name ?? 'Worker ${task.taskId}',
            status: task.status,
            latestRunId: task.latestRunId,
            createdAt: task.createdAt ?? existing?.createdAt,
            updatedAt: task.updatedAt ?? DateTime.now().toUtc(),
            tags: existing?.tags,
          );
        }

        return right(unit);
      },
    );
  }

  @override
  Future<Either<AgentFailure, AgentSession>> getAgent(String agentId) async {
    final local = await _local.getAgent(agentId);

    if (local != null) {
      return right(local);
    }

    final remote = await _execution.getTask(agentId);

    return remote.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (task) async {
        final session = AgentSession(
          agentId: task.taskId,
          projectId: 'default',
          name: task.name ?? 'Worker ${task.taskId}',
          status: task.status,
          latestRunId: task.latestRunId,
          createdAt: task.createdAt ?? DateTime.now().toUtc(),
          updatedAt: task.updatedAt ?? DateTime.now().toUtc(),
        );

        await _local.upsertAgent(
          agentId: session.agentId,
          projectId: session.projectId,
          name: session.name,
          status: session.status,
          latestRunId: session.latestRunId,
          createdAt: session.createdAt,
          updatedAt: session.updatedAt,
        );

        return right(session);
      },
    );
  }

  @override
  Future<Either<AgentFailure, api.CreateAgentResult>> createAgent({
    required String projectId,
    required String repoUrl,
    required String prompt,
    String? model,
    String? mode,
    bool? autoCreatePr,
    bool? workOnCurrentBranch,
    String? startingRef,
    String? prUrl,
    List<api.PromptImage>? images,
  }) async {
    if (_orchestrator != null) {
      final dispatched = await dispatchCommand(
        projectId: projectId,
        input: CommandInput(
          userPrompt: prompt,
          repoUrl: repoUrl,
          branch: startingRef,
          prUrl: prUrl,
          images: ExecutionFailureMapper.toTaskImages(images),
          modelId: model,
          mode: mode,
          autoCreatePr: autoCreatePr,
          workOnCurrentBranch: workOnCurrentBranch,
        ),
      );

      return dispatched.fold(
        left,
        (result) => right(
          api.CreateAgentResult(
            agentId: result.agentId,
            runId: result.runId,
            status: result.status,
          ),
        ),
      );
    }

    final result = await _execution.executeTask(
      ExecuteTaskRequest.singleRepo(
        repoUrl: repoUrl,
        prompt: prompt,
        startingRef: startingRef,
        prUrl: prUrl,
        images: ExecutionFailureMapper.toTaskImages(images),
        modelId: model,
        mode: mode,
        autoCreatePr: autoCreatePr,
        workOnCurrentBranch: workOnCurrentBranch,
      ),
    );

    return _persistCreate(
      projectId,
      prompt,
      result.fold(
        (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
        (created) => right(
          api.CreateAgentResult(
            agentId: created.taskId,
            runId: created.runId,
            status: created.status,
          ),
        ),
      ),
    );
  }

  @override
  Future<Either<AgentFailure, CommandDispatchResult>> dispatchCommand({
    required String projectId,
    required CommandInput input,
  }) async {
    final orchestrator = _orchestrator;

    if (orchestrator == null) {
      return left(const api.AgentUnknownFailure('Orchestrator not configured'));
    }

    final dispatched = await orchestrator.dispatch(input);

    return dispatched.fold(
      (msg) => left(api.AgentUnknownFailure(msg)),
      (result) async {
        final apiResult = api.CreateAgentResult(
          agentId: result.agentId,
          runId: result.runId,
          status: result.status,
        );

        await _persistCreate(projectId, input.userPrompt, right(apiResult));

        return right(result);
      },
    );
  }

  Future<Either<AgentFailure, api.CreateAgentResult>> _persistCreate(
    String projectId,
    String prompt,
    Either<AgentFailure, api.CreateAgentResult> result,
  ) async {
    return result.fold(
      left,
      (created) async {
        final now = DateTime.now().toUtc();

        final name =
            prompt.length > 48 ? '${prompt.substring(0, 48)}…' : prompt;

        await _local.upsertAgent(
          agentId: created.agentId,
          projectId: projectId,
          name: name,
          status: created.status ?? 'running',
          latestRunId: created.runId,
          createdAt: now,
          updatedAt: now,
        );

        await _local.upsertRun(
          runId: created.runId,
          agentId: created.agentId,
          status: created.status ?? 'running',
          createdAt: now,
        );

        return right(created);
      },
    );
  }

  @override
  Future<Either<AgentFailure, api.CreateRunResult>> createRun({
    required String agentId,
    required String prompt,
    String? mode,
    List<api.PromptImage>? images,
    String? repoUrl,
  }) async {
    final localAgent = await _local.getAgent(agentId);

    final resolvedRepo =
        repoUrl ?? _repoUrlFromProjectId(localAgent?.projectId);

    if (_orchestrator != null) {
      final input = CommandInput(
        userPrompt: prompt,
        repoUrl: resolvedRepo,
        mode: mode,
        images: ExecutionFailureMapper.toTaskImages(images),
        existingAgentId: agentId,
      );

      final dispatched = await _orchestrator.dispatch(input);

      return dispatched.fold(
        (msg) => left(api.AgentUnknownFailure(msg)),
        (result) async {
          final run = api.CreateRunResult(
            runId: result.runId,
            status: result.status ?? 'CREATING',
          );

          return _persistRun(agentId, run);
        },
      );
    }

    final result = await _execution.continueTask(
      ContinueTaskRequest(
        taskId: agentId,
        prompt: prompt,
        mode: mode,
        images: ExecutionFailureMapper.toTaskImages(images),
      ),
    );

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (run) => _persistRun(
        agentId,
        api.CreateRunResult(runId: run.runId, status: run.status ?? 'CREATING'),
      ),
    );
  }

  Future<Either<AgentFailure, api.CreateRunResult>> _persistRun(
    String agentId,
    api.CreateRunResult run,
  ) async {
    final now = DateTime.now().toUtc();

    await _local.upsertRun(
      runId: run.runId,
      agentId: agentId,
      status: run.status,
      createdAt: now,
    );

    await _local.upsertAgent(
      agentId: agentId,
      projectId: (await _local.getAgent(agentId))?.projectId ?? 'default',
      name: (await _local.getAgent(agentId))?.name ?? 'Worker',
      status: run.status,
      latestRunId: run.runId,
      updatedAt: now,
    );
    return right(run);
  }

  @override
  Future<Either<AgentFailure, Unit>> cancelRun({
    required String agentId,
    required String runId,
  }) async {
    final result = await _execution.cancelTask(agentId, runId);

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (_) async {
        await _local.upsertRun(
          runId: runId,
          agentId: agentId,
          status: 'cancelled',
          completedAt: DateTime.now().toUtc(),
        );

        final agent = await _local.getAgent(agentId);

        if (agent != null) {
          await _local.upsertAgent(
            agentId: agentId,
            projectId: agent.projectId,
            name: agent.name,
            status: 'cancelled',
            latestRunId: runId,
            updatedAt: DateTime.now().toUtc(),
          );
        }

        return right(unit);
      },
    );
  }

  @override
  Future<List<RunSummary>> listRunsLocal(String agentId) {
    return _local.listRunsForAgent(agentId);
  }

  @override
  Future<Either<AgentFailure, api.RunModel>> getRun({
    required String agentId,
    required String runId,
  }) async {
    final result = await _execution.getRun(agentId, runId);

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (run) async {
        await _local.upsertRun(
          runId: run.runId,
          agentId: agentId,
          status: run.status,
          resultText: run.resultText,
          createdAt: run.createdAt,
          completedAt: run.completedAt,
        );

        return right(
          api.RunModel(
            runId: run.runId,
            agentId: agentId,
            status: run.status,
            resultText: run.resultText,
            createdAt: run.createdAt,
            completedAt: run.completedAt,
          ),
        );
      },
    );
  }

  @override
  Future<Either<AgentFailure, api.ModelListPage>> listModels() async {
    final result = await _execution.listModels();

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (page) => right(
        api.ModelListPage(
          models: page.models
              .map((m) => api.ModelInfoModel(id: m.id, name: m.name))
              .toList(),
        ),
      ),
    );
  }

  @override
  Future<Either<AgentFailure, api.RepositoryListPage>>
      listRepositories() async {
    final result = await _execution.listRepositories();

    return result.fold(
      (f) => left(ExecutionFailureMapper.toAgentFailure(f)),
      (page) => right(
        api.RepositoryListPage(
          repositories: page.repositories
              .map(
                (repo) => api.RepositoryModel(
                  url: repo.url,
                  owner: repo.owner,
                  name: repo.name,
                  defaultBranch: repo.defaultBranch,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _repoUrlFromProjectId(String? projectId) {
    if (projectId == null || projectId.isEmpty || projectId == 'default') {
      return 'https://github.com/unknown/repo';
    }

    if (projectId.startsWith('http')) {
      return projectId;
    }

    return 'https://github.com/$projectId';
  }
}
