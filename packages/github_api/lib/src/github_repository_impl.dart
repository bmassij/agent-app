import 'package:fpdart/fpdart.dart';

import 'package:github_api/src/client/github_http_client.dart';
import 'package:github_api/src/errors/github_api_error.dart';
import 'package:github_api/src/github_repository.dart';
import 'package:github_api/src/models/github_models.dart';

class GithubRepositoryImpl implements GithubRepository {
  GithubRepositoryImpl(this._client);

  final GithubHttpClient _client;

  @override
  Future<Either<GithubApiError, List<GithubRepoModel>>> listUserRepos({
    int page = 1,
  }) {
    return _guard(() async {
      final list = await _client.getList(
        '/user/repos',
        queryParameters: {
          'per_page': 100,
          'sort': 'updated',
          'page': page,
        },
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(GithubRepoModel.fromJson)
          .toList();
    });
  }

  @override
  Future<Either<GithubApiError, GithubRepoModel>> getRepository(
    String owner,
    String repo,
  ) {
    return _guard(() async {
      final data = await _client.get('/repos/$owner/$repo');
      return GithubRepoModel.fromJson(data);
    });
  }

  @override
  Future<Either<GithubApiError, List<GithubPullRequestModel>>> listOpenPulls(
    String owner,
    String repo,
  ) {
    return _guard(() async {
      final list = await _client.getList(
        '/repos/$owner/$repo/pulls',
        queryParameters: {'state': 'open', 'per_page': 50},
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(GithubPullRequestModel.fromJson)
          .toList();
    });
  }

  @override
  Future<Either<GithubApiError, GithubPullRequestModel>> getPullRequest(
    String owner,
    String repo,
    int pullNumber,
  ) {
    return _guard(() async {
      final data =
          await _client.get('/repos/$owner/$repo/pulls/$pullNumber');
      return GithubPullRequestModel.fromJson(data);
    });
  }

  @override
  Future<Either<GithubApiError, List<GithubPullFileModel>>> listPullFiles(
    String owner,
    String repo,
    int pullNumber,
  ) {
    return _guard(() async {
      final list = await _client.getList(
        '/repos/$owner/$repo/pulls/$pullNumber/files',
        queryParameters: {'per_page': 100},
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(GithubPullFileModel.fromJson)
          .toList();
    });
  }

  @override
  Future<Either<GithubApiError, Unit>> mergePullRequest(
    String owner,
    String repo,
    int pullNumber, {
    String mergeMethod = 'merge',
  }) {
    return _guard(() async {
      await _client.put(
        '/repos/$owner/$repo/pulls/$pullNumber/merge',
        data: {'merge_method': mergeMethod},
      );
      return unit;
    });
  }

  @override
  Future<Either<GithubApiError, List<GithubCommitModel>>> listCommits(
    String owner,
    String repo, {
    String? branch,
    int page = 1,
  }) {
    return _guard(() async {
      final list = await _client.getList(
        '/repos/$owner/$repo/commits',
        queryParameters: {
          if (branch != null) 'sha': branch,
          'per_page': 30,
          'page': page,
        },
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(GithubCommitModel.fromJson)
          .toList();
    });
  }

  Future<Either<GithubApiError, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return right(await action());
    } on GithubApiError catch (e) {
      return left(e);
    } catch (e) {
      return left(GithubUnknownError(e.toString()));
    }
  }
}
