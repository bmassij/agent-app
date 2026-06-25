import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:fpdart/fpdart.dart';

import 'package:aivance_capabilities/aivance_capabilities.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:cursor_execution_provider/src/mappers/cursor_failure_mapper.dart';
import 'package:cursor_execution_provider/src/mappers/cursor_stream_mapper.dart';
import 'package:cursor_execution_provider/src/mappers/cursor_task_mapper.dart';

/// Cursor Cloud Agents adapter for [ExecutionProvider].
class CursorExecutionProvider implements ExecutionProvider {
  CursorExecutionProvider({
    required api.AgentRepository agents,
    required RunStreamService streamService,
  })  : _agents = agents,
        _stream = streamService;

  final api.AgentRepository _agents;
  final RunStreamService _stream;

  @override
  String get id => 'cursor';

  @override
  Future<Either<ExecutionFailure, Set<ExecutionCapability>>>
      getCapabilities() async {
    return right({
      ExecutionCapability.chat,
      ExecutionCapability.streaming,
      ExecutionCapability.images,
      ExecutionCapability.artifacts,
      ExecutionCapability.followUps,
      ExecutionCapability.repositories,
      ExecutionCapability.planning,
      ExecutionCapability.backgroundTasks,
    });
  }

  @override
  Future<Either<ExecutionFailure, TaskExecutionResult>> executeTask(
    ExecuteTaskRequest request,
  ) async {
    final result = await _agents.createAgent(
      CursorTaskMapper.toCreateAgentRequest(request),
    );
    return result.fold(
      CursorFailureMapper.left,
      (created) => right(
        TaskExecutionResult(
          taskId: created.agentId,
          runId: created.runId,
          status: created.status,
        ),
      ),
    );
  }

  @override
  Future<Either<ExecutionFailure, ContinueTaskResult>> continueTask(
    ContinueTaskRequest request,
  ) async {
    final result = await _agents.createRun(
      request.taskId,
      CursorTaskMapper.toCreateRunRequest(request),
    );
    return result.fold(
      CursorFailureMapper.left,
      (run) => right(
        ContinueTaskResult(
          taskId: request.taskId,
          runId: run.runId,
          status: run.status,
        ),
      ),
    );
  }

  @override
  Future<Either<ExecutionFailure, Unit>> cancelTask(
    String taskId,
    String runId,
  ) async {
    final result = await _agents.cancelRun(taskId, runId);
    return result.fold(CursorFailureMapper.left, (_) => right(unit));
  }

  @override
  Stream<TaskStreamEvent> streamTask(TaskStreamRequest request) {
    return _stream
        .connectRun(
          agentId: request.taskId,
          runId: request.runId,
          lastEventId: request.lastEventId,
          onStreamExpired: request.onStreamExpired ?? () {},
        )
        .map(CursorStreamMapper.toTaskStreamEvent);
  }

  @override
  Future<Either<ExecutionFailure, List<TaskImage>>> uploadImages(
    List<TaskImageInput> inputs,
  ) async {
    if (inputs.isEmpty) {
      return right(const []);
    }
    return right(
      inputs
          .map(
            (input) => TaskImage(
              data: input.data,
              mimeType: input.mimeType,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<Either<ExecutionFailure, List<TaskFile>>> uploadFiles(
    List<TaskFileInput> inputs,
  ) async {
    if (inputs.isEmpty) {
      return right(const []);
    }
    return left(
      const ExecutionUnsupportedFailure(
        'Cursor provider embeds images in prompts; file upload is not supported',
      ),
    );
  }

  @override
  Future<Either<ExecutionFailure, List<TaskArtifactDownload>>>
      downloadArtifacts(
    String taskId,
  ) async {
    final listed = await _agents.listArtifacts(taskId);
    return listed.fold(CursorFailureMapper.left, (page) async {
      final downloads = <TaskArtifactDownload>[];
      for (final artifact in page.artifacts) {
        final artifactPath = artifact.name;
        final dl = await _agents.downloadArtifact(taskId, artifactPath);
        final mapped = dl.fold<Either<ExecutionFailure, TaskArtifactDownload>>(
          CursorFailureMapper.left,
          (result) => right(
            TaskArtifactDownload(path: artifactPath, url: result.url),
          ),
        );
        final item = mapped.fold((f) => null, (d) => d);
        if (item != null) {
          downloads.add(item);
        }
      }
      return right(downloads);
    });
  }

  @override
  Future<Either<ExecutionFailure, TaskListPage>> listTasks({
    String? cursor,
    String? prUrl,
    bool? includeArchived,
  }) async {
    final result = await _agents.listAgents(
      cursor: cursor,
      prUrl: prUrl,
      includeArchived: includeArchived,
    );
    return result.fold(
      CursorFailureMapper.left,
      (page) => right(CursorTaskMapper.toTaskListPage(page)),
    );
  }

  @override
  Future<Either<ExecutionFailure, TaskInfo>> getTask(String taskId) async {
    final result = await _agents.getAgent(taskId);
    return result.fold(
      CursorFailureMapper.left,
      (agent) => right(CursorTaskMapper.toTaskInfo(agent)),
    );
  }

  @override
  Future<Either<ExecutionFailure, TaskRunInfo>> getRun(
    String taskId,
    String runId,
  ) async {
    final result = await _agents.getRun(taskId, runId);
    return result.fold(
      CursorFailureMapper.left,
      (run) => right(CursorTaskMapper.toTaskRunInfo(taskId, run)),
    );
  }

  @override
  Future<Either<ExecutionFailure, TaskUsage>> getUsage(String taskId) async {
    final result = await _agents.getUsage(taskId);
    return result.fold(
      CursorFailureMapper.left,
      (usage) => right(CursorTaskMapper.toTaskUsage(usage)),
    );
  }

  @override
  Future<Either<ExecutionFailure, TaskModelListPage>> listModels() async {
    final result = await _agents.listModels();
    return result.fold(
      CursorFailureMapper.left,
      (page) => right(CursorTaskMapper.toTaskModelListPage(page)),
    );
  }

  @override
  Future<Either<ExecutionFailure, TaskRepositoryListPage>> listRepositories() {
    return _agents.listRepositories().then(
          (result) => result.fold(
            CursorFailureMapper.left,
            (page) => right(CursorTaskMapper.toTaskRepositoryListPage(page)),
          ),
        );
  }

  /// Exposes raw SSE log lines for debugging (Cursor-specific).
  List<String> get rawSseLogLines => _stream.logger.loggedLines;
}
