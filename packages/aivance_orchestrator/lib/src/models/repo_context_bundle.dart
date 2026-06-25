/// Gathered repository context for prompt enrichment.
class RepoContextBundle {
  const RepoContextBundle({
    required this.repoUrl,
    required this.owner,
    required this.repoName,
    required this.resolvedBranch,
    this.defaultBranch,
    this.prUrl,
    this.prTitle,
    this.prNumber,
    this.ciState,
    this.failingChecks,
    this.recentCommits = const [],
    this.readmeExcerpt,
    this.agentsMdPresent = false,
    this.environmentJsonPresent = false,
    this.projectHints = const [],
    this.fromCache = false,
  });

  final String repoUrl;
  final String owner;
  final String repoName;
  final String resolvedBranch;
  final String? defaultBranch;
  final String? prUrl;
  final String? prTitle;
  final int? prNumber;
  final String? ciState;
  final List<String>? failingChecks;
  final List<CommitSummary> recentCommits;
  final String? readmeExcerpt;
  final bool agentsMdPresent;
  final bool environmentJsonPresent;
  final List<String> projectHints;
  final bool fromCache;

  String get fullName => '$owner/$repoName';

  String cacheKey({String? prUrl}) =>
      '$repoUrl|$resolvedBranch|${prUrl ?? this.prUrl ?? ''}';
}

class CommitSummary {
  const CommitSummary({required this.sha, required this.message});

  final String sha;
  final String message;

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;
}

/// Persisted user defaults per repository.
class UserRepoPreferences {
  const UserRepoPreferences({
    this.lastBranch,
    this.lastPrUrl,
    this.preferredModelId,
    this.preferPlanMode = false,
    this.autoCreatePr = false,
    this.cloudEnvName,
  });

  final String? lastBranch;
  final String? lastPrUrl;
  final String? preferredModelId;
  final bool preferPlanMode;
  final bool autoCreatePr;
  final String? cloudEnvName;
}
