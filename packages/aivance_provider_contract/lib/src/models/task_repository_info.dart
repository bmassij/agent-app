import 'package:aivance_provider_contract/src/utils/repo_url_utils.dart';

class TaskRepositoryInfo {
  const TaskRepositoryInfo({
    required this.url,
    this.owner,
    this.name,
    this.defaultBranch,
  });

  factory TaskRepositoryInfo.fromUrl(String raw) {
    return TaskRepositoryInfo(url: RepoUrlUtils.normalize(raw));
  }

  final String url;
  final String? owner;
  final String? name;
  final String? defaultBranch;
}

class TaskRepositoryListPage {
  const TaskRepositoryListPage({required this.repositories});

  final List<TaskRepositoryInfo> repositories;
}
