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
    when(() => dio.options)
        .thenReturn(BaseOptions(baseUrl: 'https://api.cursor.com/v1'));
    when(() => dio.interceptors).thenReturn(Interceptors());
    repo =
        AgentRepositoryImpl(CursorHttpClient(apiKey: 'cursor_test', dio: dio));
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
        'models': [
          {'id': 'claude-sonnet', 'name': 'Sonnet'}
        ],
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
        'repositories': [
          {'url': 'https://github.com/o/r'}
        ],
      }),
    );

    final result = await repo.listRepositories();
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.repositories.single.url, contains('github.com')),
    );
  });

  test('listRepositories parses items array and bare github urls', () async {
    when(
      () => dio.get<dynamic>(
        '/repositories',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'items': [
          {'url': 'github.com/o/r2'},
          'https://github.com/o/r3',
        ],
      }),
    );

    final result = await repo.listRepositories();
    result.fold(
      (_) => fail('expected right'),
      (page) {
        expect(page.repositories, hasLength(2));
        expect(page.repositories.first.url, 'https://github.com/o/r2');
        expect(page.repositories.last.url, 'https://github.com/o/r3');
      },
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
        'runs': [
          {'runId': 'r1', 'inputTokens': 10, 'outputTokens': 20}
        ],
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
        'artifacts': [
          {'name': 'log.txt', 'type': 'file'}
        ],
      }),
    );

    final result = await repo.listArtifacts('a1');
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.artifacts.single.name, 'log.txt'),
    );
  });

  test('getAgent returns agent', () async {
    when(
      () => dio.get<dynamic>(
        '/agents/a1',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'agentId': 'a1',
        'status': 'idle',
        'repos': [],
      }),
    );

    final result = await repo.getAgent('a1');
    result.fold(
      (_) => fail('expected right'),
      (agent) => expect(agent.agentId, 'a1'),
    );
  });

  test('createAgent returns result', () async {
    when(
      () => dio.post<dynamic>(
        '/agents',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'agent': {'id': 'a2'},
        'run': {'id': 'r1', 'status': 'CREATING'},
      }),
    );

    final result = await repo.createAgent(
      const CreateAgentRequest(
        repos: [AgentRepoConfig(url: 'https://github.com/o/r')],
        prompt: 'hi',
      ),
    );
    result.fold(
      (_) => fail('expected right'),
      (created) => expect(created.agentId, 'a2'),
    );
  });

  test('createRun returns run result', () async {
    when(
      () => dio.post<dynamic>(
        '/agents/a1/runs',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'run': {'id': 'r2', 'status': 'running'},
      }),
    );

    final result = await repo.createRun(
      'a1',
      const CreateRunRequest(prompt: 'follow up'),
    );
    result.fold(
      (_) => fail('expected right'),
      (run) => expect(run.runId, 'r2'),
    );
  });

  test('listRuns passes cursor query', () async {
    when(
      () => dio.get<dynamic>(
        '/agents/a1/runs',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'runs': [
          {'runId': 'r1', 'status': 'done'}
        ],
      }),
    );

    final result = await repo.listRuns('a1', cursor: 'cur');
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.runs.single.runId, 'r1'),
    );
    verify(
      () => dio.get<dynamic>(
        '/agents/a1/runs',
        queryParameters: {'cursor': 'cur'},
        options: any(named: 'options'),
      ),
    ).called(1);
  });

  test('listAgents maps 404 to AgentNotFoundFailure', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/agents'),
        response: Response(
          requestOptions: RequestOptions(path: '/agents'),
          statusCode: 404,
        ),
      ),
    );

    final result = await repo.listAgents();
    result.fold(
      (failure) => expect(failure, isA<AgentNotFoundFailure>()),
      (_) => fail('expected left'),
    );
  });
}
