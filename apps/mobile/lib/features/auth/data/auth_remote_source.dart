import 'package:dio/dio.dart';

import 'package:cursor_mobile_commander/core/logging/app_logger.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_model.dart';
import 'package:cursor_mobile_commander/shared/constants/cursor_api_config.dart';

/// HTTP calls for Cursor auth (Sprint 3 moves this to cursor_api_core).
class AuthRemoteSource {
  AuthRemoteSource({
    Dio? dio,
    AppLogger? logger,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: CursorApiConfig.baseUrl,
                connectTimeout: CursorApiConfig.connectTimeout,
                receiveTimeout: CursorApiConfig.receiveTimeout,
                headers: {'Content-Type': 'application/json'},
              ),
            ),
        _logger = logger ?? const AppLogger();

  final Dio _dio;
  final AppLogger _logger;

  Future<CursorMeModel> fetchMe(String apiKey) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me',
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
      ),
    );
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty response from /v1/me',
      );
    }
    _logger.debug('Validated Cursor API key');
    return CursorMeModel.fromJson(data);
  }
}
