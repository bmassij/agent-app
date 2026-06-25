import 'package:aivance_orchestrator/aivance_orchestrator.dart';
import 'package:cursor_api_agents/cursor_api_agents.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAgentRepository extends Mock implements AgentRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateRunRequest(prompt: 'fallback'));
  });

  group('AgentCommandOrchestrator follow-up', () {
    late _MockAgentRepository agents;
    late AgentCommandOrchestrator orchestrator;

    setUp(() {
      agents = _MockAgentRepository();
      orchestrator = AgentCommandOrchestrator(agents: agents);
    });

    test('enriches follow-up prompt via createRun', () async {
      when(() => agents.createRun(any(), any())).thenAnswer(
        (_) async => right(
          const CreateRunResult(runId: 'run-1', status: 'RUNNING'),
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
        () => agents.createRun('agent-42', captureAny()),
      ).captured.single as CreateRunRequest;

      expect(captured.prompt, contains('Fix deze bug'));
      expect(captured.prompt, contains('Repository: o/r'));
      expect(captured.prompt, contains('## Context'));
    });
  });
}
