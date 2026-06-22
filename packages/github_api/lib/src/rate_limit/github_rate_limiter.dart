import 'package:github_api/src/errors/github_api_error.dart';

class GithubRateLimitInfo {
  const GithubRateLimitInfo({
    required this.remaining,
    required this.limit,
    this.resetAt,
  });

  final int remaining;
  final int limit;
  final DateTime? resetAt;
}

class GithubRateLimiter {
  GithubRateLimiter({this.lowWatermark = 10});

  final int lowWatermark;
  GithubRateLimitInfo? _last;

  GithubRateLimitInfo? get lastInfo => _last;

  GithubRateLimitInfo parseHeaders(Map<String, List<String>> headers) {
    final remaining = int.tryParse(
          _header(headers, 'x-ratelimit-remaining') ?? '',
        ) ??
        0;
    final limit = int.tryParse(_header(headers, 'x-ratelimit-limit') ?? '') ?? 0;
    final resetSeconds =
        int.tryParse(_header(headers, 'x-ratelimit-reset') ?? '');
    final resetAt = resetSeconds != null
        ? DateTime.fromMillisecondsSinceEpoch(resetSeconds * 1000, isUtc: true)
        : null;
    _last = GithubRateLimitInfo(
      remaining: remaining,
      limit: limit,
      resetAt: resetAt,
    );
    return _last!;
  }

  void ensureAvailable(Map<String, List<String>> headers) {
    final info = parseHeaders(headers);
    if (info.remaining < lowWatermark) {
      throw GithubRateLimitedError(
        resetAt: info.resetAt,
        remaining: info.remaining,
      );
    }
  }

  String? _header(Map<String, List<String>> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name && entry.value.isNotEmpty) {
        return entry.value.first;
      }
    }
    return null;
  }
}
