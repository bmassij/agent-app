import 'package:commander_orchestrator/commander_orchestrator.dart';
import 'package:commander_orchestrator/src/models/repo_context_bundle.dart';
import 'package:test/test.dart';

void main() {
  group('PromptIntent', () {
    test('detects fix and explain intents', () {
      final fix = PromptIntent.analyze('Fix deze bug');
      expect(fix.wantsFix, isTrue);

      final explain = PromptIntent.analyze('Vertel me over dit project');
      expect(explain.wantsExplain, isTrue);
      expect(explain.suggestPlanMode, isTrue);
    });
  });

  group('PromptBuilder', () {
    const builder = PromptBuilder();

    test('wraps user prompt with briefing', () {
      const context = RepoContextBundle(
        repoUrl: 'https://github.com/o/r',
        owner: 'o',
        repoName: 'r',
        resolvedBranch: 'main',
        agentsMdPresent: true,
      );

      final built = builder.build(
        const CommandInput(
          userPrompt: 'Maak een Windows-versie',
          repoUrl: 'https://github.com/o/r',
        ),
        context,
      );

      expect(built.enrichedPrompt, contains('Maak een Windows-versie'));
      expect(built.enrichedPrompt, contains('AGENTS.md'));
      expect(built.request.repos.single.url, contains('github.com'));
      expect(built.request.repos.single.startingRef, 'main');
    });

    test('uses prUrl when present in context', () {
      const context = RepoContextBundle(
        repoUrl: 'https://github.com/o/r',
        owner: 'o',
        repoName: 'r',
        resolvedBranch: 'main',
        prUrl: 'https://github.com/o/r/pull/42',
        prNumber: 42,
      );

      final built = builder.build(
        const CommandInput(
          userPrompt: 'Fix deze bug',
          repoUrl: 'https://github.com/o/r',
        ),
        context,
      );

      expect(built.request.repos.single.prUrl, contains('/pull/42'));
      expect(built.request.repos.single.startingRef, isNull);
    });
  });

  group('RepositoryScanner.parseRepoUrl', () {
    test('parses normalized github urls', () {
      final parsed = RepositoryScanner.parseRepoUrl('github.com/o/r');
      expect(parsed?.owner, 'o');
      expect(parsed?.repo, 'r');
    });
  });
}
