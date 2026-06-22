import 'package:dio/dio.dart';
import 'package:github_api/github_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  group('GithubRateLimiter', () {
    test('throws when remaining below watermark', () {
      final limiter = GithubRateLimiter(lowWatermark: 10);
      expect(
        () => limiter.ensureAvailable({
          'x-ratelimit-remaining': ['5'],
          'x-ratelimit-limit': ['5000'],
        }),
        throwsA(isA<GithubRateLimitedError>()),
      );
    });
  });

  group('GithubHttpClient', () {
    test('maps 409 to GithubMergeConflictError', () {
      final error = GithubHttpClient.mapDioException(
        DioException(
          requestOptions: RequestOptions(path: '/merge'),
          response: Response(
            requestOptions: RequestOptions(path: '/merge'),
            statusCode: 409,
          ),
        ),
      );
      expect(error, isA<GithubMergeConflictError>());
    });
  });

  group('GithubRepositoryImpl', () {
    late _MockDio dio;
    late GithubRepositoryImpl repo;

    setUp(() {
      dio = _MockDio();
      when(() => dio.options).thenReturn(BaseOptions(baseUrl: 'https://api.github.com'));
      repo = GithubRepositoryImpl(GithubHttpClient(accessToken: 'gho_test', dio: dio));
    });

    test('listUserRepos returns repos', () async {
      when(
        () => dio.get<dynamic>(
          '/user/repos',
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/user/repos'),
          data: [
            {'full_name': 'org/repo', 'html_url': 'https://github.com/org/repo'},
          ],
          headers: Headers.fromMap({
            'x-ratelimit-remaining': ['100'],
            'x-ratelimit-limit': ['5000'],
          }),
        ),
      );

      final result = await repo.listUserRepos();
      result.fold(
        (_) => fail('expected right'),
        (repos) => expect(repos.single.fullName, 'org/repo'),
      );
    });

    test('mergePullRequest maps 405 to not mergeable', () async {
      when(
        () => dio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/merge'),
          response: Response(
            requestOptions: RequestOptions(path: '/merge'),
            statusCode: 405,
            data: {'message': 'not mergeable'},
          ),
        ),
      );

      final result = await repo.mergePullRequest('o', 'r', 1);
      result.fold(
        (error) => expect(error, isA<GithubNotMergeableError>()),
        (_) => fail('expected left'),
      );
    });
  });
}
