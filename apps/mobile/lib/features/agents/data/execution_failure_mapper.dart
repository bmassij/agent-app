import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:aivance_provider_contract/aivance_provider_contract.dart';

/// Maps [ExecutionFailure] to legacy [api.AgentFailure] for domain compatibility.
abstract final class ExecutionFailureMapper {
  static api.AgentFailure toAgentFailure(ExecutionFailure failure) {
    return switch (failure) {
      ExecutionUnauthorizedFailure(:final message) =>
        api.AgentUnauthorizedFailure(message),
      ExecutionBusyFailure() => api.AgentBusyFailure(),
      ExecutionNetworkFailure(:final message) =>
        api.AgentNetworkFailure(message),
      _ => api.AgentUnknownFailure(failure.message),
    };
  }

  static List<TaskImage>? toTaskImages(List<api.PromptImage>? images) {
    return images
        ?.map(
          (image) => TaskImage(
            data: image.data,
            mimeType: image.mimeType,
            url: image.url,
          ),
        )
        .toList();
  }
}
