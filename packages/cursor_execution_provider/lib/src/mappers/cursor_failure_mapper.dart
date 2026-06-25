import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:fpdart/fpdart.dart';

import 'package:aivance_provider_contract/aivance_provider_contract.dart';

/// Maps [ExecutionFailure] to legacy [api.AgentFailure] for domain compatibility.
abstract final class CursorFailureMapper {
  static Left<ExecutionFailure, T> left<T>(api.AgentFailure failure) {
    return Left(map(failure));
  }

  static ExecutionFailure map(api.AgentFailure failure) {
    return switch (failure) {
      api.AgentUnauthorizedFailure(:final message) =>
        ExecutionUnauthorizedFailure(message),
      api.AgentBusyFailure() => const ExecutionBusyFailure(),
      api.AgentNetworkFailure(:final message) =>
        ExecutionNetworkFailure(message),
      api.AgentUnknownFailure(:final message) =>
        ExecutionUnknownFailure(message),
      _ => ExecutionUnknownFailure(failure.toString()),
    };
  }
}
