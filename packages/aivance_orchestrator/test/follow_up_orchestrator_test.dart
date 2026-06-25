import 'package:aivance_orchestrator/aivance_orchestrator.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockExecutionProvider extends Mock implements ExecutionProvider {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ExecuteTaskRequest.singleRepo(
        repoUrl: 'https://github.com/o/r',
        prompt: 'fallback',
      ),
    );
    registerFallbackValue(
      const ContinueTaskRequest(taskId: 'agent-42', prompt: 'fallback'),
    );
  });

  group('AgentCommandOrchestrator follow-up', () {
    late _MockExecutionProvider execution;
    late AgentCommandOrchestrator orchestrator;

    setUp(() {
      execution = _MockExecutionProvider();
      when(() => execution.id).thenReturn('cursor');
      orchestrator = AgentCommandOrchestrator(execution: execution);
    });

    test('enriches follow-up prompt via continueTask', () async {
      when(() => execution.continueTask(any())).thenAnswer(
        (_) async => right(
          const ContinueTaskResult(
            taskId: 'agent-42',
            runId: 'run-1',
            status: 'RUNNING',
          ),
        ),
      );

      final result = await orchestrator.dispatch(
        const CommandInput(
          userPrompt: 'Fix deze bug',
          repoUrl: 'https://github.com/o/r',
          existingAgentId: 'agent-42',
        ),
      );

      expect(result.isRight(), isTrue);
      final captured = verify(
        () => execution.continueTask(captureAny()),
      ).captured.single as ContinueTaskRequest;

      expect(captured.prompt, contains('Fix deze bug'));
      expect(captured.prompt, contains('Repository: o/r'));
      expect(captured.prompt, contains('## Context'));
    });
  });
}
