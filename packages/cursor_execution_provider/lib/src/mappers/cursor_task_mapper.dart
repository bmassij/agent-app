import 'package:cursor_api_agents/cursor_api_agents.dart' as api;

import 'package:aivance_provider_contract/aivance_provider_contract.dart';

abstract final class CursorTaskMapper {
  static api.CreateAgentRequest toCreateAgentRequest(
      ExecuteTaskRequest request) {
    return api.CreateAgentRequest(
      repos: request.repos
          .map(
            (repo) => api.AgentRepoConfig(
              url: repo.url,
              startingRef: repo.startingRef,
              prUrl: repo.prUrl,
            ),
          )
          .toList(),
      prompt: request.prompt,
      images: request.images?.map(toPromptImage).toList(),
      name: request.name,
      env: request.env == null
          ? null
          : api.CloudEnvConfig(
              type: request.env!.type,
              name: request.env!.name,
            ),
      envVars: request.envVars,
      modelId: request.modelId,
      modelParams: request.modelParams
          ?.map((p) => api.ModelParam(id: p.id, value: p.value))
          .toList(),
      mode: request.mode,
      autoCreatePr: request.autoCreatePr,
      workOnCurrentBranch: request.workOnCurrentBranch,
      skipReviewerRequest: request.skipReviewerRequest,
      mcpServers: request.mcpServers,
      agentId: request.taskId,
    );
  }

  static api.CreateRunRequest toCreateRunRequest(ContinueTaskRequest request) {
    return api.CreateRunRequest(
      prompt: request.prompt,
      images: request.images?.map(toPromptImage).toList(),
      mode: request.mode,
      mcpServers: request.mcpServers,
    );
  }

  static api.PromptImage toPromptImage(TaskImage image) {
    return api.PromptImage(
      data: image.data,
      mimeType: image.mimeType,
      url: image.url,
    );
  }

  static TaskImage fromPromptImage(api.PromptImage image) {
    return TaskImage(
      data: image.data,
      mimeType: image.mimeType,
      url: image.url,
    );
  }

  static TaskListPage toTaskListPage(api.AgentListPage page) {
    return TaskListPage(
      tasks: page.agents.map(toTaskInfo).toList(),
      nextCursor: page.nextCursor,
    );
  }

  static TaskInfo toTaskInfo(api.AgentModel agent) {
    return TaskInfo(
      taskId: agent.agentId,
      name: agent.name,
      status: agent.status,
      latestRunId: agent.latestRunId,
      createdAt: agent.createdAt,
      updatedAt: agent.updatedAt,
    );
  }

  static TaskRunInfo toTaskRunInfo(String taskId, api.RunModel run) {
    return TaskRunInfo(
      runId: run.runId,
      taskId: taskId,
      status: run.status,
      resultText: run.resultText,
      createdAt: run.createdAt,
      completedAt: run.completedAt,
    );
  }

  static TaskUsage toTaskUsage(api.UsageModel usage) {
    return TaskUsage(
      runs: usage.runs
          .map(
            (run) => TaskUsageRun(
              runId: run.runId,
              inputTokens: run.inputTokens,
              outputTokens: run.outputTokens,
            ),
          )
          .toList(),
    );
  }

  static TaskModelListPage toTaskModelListPage(api.ModelListPage page) {
    return TaskModelListPage(
      models: page.models
          .map(
            (model) => TaskModelInfo(
              id: model.id,
              name: model.name,
            ),
          )
          .toList(),
    );
  }

  static TaskRepositoryListPage toTaskRepositoryListPage(
    api.RepositoryListPage page,
  ) {
    return TaskRepositoryListPage(
      repositories: page.repositories
          .map(
            (repo) => TaskRepositoryInfo(
              url: repo.url,
              owner: repo.owner,
              name: repo.name,
              defaultBranch: repo.defaultBranch,
            ),
          )
          .toList(),
    );
  }
}
