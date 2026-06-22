sealed class GithubApiError implements Exception {
  const GithubApiError();
}

class GithubUnauthorizedError extends GithubApiError {
  const GithubUnauthorizedError([this.message = 'Unauthorized']);

  final String message;

  @override
  String toString() => message;
}

class GithubRateLimitedError extends GithubApiError {
  const GithubRateLimitedError({this.resetAt, this.remaining});

  final DateTime? resetAt;
  final int? remaining;

  @override
  String toString() => 'Rate limited';
}

class GithubNotFoundError extends GithubApiError {
  const GithubNotFoundError();
}

class GithubValidationFailedError extends GithubApiError {
  const GithubValidationFailedError([this.message = 'Validation failed']);

  final String message;

  @override
  String toString() => message;
}

class GithubMergeConflictError extends GithubApiError {
  const GithubMergeConflictError();
}

class GithubNotMergeableError extends GithubApiError {
  const GithubNotMergeableError([this.message = 'Not mergeable']);

  final String message;

  @override
  String toString() => message;
}

class GithubNetworkError extends GithubApiError {
  const GithubNetworkError([this.message = 'Network error']);

  final String message;

  @override
  String toString() => message;
}

class GithubUnknownError extends GithubApiError {
  const GithubUnknownError([this.message = 'Unknown error']);

  final String message;

  @override
  String toString() => message;
}
