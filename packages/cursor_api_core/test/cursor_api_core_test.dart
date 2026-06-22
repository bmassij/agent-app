import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_api_core/cursor_api_core.dart';

class _MockDio extends Mock implements Dio {}

class _MockResponse extends Mock implements Response<dynamic> {}

void main() {
  group('CursorHttpClient.mapDioException', () {
    test('maps 401 to CursorAuthError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/me'),
            statusCode: 401,
          ),
        ),
      );
      expect(error, isA<CursorAuthError>());
    });

    test('maps 409 to CursorAgentBusyError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/runs'),
          response: Response(
            requestOptions: RequestOptions(path: '/runs'),
            statusCode: 409,
          ),
        ),
      );
      expect(error, isA<CursorAgentBusyError>());
    });

    test('maps 410 to CursorStreamExpiredError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/stream'),
          response: Response(
            requestOptions: RequestOptions(path: '/stream'),
            statusCode: 410,
          ),
        ),
      );
      expect(error, isA<CursorStreamExpiredError>());
    });

    test('maps timeout to CursorNetworkError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(error, isA<CursorNetworkError>());
    });
  });

  group('CursorMeModel', () {
    test('fromJson uses defaults for missing fields', () {
      final model = CursorMeModel.fromJson({});
      expect(model.apiKeyName, 'API Key');
      expect(model.userEmail, isNull);
    });
  });
}
