import 'package:aivance_capabilities/aivance_capabilities.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart' as api;
import 'package:cursor_api_stream/cursor_api_stream.dart';
import 'package:cursor_execution_provider/cursor_execution_provider.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:aivance_provider_contract/aivance_provider_contract.dart';

class _MockAgentRepository extends Mock implements api.AgentRepository {}

class _MockRunStreamService extends Mock implements RunStreamService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      api.CreateAgentRequest.singleRepo(
        repoUrl: 'https://github.com/o/r',
        prompt: 'fallback',
      ),
    );
    registerFallbackValue(
      const api.CreateRunRequest(prompt: 'fallback'),
    );
  });

  group('CursorExecutionProvider', () {
    late _MockAgentRepository agents;
    late _MockRunStreamService stream;
    late CursorExecutionProvider provider;

    setUp(() {
      agents = _MockAgentRepository();
      stream = _MockRunStreamService();
      provider = CursorExecutionProvider(
        agents: agents,
        streamService: stream,
      );
    });

    test('id is cursor', () {
      expect(provider.id, 'cursor');
    });

    test('getCapabilities returns execution capabilities', () async {
      final result = await provider.getCapabilities();
      expect(result.isRight(), isTrue);
      final caps = result.getOrElse((_) => {});
      expect(caps, contains(ExecutionCapability.chat));
      expect(caps, contains(ExecutionCapability.followUps));
    });

    test('executeTask maps to createAgent', () async {
      when(() => agents.createAgent(any())).thenAnswer(
        (_) async => right(
          const api.CreateAgentResult(
            agentId: 'agent-1',
            runId: 'run-1',
            status: 'RUNNING',
          ),
        ),
      );

      final result = await provider.executeTask(
        ExecuteTaskRequest.singleRepo(
          repoUrl: 'https://github.com/o/r',
          prompt: 'Hello',
        ),
      );

      expect(result.isRight(), isTrue);
      final created = result.getOrElse((_) => throw StateError('fail'));
      expect(created.taskId, 'agent-1');
      expect(created.runId, 'run-1');
    });

    test('continueTask maps to createRun', () async {
      when(() => agents.createRun(any(), any())).thenAnswer(
        (_) async => right(
          const api.CreateRunResult(runId: 'run-2', status: 'RUNNING'),
        ),
      );

      final result = await provider.continueTask(
        const ContinueTaskRequest(taskId: 'agent-1', prompt: 'Follow up'),
      );

      expect(result.isRight(), isTrue);
      expect(result.getOrElse((_) => throw StateError('fail')).runId, 'run-2');
    });

    test('uploadFiles returns unsupported for Cursor', () async {
      final result = await provider.uploadFiles(
        const [
          TaskFileInput(name: 'a.txt', mimeType: 'text/plain', data: 'a'),
        ],
      );
      expect(result.isLeft(), isTrue);
    });
  });
}
