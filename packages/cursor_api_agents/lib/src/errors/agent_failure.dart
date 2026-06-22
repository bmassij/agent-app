import 'package:cursor_api_core/cursor_api_core.dart';

/// Agent-layer failures mapped from [CursorApiError].
sealed class AgentFailure implements Exception {
  const AgentFailure();
}

class AgentUnauthorizedFailure extends AgentFailure {
  const AgentUnauthorizedFailure([this.message = 'Unauthorized']);

  final String message;
}

class AgentNotFoundFailure extends AgentFailure {
  const AgentNotFoundFailure();
}

class AgentBusyFailure extends AgentFailure {
  const AgentBusyFailure({this.retryAfterSeconds});

  final int? retryAfterSeconds;
}

class AgentRateLimitedFailure extends AgentFailure {
  const AgentRateLimitedFailure({this.resetAt});

  final DateTime? resetAt;
}

class AgentContextTooLargeFailure extends AgentFailure {
  const AgentContextTooLargeFailure();
}

class AgentNetworkFailure extends AgentFailure {
  const AgentNetworkFailure([this.message = 'Network error']);

  final String message;
}

class AgentUnknownFailure extends AgentFailure {
  const AgentUnknownFailure([this.message = 'Unknown error']);

  final String message;
}

AgentFailure mapCursorApiError(Object error) {
  return switch (error) {
    CursorAuthError(:final message) => AgentUnauthorizedFailure(message),
    CursorNotFoundError() => const AgentNotFoundFailure(),
    CursorAgentBusyError(:final retryAfterSeconds) =>
      AgentBusyFailure(retryAfterSeconds: retryAfterSeconds),
    CursorRateLimitError(:final resetAt) =>
      AgentRateLimitedFailure(resetAt: resetAt),
    CursorContextTooLargeError() => const AgentContextTooLargeFailure(),
    CursorNetworkError(:final message) => AgentNetworkFailure(message),
    CursorServerError(:final statusCode) =>
      AgentUnknownFailure('Server error $statusCode'),
    _ => AgentUnknownFailure(error.toString()),
  };
}
