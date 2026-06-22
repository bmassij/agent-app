import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_api_agents/cursor_api_agents.dart';

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

  test('listAgents returns agents on success', () async {
    when(
      () => dio.get<dynamic>(
        '/agents',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'agents': [
          {'agentId': 'a1', 'status': 'idle'},
        ],
      }),
    );

    final result = await repo.listAgents();
    result.fold(
      (_) => fail('expected right'),
      (page) => expect(page.agents.single.agentId, 'a1'),
    );
  });

  test('createAgent maps 409 to AgentBusyFailure', () async {
    when(
      () => dio.post<dynamic>(
        '/agents',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/agents'),
        response: Response(
          requestOptions: RequestOptions(path: '/agents'),
          statusCode: 409,
        ),
      ),
    );

    final result = await repo.createAgent(
      const CreateAgentRequest(
        repos: ['https://github.com/o/r'],
        messages: [AgentMessage(role: 'user', content: 'hi')],
      ),
    );
    result.fold(
      (failure) => expect(failure, isA<AgentBusyFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('getRun returns run model', () async {
    when(
      () => dio.get<dynamic>(
        '/agents/a1/runs/r1',
        queryParameters: any(named: 'queryParameters'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _jsonResponse({
        'runId': 'r1',
        'agentId': 'a1',
        'status': 'running',
      }),
    );

    final result = await repo.getRun('a1', 'r1');
    result.fold(
      (_) => fail('expected right'),
      (run) => expect(run.status, 'running'),
    );
  });

  test('cancelRun succeeds', () async {
    when(
      () => dio.post<dynamic>(
        '/agents/a1/runs/r1/cancel',
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => _jsonResponse({}));

    final result = await repo.cancelRun('a1', 'r1');
    result.fold(
      (_) => fail('expected right'),
      (_) {},
    );
  });
}
