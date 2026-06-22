import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_api_agents/src/agent_repository.dart';
import 'package:cursor_api_agents/src/errors/agent_failure.dart';
import 'package:cursor_api_agents/src/models/agent_model.dart';
import 'package:cursor_api_agents/src/models/artifact_model.dart';
import 'package:cursor_api_agents/src/models/create_agent_request.dart';
import 'package:cursor_api_agents/src/models/create_run_request.dart';
import 'package:cursor_api_agents/src/models/model_info_model.dart';
import 'package:cursor_api_agents/src/models/repository_model.dart';
import 'package:cursor_api_agents/src/models/run_model.dart';
import 'package:cursor_api_agents/src/models/usage_model.dart';

class AgentRepositoryImpl implements AgentRepository {
  AgentRepositoryImpl(this._client);

  final CursorHttpClient _client;

  @override
  Future<Either<AgentFailure, AgentListPage>> listAgents({String? cursor}) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>(
        '/agents',
        queryParameters: cursor != null ? {'cursor': cursor} : null,
      );
      return AgentListPage.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, AgentModel>> getAgent(String agentId) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>('/agents/$agentId');
      return AgentModel.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, CreateAgentResult>> createAgent(
    CreateAgentRequest request,
  ) {
    return _guard(() async {
      final data = await _client.post<Map<String, dynamic>>(
        '/agents',
        data: request.toJson(),
      );
      return CreateAgentResult.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, ModelListPage>> listModels() {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>('/models');
      return ModelListPage.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, RepositoryListPage>> listRepositories() {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>('/repositories');
      return RepositoryListPage.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, RunListPage>> listRuns(
    String agentId, {
    String? cursor,
  }) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>(
        '/agents/$agentId/runs',
        queryParameters: cursor != null ? {'cursor': cursor} : null,
      );
      return RunListPage.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, RunModel>> getRun(
    String agentId,
    String runId,
  ) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>(
        '/agents/$agentId/runs/$runId',
      );
      return RunModel.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, CreateRunResult>> createRun(
    String agentId,
    CreateRunRequest request,
  ) {
    return _guard(() async {
      final data = await _client.post<Map<String, dynamic>>(
        '/agents/$agentId/runs',
        data: request.toJson(),
      );
      return CreateRunResult.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, Unit>> cancelRun(
    String agentId,
    String runId,
  ) {
    return _guard(() async {
      await _client.post<Map<String, dynamic>>(
        '/agents/$agentId/runs/$runId/cancel',
      );
      return unit;
    });
  }

  @override
  Future<Either<AgentFailure, UsageModel>> getUsage(String agentId) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>(
        '/agents/$agentId/usage',
      );
      return UsageModel.fromJson(data);
    });
  }

  @override
  Future<Either<AgentFailure, ArtifactListPage>> listArtifacts(String agentId) {
    return _guard(() async {
      final data = await _client.get<Map<String, dynamic>>(
        '/agents/$agentId/artifacts',
      );
      return ArtifactListPage.fromJson(data);
    });
  }

  Future<Either<AgentFailure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on CursorApiError catch (e) {
      return left(mapCursorApiError(e));
    } catch (e) {
      return left(AgentUnknownFailure(e.toString()));
    }
  }
}
