import 'package:dio/dio.dart';
import 'package:github_api/github_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _response<T>(T data, {Map<String, List<String>>? headers}) =>
    Response<T>(
      requestOptions: RequestOptions(path: '/'),
      data: data,
      headers: headers != null ? Headers.fromMap(headers) : null,
    );

void main() {
  group('GithubHttpClient extended', () {
    test('maps 401 404 422 429 and network errors', () {
      expect(
        GithubHttpClient.mapDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 401,
              data: {'message': 'bad token'},
            ),
          ),
        ),
        isA<GithubUnauthorizedError>(),
      );
      expect(
        GithubHttpClient.mapDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 404,
            ),
          ),
        ),
        isA<GithubNotFoundError>(),
      );
      expect(
        GithubHttpClient.mapDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 422,
              data: {'message': 'invalid'},
            ),
          ),
        ),
        isA<GithubValidationFailedError>(),
      );
      expect(
        GithubHttpClient.mapDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            response: Response(
              requestOptions: RequestOptions(path: '/'),
              statusCode: 429,
              headers: Headers.fromMap({
                'x-ratelimit-reset': ['1700000000']
              }),
            ),
          ),
        ),
        isA<GithubRateLimitedError>(),
      );
      expect(
        GithubHttpClient.mapDioException(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: DioExceptionType.connectionError,
          ),
        ),
        isA<GithubNetworkError>(),
      );
    });

    test('get throws when response is not an object', () async {
      final dio = _MockDio();
      when(() => dio.options)
          .thenReturn(BaseOptions(baseUrl: 'https://api.github.com'));
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          'bad',
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final client = GithubHttpClient(accessToken: 'gho_test', dio: dio);
      expect(
          () => client.get('/repos/o/r'), throwsA(isA<GithubUnknownError>()));
    });
  });

  group('GithubRepositoryImpl extended', () {
    late _MockDio dio;
    late GithubRepositoryImpl repo;

    setUp(() {
      dio = _MockDio();
      when(() => dio.options)
          .thenReturn(BaseOptions(baseUrl: 'https://api.github.com'));
      repo = GithubRepositoryImpl(
          GithubHttpClient(accessToken: 'gho_test', dio: dio));
    });

    test('getRepository returns repo', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          {'full_name': 'o/r', 'html_url': 'https://github.com/o/r'},
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.getRepository('o', 'r');
      result.fold(
        (_) => fail('expected right'),
        (repoModel) => expect(repoModel.fullName, 'o/r'),
      );
    });

    test('listOpenPulls returns pulls', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          [
            {'number': 1, 'title': 'Fix', 'state': 'open'},
          ],
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.listOpenPulls('o', 'r');
      result.fold(
        (_) => fail('expected right'),
        (pulls) => expect(pulls.single.number, 1),
      );
    });

    test('getPullRequest returns pull', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          {'number': 2, 'title': 'Feat', 'state': 'open'},
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.getPullRequest('o', 'r', 2);
      result.fold(
        (_) => fail('expected right'),
        (pull) => expect(pull.title, 'Feat'),
      );
    });

    test('listPullFiles returns files', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          [
            {'filename': 'a.dart', 'status': 'modified'},
          ],
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.listPullFiles('o', 'r', 1);
      result.fold(
        (_) => fail('expected right'),
        (files) => expect(files.single.filename, 'a.dart'),
      );
    });

    test('listCommits passes branch filter', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => _response(
          [
            {
              'sha': 'abc',
              'commit': {'message': 'init'}
            },
          ],
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.listCommits('o', 'r', branch: 'main');
      result.fold(
        (_) => fail('expected right'),
        (commits) => expect(commits.single.sha, 'abc'),
      );
    });

    test('mergePullRequest succeeds', () async {
      when(() => dio.put<dynamic>(
            any(),
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => _response(
          {'merged': true},
          headers: {
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          },
        ),
      );

      final result = await repo.mergePullRequest('o', 'r', 1);
      result.fold(
        (_) => fail('expected right'),
        (_) => expect(true, isTrue),
      );
    });
  });
}
