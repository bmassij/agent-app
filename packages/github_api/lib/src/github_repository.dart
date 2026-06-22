import 'package:fpdart/fpdart.dart';

import 'package:github_api/src/errors/github_api_error.dart';
import 'package:github_api/src/models/github_models.dart';

/// GitHub REST operations per docs/API_GUIDE.md.
abstract interface class GithubRepository {
  Future<Either<GithubApiError, List<GithubRepoModel>>> listUserRepos({
    int page,
  });

  Future<Either<GithubApiError, GithubRepoModel>> getRepository(
    String owner,
    String repo,
  );

  Future<Either<GithubApiError, List<GithubPullRequestModel>>> listOpenPulls(
    String owner,
    String repo,
  );

  Future<Either<GithubApiError, GithubPullRequestModel>> getPullRequest(
    String owner,
    String repo,
    int pullNumber,
  );

  Future<Either<GithubApiError, List<GithubPullFileModel>>> listPullFiles(
    String owner,
    String repo,
    int pullNumber,
  );

  Future<Either<GithubApiError, Unit>> mergePullRequest(
    String owner,
    String repo,
    int pullNumber, {
    String mergeMethod,
  });

  Future<Either<GithubApiError, List<GithubCommitModel>>> listCommits(
    String owner,
    String repo, {
    String? branch,
    int page,
  });
}
