import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/agents/domain/agent_model.dart';
import 'package:cursor_mobile_commander/features/agents/domain/run_model.dart';

/// Agent operations with local SQLite persistence.
abstract interface class AgentRepository {
  Stream<List<AgentSession>> watchAgents();

  Future<List<AgentSession>> listAgentsLocal();

  Future<Either<AgentFailure, Unit>> syncAgentsFromApi();

  Future<Either<AgentFailure, AgentSession>> getAgent(String agentId);

  Future<Either<AgentFailure, CreateAgentResult>> createAgent({
    required String projectId,
    required String repoUrl,
    required String prompt,
    String? model,
    String? mode,
    bool? autoCreatePr,
    bool? workOnCurrentBranch,
  });

  Future<Either<AgentFailure, CreateRunResult>> createRun({
    required String agentId,
    required String prompt,
  });

  Future<Either<AgentFailure, Unit>> cancelRun({
    required String agentId,
    required String runId,
  });

  Future<List<RunSummary>> listRunsLocal(String agentId);

  Future<Either<AgentFailure, RunModel>> getRun({
    required String agentId,
    required String runId,
  });

  Future<Either<AgentFailure, ModelListPage>> listModels();
}
