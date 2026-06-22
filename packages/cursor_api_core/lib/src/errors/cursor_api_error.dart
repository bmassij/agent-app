/// Cursor API HTTP errors mapped from status codes.
sealed class CursorApiError implements Exception {
  const CursorApiError();
}

class CursorAuthError extends CursorApiError {
  const CursorAuthError([this.message = 'Unauthorized']);

  final String message;

  @override
  String toString() => message;
}

class CursorNotFoundError extends CursorApiError {
  const CursorNotFoundError([this.message = 'Not found']);

  final String message;

  @override
  String toString() => message;
}

class CursorAgentBusyError extends CursorApiError {
  const CursorAgentBusyError({this.retryAfterSeconds});

  final int? retryAfterSeconds;
}

class CursorStreamExpiredError extends CursorApiError {
  const CursorStreamExpiredError({this.lastEventId});

  final String? lastEventId;
}

class CursorRateLimitError extends CursorApiError {
  const CursorRateLimitError({this.resetAt});

  final DateTime? resetAt;
}

class CursorContextTooLargeError extends CursorApiError {
  const CursorContextTooLargeError([
    this.message = 'Context too large',
  ]);

  final String message;

  @override
  String toString() => message;
}

class CursorServerError extends CursorApiError {
  const CursorServerError(this.statusCode, [this.body]);

  final int statusCode;
  final String? body;

  @override
  String toString() => 'Server error $statusCode';
}

class CursorNetworkError extends CursorApiError {
  const CursorNetworkError([this.message = 'Network error']);

  final String message;

  @override
  String toString() => message;
}

class CursorUnknownError extends CursorApiError {
  const CursorUnknownError([this.message = 'Unknown error']);

  final String message;

  @override
  String toString() => message;
}
