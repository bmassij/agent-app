import 'package:dio/dio.dart';

import 'package:github_api/src/errors/github_api_error.dart';
import 'package:github_api/src/rate_limit/github_rate_limiter.dart';

/// Dio client for GitHub REST API with rate-limit header parsing.
class GithubHttpClient {
  GithubHttpClient({
    required String accessToken,
    Dio? dio,
    GithubRateLimiter? rateLimiter,
    String baseUrl = 'https://api.github.com',
  })  : _rateLimiter = rateLimiter ?? GithubRateLimiter(),
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                headers: {
                  'Accept': 'application/vnd.github+json',
                  'X-GitHub-Api-Version': '2022-11-28',
                  'Authorization': 'Bearer $accessToken',
                },
              ),
            );

  final Dio _dio;
  final GithubRateLimiter _rateLimiter;

  GithubRateLimiter get rateLimiter => _rateLimiter;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await getDynamic(path, queryParameters: queryParameters);
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const GithubUnknownError('Expected JSON object');
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final data = await getDynamic(path, queryParameters: queryParameters);
    if (data is List<dynamic>) {
      return data;
    }
    throw const GithubUnknownError('Expected JSON array');
  }

  Future<dynamic> getDynamic(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(() => _dio.get<dynamic>(path, queryParameters: queryParameters));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
  }) async {
    return _request(() => _dio.post<dynamic>(path, data: data));
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
  }) async {
    return _request(() => _dio.put<dynamic>(path, data: data));
  }

  Future<void> delete(String path) async {
    await _request(() => _dio.delete<dynamic>(path));
  }

  Future<T> _request<T>(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      _rateLimiter.parseHeaders(response.headers.map);
      return response.data as T;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  static GithubApiError mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final message = _message(e.response?.data);

    if (status == 401) {
      return GithubUnauthorizedError(message ?? 'Unauthorized');
    }
    if (status == 404) {
      return const GithubNotFoundError();
    }
    if (status == 405) {
      return GithubNotMergeableError(message ?? 'Not mergeable');
    }
    if (status == 409) {
      return const GithubMergeConflictError();
    }
    if (status == 422) {
      return GithubValidationFailedError(message ?? 'Validation failed');
    }
    if (status == 429) {
      final resetHeader = e.response?.headers.value('x-ratelimit-reset');
      final resetSeconds = resetHeader != null ? int.tryParse(resetHeader) : null;
      return GithubRateLimitedError(
        resetAt: resetSeconds != null
            ? DateTime.fromMillisecondsSinceEpoch(resetSeconds * 1000, isUtc: true)
            : null,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return GithubNetworkError(e.message ?? 'Network error');
    }
    return GithubUnknownError(message ?? e.message ?? 'Request failed');
  }

  static String? _message(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
