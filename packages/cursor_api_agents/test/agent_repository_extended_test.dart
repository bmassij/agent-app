import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

Response<T> _jsonResponse<T>(T data) => Response<T>(
      requestOptions: RequestOptions(path: '/'),
      data: data,
    );

void main() {
  late _MockDio dio;
  late AgentRepositoryImpl repo;

  setUp(() {
    dio = _MockDio();
    when(() => dio.options).thenReturn(BaseOptions(baseUrl: 'https://api.cursor.com/v1'));
    when(() => dio.interceptors).thenReturn(Interceptors());
    repo = AgentRepositoryImpl(CursorHttpClient(apiKey: 'cursor_test', dio: dio));
  });

  test('listModels returns models', () async {
    when(
      () => dio.get<dynamic>(
        '/models',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'models': [{'id': 'claude-sonnet', 'name': 'Sonnet'}],
      }),
    );

    final result = await repo.listModels();
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.models.single.id, 'claude-sonnet'),
    );
  });

  test('listRepositories returns repos', () async {
    when(
      () => dio.get<dynamic>(
        '/repositories',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'repositories': [{'url': 'https://github.com/o/r'}],
      }),
    );

    final result = await repo.listRepositories();
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.repositories.single.url, contains('github.com')),
    );
  });

  test('getUsage returns usage rows', () async {
    when(
      () => dio.get<dynamic>(
        '/agents/a1/usage',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'runs': [{'runId': 'r1', 'inputTokens': 10, 'outputTokens': 20}],
      }),
    );

    final result = await repo.getUsage('a1');
    result.fold(
      (_) => fail('expected right'),
      (usage) => expect(usage.runs.single.inputTokens, 10),
    );
  });

  test('listArtifacts returns artifacts', () async {
    when(
      () => dio.get<dynamic>(
        '/agents/a1/artifacts',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'artifacts': [{'name': 'log.txt', 'type': 'file'}],
      }),
    );

    final result = await repo.listArtifacts('a1');
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.artifacts.single.name, 'log.txt'),
    );
  });
}
