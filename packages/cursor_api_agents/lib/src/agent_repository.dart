import 'package:fpdart/fpdart.dart';

import 'package:cursor_api_agents/src/errors/agent_failure.dart';
import 'package:cursor_api_agents/src/models/agent_model.dart';
import 'package:cursor_api_agents/src/models/artifact_model.dart';
import 'package:cursor_api_agents/src/models/create_agent_request.dart';
import 'package:cursor_api_agents/src/models/create_run_request.dart';
import 'package:cursor_api_agents/src/models/model_info_model.dart';
import 'package:cursor_api_agents/src/models/repository_model.dart';
import 'package:cursor_api_agents/src/models/run_model.dart';
import 'package:cursor_api_agents/src/models/usage_model.dart';

/// Cursor agent and run operations (API_GUIDE.md).
abstract interface class AgentRepository {
  Future<Either<AgentFailure, AgentListPage>> listAgents({String? cursor});

  Future<Either<AgentFailure, AgentModel>> getAgent(String agentId);

  Future<Either<AgentFailure, CreateAgentResult>> createAgent(
    CreateAgentRequest request,
  );

  Future<Either<AgentFailure, ModelListPage>> listModels();

  Future<Either<AgentFailure, RepositoryListPage>> listRepositories();

  Future<Either<AgentFailure, RunListPage>> listRuns(
    String agentId, {
    String? cursor,
  });

  Future<Either<AgentFailure, RunModel>> getRun(String agentId, String runId);

  Future<Either<AgentFailure, CreateRunResult>> createRun(
    String agentId,
    CreateRunRequest request,
  );

  Future<Either<AgentFailure, Unit>> cancelRun(String agentId, String runId);

  Future<Either<AgentFailure, UsageModel>> getUsage(String agentId);

  Future<Either<AgentFailure, ArtifactListPage>> listArtifacts(String agentId);
}
