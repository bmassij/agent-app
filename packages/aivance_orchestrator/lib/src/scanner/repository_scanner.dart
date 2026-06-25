import 'package:aivance_orchestrator/src/models/repo_context_bundle.dart';
import 'package:aivance_provider_contract/aivance_provider_contract.dart';
import 'package:github_api/github_api.dart';

/// Parses owner/repo and fetches GitHub metadata when a token is available.
class RepositoryScanner {
  RepositoryScanner({GithubRepository? github}) : _github = github;

  final GithubRepository? _github;

  static ({String owner, String repo})? parseRepoUrl(String url) {
    final normalized = RepoUrlUtils.normalize(url);
    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      return null;
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) {
      return null;
    }
    return (owner: segments[0], repo: segments[1]);
  }

  Future<RepoContextBundle> scan({
    required String repoUrl,
    String? branch,
    String? prUrl,
    int? prNumber,
    String? preferredBranch,
  }) async {
    final parsed = parseRepoUrl(repoUrl);
    if (parsed == null) {
      return RepoContextBundle(
        repoUrl: RepoUrlUtils.normalize(repoUrl),
        owner: 'unknown',
        repoName: 'repo',
        resolvedBranch: branch ?? preferredBranch ?? 'main',
      );
    }

    var resolvedBranch = branch ?? preferredBranch ?? 'main';
    String? defaultBranch;
    String? resolvedPrUrl = prUrl;
    String? prTitle;
    int? resolvedPrNumber = prNumber;
    String? ciState;
    List<String>? failingChecks;
    final commits = <CommitSummary>[];
    String? readmeExcerpt;
    var agentsMd = false;
    var environmentJson = false;
    final hints = <String>[];

    final gh = _github;
    if (gh != null) {
      final repoResult = await gh.getRepository(parsed.owner, parsed.repo);
      repoResult.fold((_) {}, (repo) {
        defaultBranch = repo.defaultBranch;
        if (branch == null &&
            preferredBranch == null &&
            defaultBranch != null) {
          resolvedBranch = defaultBranch!;
        }
      });

      if (resolvedPrUrl == null && resolvedPrNumber != null) {
        final prResult = await gh.getPullRequest(
          parsed.owner,
          parsed.repo,
          resolvedPrNumber,
        );
        prResult.fold((_) {}, (pr) {
          resolvedPrUrl = pr.htmlUrl;
          prTitle = pr.title;
        });
      }

      if (resolvedPrUrl == null) {
        final pulls = await gh.listOpenPulls(parsed.owner, parsed.repo);
        pulls.fold((_) {}, (open) {
          if (open.isNotEmpty && prUrl == null && prNumber == null) {
            final first = open.first;
            resolvedPrUrl = first.htmlUrl;
            prTitle = first.title;
            resolvedPrNumber = first.number;
          }
        });
      }

      final commitResult = await gh.listCommits(
        parsed.owner,
        parsed.repo,
        branch: resolvedBranch,
      );
      commitResult.fold((_) {}, (list) {
        for (final c in list.take(5)) {
          final msg = c.message.split('\n').first;
          commits.add(CommitSummary(sha: c.sha, message: msg));
        }
      });

      for (final path in ['README.md', 'readme.md']) {
        final readme = await gh.getFileContent(
          parsed.owner,
          parsed.repo,
          path,
          ref: resolvedBranch,
        );
        final found = readme.fold((_) => false, (file) {
          final text = file.decodeUtf8();
          readmeExcerpt = _truncate(text, 1500);
          return true;
        });
        if (found) {
          break;
        }
      }

      final agents = await gh.getFileContent(
        parsed.owner,
        parsed.repo,
        'AGENTS.md',
        ref: resolvedBranch,
      );
      agentsMd = agents.isRight();

      final envFile = await gh.getFileContent(
        parsed.owner,
        parsed.repo,
        '.cursor/environment.json',
        ref: resolvedBranch,
      );
      environmentJson = envFile.isRight();

      final pubspec = await gh.getFileContent(
        parsed.owner,
        parsed.repo,
        'pubspec.yaml',
        ref: resolvedBranch,
      );
      pubspec.fold((_) {}, (_) => hints.add('Flutter/Dart (pubspec.yaml)'));

      final packageJson = await gh.getFileContent(
        parsed.owner,
        parsed.repo,
        'package.json',
        ref: resolvedBranch,
      );
      packageJson.fold((_) {}, (_) => hints.add('Node.js (package.json)'));

      final statusRef = resolvedPrUrl != null && commits.isNotEmpty
          ? commits.first.sha
          : resolvedBranch;
      final status = await gh.getCombinedStatus(
        parsed.owner,
        parsed.repo,
        statusRef,
      );
      status.fold((_) {}, (s) {
        ciState = s.state;
        failingChecks = s.failingContexts;
      });
    }

    return RepoContextBundle(
      repoUrl: RepoUrlUtils.normalize(repoUrl),
      owner: parsed.owner,
      repoName: parsed.repo,
      resolvedBranch: resolvedBranch,
      defaultBranch: defaultBranch,
      prUrl: resolvedPrUrl,
      prTitle: prTitle,
      prNumber: resolvedPrNumber,
      ciState: ciState,
      failingChecks: failingChecks,
      recentCommits: commits,
      readmeExcerpt: readmeExcerpt,
      agentsMdPresent: agentsMd,
      environmentJsonPresent: environmentJson,
      projectHints: hints,
    );
  }

  static String _truncate(String text, int maxChars) {
    if (text.length <= maxChars) {
      return text;
    }
    return '${text.substring(0, maxChars)}…';
  }
}
