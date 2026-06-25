/// Rule-based intent detection (no LLM).
class PromptIntent {
  const PromptIntent({
    this.wantsPr = false,
    this.wantsFix = false,
    this.wantsExplain = false,
    this.wantsTests = false,
    this.suggestPlanMode = false,
  });

  factory PromptIntent.analyze(String prompt) {
    final lower = prompt.toLowerCase();
    final wantsPr = _matches(lower, [
      'maak een pr',
      'maak pr',
      'open pr',
      'pull request',
      'create pr',
    ]);
    final wantsFix = _matches(lower, [
      'fix',
      'bug',
      'herstel',
      'repareer',
      'broken',
      'fout',
    ]);
    final wantsExplain = _matches(lower, [
      'vertel',
      'uitleg',
      'about',
      'over dit project',
      'wat is',
      'explain',
      'describe',
    ]);
    final wantsTests = _matches(lower, [
      'test',
      'ci',
      'falen',
      'failing',
      'lint',
    ]);
    final suggestPlanMode = wantsExplain ||
        _matches(lower, [
          'plan',
          'architect',
          'onderzoek',
          'analyse',
        ]);

    return PromptIntent(
      wantsPr: wantsPr,
      wantsFix: wantsFix,
      wantsExplain: wantsExplain,
      wantsTests: wantsTests,
      suggestPlanMode: suggestPlanMode,
    );
  }

  static bool _matches(String text, List<String> needles) {
    return needles.any(text.contains);
  }

  final bool wantsPr;
  final bool wantsFix;
  final bool wantsExplain;
  final bool wantsTests;
  final bool suggestPlanMode;
}
