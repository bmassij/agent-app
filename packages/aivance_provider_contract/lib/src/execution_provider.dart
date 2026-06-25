import 'package:aivance_capabilities/aivance_capabilities.dart';
import 'package:fpdart/fpdart.dart';

import 'package:aivance_provider_contract/src/errors/execution_failure.dart';
import 'package:aivance_provider_contract/src/models/continue_task_request.dart';
import 'package:aivance_provider_contract/src/models/execute_task_request.dart';
import 'package:aivance_provider_contract/src/models/task_artifact.dart';
import 'package:aivance_provider_contract/src/models/task_file.dart';
import 'package:aivance_provider_contract/src/models/task_image.dart';
import 'package:aivance_provider_contract/src/models/task_info.dart';
import 'package:aivance_provider_contract/src/models/task_model_info.dart';
import 'package:aivance_provider_contract/src/models/task_repository_info.dart';
import 'package:aivance_provider_contract/src/models/task_run_info.dart';
import 'package:aivance_provider_contract/src/models/task_stream_event.dart';
import 'package:aivance_provider_contract/src/models/task_stream_request.dart';
import 'package:aivance_provider_contract/src/models/task_usage.dart';

/// Provider-agnostic execution port for digital work dispatch and monitoring.
abstract interface class ExecutionProvider {
  /// Stable provider identifier (e.g. `cursor`).
  String get id;

  /// Returns execution capabilities supported by this provider instance.
  Future<Either<ExecutionFailure, Set<ExecutionCapability>>> getCapabilities();

  /// Starts a new task session (maps to agent/worker creation).
  Future<Either<ExecutionFailure, TaskExecutionResult>> executeTask(
    ExecuteTaskRequest request,
  );

  /// Sends a follow-up prompt on an existing task session.
  Future<Either<ExecutionFailure, ContinueTaskResult>> continueTask(
    ContinueTaskRequest request,
  );

  /// Cancels an in-flight run for a task session.
  Future<Either<ExecutionFailure, Unit>> cancelTask(
    String taskId,
    String runId,
  );

  /// Streams real-time progress events for a run.
  Stream<TaskStreamEvent> streamTask(TaskStreamRequest request);

  /// Validates and normalizes image attachments before task dispatch.
  Future<Either<ExecutionFailure, List<TaskImage>>> uploadImages(
    List<TaskImageInput> inputs,
  );

  /// Validates and normalizes file attachments before task dispatch.
  Future<Either<ExecutionFailure, List<TaskFile>>> uploadFiles(
    List<TaskFileInput> inputs,
  );

  /// Lists artifacts for a task and resolves download URLs where supported.
  Future<Either<ExecutionFailure, List<TaskArtifactDownload>>>
      downloadArtifacts(
    String taskId,
  );

  /// Lists active and recent task sessions.
  Future<Either<ExecutionFailure, TaskListPage>> listTasks({
    String? cursor,
    String? prUrl,
    bool? includeArchived,
  });

  /// Fetches a single task session by id.
  Future<Either<ExecutionFailure, TaskInfo>> getTask(String taskId);

  /// Fetches run metadata for a task session.
  Future<Either<ExecutionFailure, TaskRunInfo>> getRun(
    String taskId,
    String runId,
  );

  /// Returns token usage for a task session.
  Future<Either<ExecutionFailure, TaskUsage>> getUsage(String taskId);

  /// Lists models available for task execution.
  Future<Either<ExecutionFailure, TaskModelListPage>> listModels();

  /// Lists repositories available for task binding.
  Future<Either<ExecutionFailure, TaskRepositoryListPage>> listRepositories();
}
