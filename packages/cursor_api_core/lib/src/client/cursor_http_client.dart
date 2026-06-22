import 'package:dio/dio.dart';

import 'package:cursor_api_core/src/config/cursor_api_config.dart';
import 'package:cursor_api_core/src/errors/cursor_api_error.dart';
import 'package:cursor_api_core/src/models/cursor_me_model.dart';

/// Dio-based HTTP client for Cursor API v1 with Bearer auth injection.
class CursorHttpClient {
  CursorHttpClient({
    required String apiKey,
    Dio? dio,
    String baseUrl = CursorApiConfig.baseUrl,
  })  : _apiKey = apiKey,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: CursorApiConfig.connectTimeout,
                receiveTimeout: CursorApiConfig.receiveTimeout,
                headers: {'Content-Type': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $_apiKey';
          handler.next(options);
        },
      ),
    );
  }

  final String _apiKey;
  final Dio _dio;

  Dio get dio => _dio;

  Future<CursorMeModel> fetchMe() async {
    final data = await _get<Map<String, dynamic>>('/me');
    return CursorMeModel.fromJson(data);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    return _get<T>(path, queryParameters: queryParameters, parser: parser);
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<T> _get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  T _parseResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic>)? parser,
  ) {
    final body = response.data;
    if (parser != null) {
      if (body is Map<String, dynamic>) {
        return parser(body);
      }
      throw const CursorUnknownError('Expected JSON object');
    }
    if (T == Map<String, dynamic>) {
      if (body is Map<String, dynamic>) {
        return body as T;
      }
      throw const CursorUnknownError('Expected JSON object');
    }
    return body as T;
  }

  /// Maps [DioException] to typed [CursorApiError].
  static CursorApiError mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final message = _errorMessage(data) ?? e.message;

    if (status == 401) {
      return CursorAuthError(message ?? 'Unauthorized');
    }
    if (status == 404) {
      return const CursorNotFoundError();
    }
    if (status == 409) {
      return CursorAgentBusyError(
        retryAfterSeconds: _parseRetryAfter(e.response?.headers),
      );
    }
    if (status == 410) {
      return const CursorStreamExpiredError();
    }
    if (status == 413) {
      return CursorContextTooLargeError(message ?? 'Context too large');
    }
    if (status == 429) {
      return CursorRateLimitError(resetAt: _parseRateLimitReset(e.response?.headers));
    }
    if (status != null && status >= 500) {
      return CursorServerError(status, message);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return CursorNetworkError(message ?? 'Network error');
    }
    return CursorUnknownError(message ?? 'Request failed');
  }

  static String? _errorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['error_description'] as String?;
    }
    return null;
  }

  static int? _parseRetryAfter(Headers? headers) {
    final value = headers?.value('retry-after');
    return value != null ? int.tryParse(value) : null;
  }

  static DateTime? _parseRateLimitReset(Headers? headers) {
    final value = headers?.value('x-ratelimit-reset');
    final seconds = value != null ? int.tryParse(value) : null;
    if (seconds == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
  }
}
