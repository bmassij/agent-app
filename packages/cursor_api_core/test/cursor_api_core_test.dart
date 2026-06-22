import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:cursor_api_core/cursor_api_core.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _response<T>(T data, {int status = 200}) => Response<T>(
      requestOptions: RequestOptions(path: '/'),
      data: data,
      statusCode: status,
    );

void main() {
  group('CursorHttpClient.mapDioException', () {
    test('maps 401 to CursorAuthError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/me'),
            statusCode: 401,
            data: {'message': 'bad key'},
          ),
        ),
      );
      expect(error, isA<CursorAuthError>());
      expect((error as CursorAuthError).message, 'bad key');
    });

    test('maps 401 with error_description field', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/me'),
            statusCode: 401,
            data: {'error_description': 'token expired'},
          ),
        ),
      );
      expect((error as CursorAuthError).message, 'token expired');
    });

    test('maps 404 to CursorNotFoundError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/agents/x'),
          response: Response(
            requestOptions: RequestOptions(path: '/agents/x'),
            statusCode: 404,
          ),
        ),
      );
      expect(error, isA<CursorNotFoundError>());
    });

    test('maps 409 to CursorAgentBusyError with retry-after', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/runs'),
          response: Response(
            requestOptions: RequestOptions(path: '/runs'),
            statusCode: 409,
            headers: Headers.fromMap({
              'retry-after': ['15']
            }),
          ),
        ),
      );
      expect(error, isA<CursorAgentBusyError>());
      expect((error as CursorAgentBusyError).retryAfterSeconds, 15);
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

    test('maps 413 to CursorContextTooLargeError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/agents'),
          response: Response(
            requestOptions: RequestOptions(path: '/agents'),
            statusCode: 413,
            data: {'error': 'too large'},
          ),
        ),
      );
      expect(error, isA<CursorContextTooLargeError>());
    });

    test('maps 429 to CursorRateLimitError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/agents'),
          response: Response(
            requestOptions: RequestOptions(path: '/agents'),
            statusCode: 429,
            headers: Headers.fromMap({
              'x-ratelimit-reset': ['1700000000']
            }),
          ),
        ),
      );
      expect(error, isA<CursorRateLimitError>());
    });

    test('maps 500 to CursorServerError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/agents'),
          response: Response(
            requestOptions: RequestOptions(path: '/agents'),
            statusCode: 503,
            data: {'message': 'down'},
          ),
        ),
      );
      expect(error, isA<CursorServerError>());
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

    test('maps receive timeout to CursorNetworkError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.receiveTimeout,
        ),
      );
      expect(error, isA<CursorNetworkError>());
    });

    test('maps connection error to CursorNetworkError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(error, isA<CursorNetworkError>());
    });

    test('maps unknown client error to CursorUnknownError', () {
      final error = CursorHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/me'),
            statusCode: 418,
          ),
        ),
      );
      expect(error, isA<CursorUnknownError>());
    });
  });

  group('CursorHttpClient requests', () {
    late _MockDio dio;
    late CursorHttpClient client;

    setUp(() {
      dio = _MockDio();
      when(() => dio.options).thenReturn(
        BaseOptions(baseUrl: 'https://api.cursor.com/v1'),
      );
      when(() => dio.interceptors).thenReturn(Interceptors());
      client = CursorHttpClient(apiKey: 'cursor_test', dio: dio);
    });

    test('fetchMe returns parsed model', () async {
      when(
        () => dio.get<dynamic>(
          '/me',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => _response({'userEmail': 'a@b.com', 'apiKeyName': 'Key'}),
      );

      final me = await client.fetchMe();
      expect(me.userEmail, 'a@b.com');
      expect(me.apiKeyName, 'Key');
    });

    test('get with custom parser', () async {
      when(
        () => dio.get<dynamic>(
          '/agents',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response({'id': 'a1'}));

      final id = await client.get<String>(
        '/agents',
        parser: (json) => json['id'] as String,
      );
      expect(id, 'a1');
    });

    test('post returns parsed body', () async {
      when(
        () => dio.post<dynamic>(
          '/agents',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _response({'agentId': 'new'}));

      final data = await client.post<Map<String, dynamic>>('/agents', data: {});
      expect(data['agentId'], 'new');
    });

    test('get passes query parameters', () async {
      when(
        () => dio.get<dynamic>(
          '/agents',
          queryParameters: {'cursor': 'abc'},
        ),
      ).thenAnswer((_) async => _response({'agents': []}));

      await client.get<Map<String, dynamic>>(
        '/agents',
        queryParameters: {'cursor': 'abc'},
      );
      verify(
        () => dio.get<dynamic>(
          '/agents',
          queryParameters: {'cursor': 'abc'},
        ),
      ).called(1);
    });

    test('get returns raw map without parser', () async {
      when(
        () => dio.get<dynamic>(
          '/ping',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response({'ok': true}));

      final data = await client.get<Map<String, dynamic>>('/ping');
      expect(data['ok'], isTrue);
    });

    test('post returns scalar body without parser', () async {
      when(
        () => dio.post<dynamic>(
          '/scalar',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _response('ok'));

      final value = await client.post<String>('/scalar');
      expect(value, 'ok');
    });

    test('get throws when body is not a map', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) async => _response('text'));

      expect(
        () => client.get<Map<String, dynamic>>('/bad'),
        throwsA(isA<CursorUnknownError>()),
      );
    });

    test('postVoid succeeds', () async {
      when(
        () => dio.post<dynamic>(
          '/cancel',
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _response(null, status: 204));

      await expectLater(client.postVoid('/cancel'), completes);
    });

    test('postVoid throws mapped error', () async {
      when(
        () => dio.post<dynamic>(
          '/cancel',
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cancel'),
          response: Response(
            requestOptions: RequestOptions(path: '/cancel'),
            statusCode: 500,
          ),
        ),
      );

      expect(
        () => client.postVoid('/cancel'),
        throwsA(isA<CursorServerError>()),
      );
    });

    test('get throws CursorAuthError on 401', () async {
      when(
        () => dio.get<dynamic>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/me'),
          response: Response(
            requestOptions: RequestOptions(path: '/me'),
            statusCode: 401,
          ),
        ),
      );

      expect(
        () => client.get<Map<String, dynamic>>('/me'),
        throwsA(isA<CursorAuthError>()),
      );
    });

    test('post throws when body is not a map with parser', () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => _response('not-json'));

      expect(
        () => client.post<String>(
          '/agents',
          parser: (_) => 'x',
        ),
        throwsA(isA<CursorUnknownError>()),
      );
    });
  });

  group('CursorApiConfig', () {
    test('exposes base URL and timeouts', () {
      expect(CursorApiConfig.baseUrl, contains('api.cursor.com'));
      expect(CursorApiConfig.connectTimeout.inSeconds, 15);
      expect(CursorApiConfig.receiveTimeout.inSeconds, 30);
    });
  });

  group('CursorApiError toString', () {
    test('formats messages', () {
      expect(const CursorAuthError('bad').toString(), 'bad');
      expect(const CursorNotFoundError('missing').toString(), 'missing');
      expect(const CursorServerError(503, 'down').toString(), contains('503'));
      expect(const CursorNetworkError('offline').toString(), 'offline');
      expect(const CursorUnknownError('x').toString(), 'x');
      expect(const CursorContextTooLargeError('big').toString(), 'big');
    });
  });

  group('CursorMeModel', () {
    test('fromJson uses defaults for missing fields', () {
      final model = CursorMeModel.fromJson({});
      expect(model.apiKeyName, 'API Key');
      expect(model.userEmail, isNull);
    });

    test('fromJson reads all fields', () {
      final model = CursorMeModel.fromJson({
        'userEmail': 'u@x.com',
        'apiKeyName': 'Prod',
        'userId': 42,
        'createdAt': '2026-01-15T12:00:00Z',
      });
      expect(model.userEmail, 'u@x.com');
      expect(model.apiKeyName, 'Prod');
      expect(model.userId, 42);
      expect(model.createdAt.isUtc, isTrue);
    });
  });
}
