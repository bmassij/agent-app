import 'package:aivance_provider_contract/src/models/task_image.dart';

class TaskModelParam {
  const TaskModelParam({required this.id, required this.value});

  final String id;
  final Object value;
}

class TaskCloudEnv {
  const TaskCloudEnv({
    required this.type,
    this.name,
  });

  final String type;
  final String? name;
}

class TaskRepoConfig {
  const TaskRepoConfig({
    required this.url,
    this.startingRef,
    this.prUrl,
  });

  final String url;
  final String? startingRef;
  final String? prUrl;
}

/// Provider-agnostic request to start a new execution task (agent/worker session).
class ExecuteTaskRequest {
  const ExecuteTaskRequest({
    required this.prompt,
    required this.repos,
    this.images,
    this.name,
    this.env,
    this.envVars,
    this.modelId,
    this.modelParams,
    this.mode,
    this.autoCreatePr,
    this.workOnCurrentBranch,
    this.skipReviewerRequest,
    this.mcpServers,
    this.taskId,
  });

  factory ExecuteTaskRequest.singleRepo({
    required String repoUrl,
    required String prompt,
    String? startingRef,
    String? prUrl,
    List<TaskImage>? images,
    String? name,
    TaskCloudEnv? env,
    Map<String, String>? envVars,
    String? modelId,
    List<TaskModelParam>? modelParams,
    String? mode,
    bool? autoCreatePr,
    bool? workOnCurrentBranch,
    bool? skipReviewerRequest,
    List<Map<String, dynamic>>? mcpServers,
    String? taskId,
  }) {
    return ExecuteTaskRequest(
      repos: [
        TaskRepoConfig(
          url: repoUrl,
          startingRef: startingRef,
          prUrl: prUrl,
        ),
      ],
      prompt: prompt,
      images: images,
      name: name,
      env: env,
      envVars: envVars,
      modelId: modelId,
      modelParams: modelParams,
      mode: mode,
      autoCreatePr: autoCreatePr,
      workOnCurrentBranch: workOnCurrentBranch,
      skipReviewerRequest: skipReviewerRequest,
      mcpServers: mcpServers,
      taskId: taskId,
    );
  }

  final String prompt;
  final List<TaskRepoConfig> repos;
  final List<TaskImage>? images;
  final String? name;
  final TaskCloudEnv? env;
  final Map<String, String>? envVars;
  final String? modelId;
  final List<TaskModelParam>? modelParams;
  final String? mode;
  final bool? autoCreatePr;
  final bool? workOnCurrentBranch;
  final bool? skipReviewerRequest;
  final List<Map<String, dynamic>>? mcpServers;
  final String? taskId;
}

class TaskExecutionResult {
  const TaskExecutionResult({
    required this.taskId,
    required this.runId,
    this.status,
  });

  final String taskId;
  final String runId;
  final String? status;
}
