import 'package:commander_orchestrator/src/cache/context_cache.dart';
import 'package:commander_orchestrator/src/intent/prompt_intent.dart';
import 'package:commander_orchestrator/src/models/command_models.dart';
import 'package:commander_orchestrator/src/models/repo_context_bundle.dart';
import 'package:commander_orchestrator/src/scanner/repository_scanner.dart';

/// Assembles [RepoContextBundle] with caching and intent-aware PR selection.
class ContextBuilder {
  ContextBuilder({
    required RepositoryScanner scanner,
    ContextCache? cache,
  })  : _scanner = scanner,
        _cache = cache ?? ContextCache();

  final RepositoryScanner _scanner;
  final ContextCache _cache;

  ContextCache get cache => _cache;

  Future<RepoContextBundle> build(
    CommandInput input, {
    UserRepoPreferences prefs = const UserRepoPreferences(),
  }) async {
    final intent = PromptIntent.analyze(input.userPrompt);
    final preliminaryKey = '${input.repoUrl}|${input.branch ?? prefs.lastBranch ?? ''}|${input.prUrl ?? ''}';
    final cached = _cache.get(preliminaryKey);
    if (cached != null && input.prUrl == null && input.prNumber == null) {
      return cached;
    }

    var bundle = await _scanner.scan(
      repoUrl: input.repoUrl,
      branch: input.branch ?? prefs.lastBranch,
      prUrl: input.prUrl ?? prefs.lastPrUrl,
      prNumber: input.prNumber,
      preferredBranch: prefs.lastBranch,
    );

    if (intent.wantsFix || intent.wantsTests) {
      bundle = _preferPrWithFailingCi(bundle, await _rescanWithPrIfNeeded(input, bundle, prefs));
    }

    _cache.put(bundle.cacheKey(), bundle);
    return bundle;
  }

  RepoContextBundle _preferPrWithFailingCi(
    RepoContextBundle current,
    RepoContextBundle withPrs,
  ) {
    if (withPrs.prUrl != null &&
        (withPrs.ciState == 'failure' || withPrs.ciState == 'error')) {
      return withPrs;
    }
    return current.prUrl != null ? current : withPrs;
  }

  Future<RepoContextBundle> _rescanWithPrIfNeeded(
    CommandInput input,
    RepoContextBundle bundle,
    UserRepoPreferences prefs,
  ) async {
    if (bundle.prUrl != null) {
      return bundle;
    }
    return _scanner.scan(
      repoUrl: input.repoUrl,
      branch: bundle.resolvedBranch,
      preferredBranch: prefs.lastBranch,
    );
  }
}
