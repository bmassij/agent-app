import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/agents/data/agent_local_source.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_failure.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';
import 'package:cursor_mobile_commander/features/agents/domain/agent_repository.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';

class AgentRepositoryImpl implements AgentRepository {
  AgentRepositoryImpl({
    required api.AgentRepository apiRepository,
    required AgentLocalSource localSource,
  })  : _api = apiRepository,
        _local = localSource;

  final api.AgentRepository _api;
  final AgentLocalSource _local;

  @override
  Stream<List<AgentSession>> watchAgents() => _local.watchAgents();

  @override
  Future<List<AgentSession>> listAgentsLocal() => _local.listAgents();

  @override
  Future<Either<AgentFailure, Unit>> syncAgentsFromApi() async {
    final result = await _api.listAgents();
    return result.fold(
      left,
      (page) async {
        for (final agent in page.agents) {
          final existing = await _local.getAgent(agent.agentId);
          await _local.upsertAgent(
            agentId: agent.agentId,
            projectId: existing?.projectId ?? 'default',
            name: agent.name ?? existing?.name ?? 'Agent ${agent.agentId}',
            status: agent.status,
            latestRunId: agent.latestRunId,
            createdAt: agent.createdAt ?? existing?.createdAt,
            updatedAt: agent.updatedAt ?? DateTime.now().toUtc(),
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
    final remote = await _api.getAgent(agentId);
    return remote.fold(
      left,
      (agent) async {
        final session = AgentSession(
          agentId: agent.agentId,
          projectId: 'default',
          name: agent.name ?? 'Agent ${agent.agentId}',
          status: agent.status,
          latestRunId: agent.latestRunId,
          createdAt: agent.createdAt ?? DateTime.now().toUtc(),
          updatedAt: agent.updatedAt ?? DateTime.now().toUtc(),
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
  }) async {
    final result = await _api.createAgent(
      api.CreateAgentRequest(
        repos: [repoUrl],
        messages: [api.AgentMessage(role: 'user', content: prompt)],
        model: model,
        mode: mode,
        autoCreatePr: autoCreatePr,
        workOnCurrentBranch: workOnCurrentBranch,
      ),
    );

    return result.fold(
      left,
      (created) async {
        final now = DateTime.now().toUtc();
        final name = prompt.length > 48 ? '${prompt.substring(0, 48)}…' : prompt;
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
  }) async {
    final result = await _api.createRun(
      agentId,
      api.CreateRunRequest(
        messages: [api.RunMessage(role: 'user', content: prompt)],
      ),
    );

    return result.fold(
      left,
      (run) async {
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
          name: (await _local.getAgent(agentId))?.name ?? 'Agent',
          status: run.status,
          latestRunId: run.runId,
          updatedAt: now,
        );
        return right(run);
      },
    );
  }

  @override
  Future<Either<AgentFailure, Unit>> cancelRun({
    required String agentId,
    required String runId,
  }) async {
    final result = await _api.cancelRun(agentId, runId);
    return result.fold(
      left,
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
    final result = await _api.getRun(agentId, runId);
    return result.fold(
      left,
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
  Future<Either<AgentFailure, api.ModelListPage>> listModels() {
    return _api.listModels();
  }
}
