class RepositoryModel {
  const RepositoryModel({
    required this.url,
    this.owner,
    this.name,
    this.defaultBranch,
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    var url = json['url'] as String? ??
        json['html_url'] as String? ??
        json['repoUrl'] as String? ??
        json['repositoryUrl'] as String? ??
        '';

    final ownerField = json['owner'];
    final owner = json['ownerName'] as String? ??
        (ownerField is String ? ownerField : null) ??
        (ownerField is Map<String, dynamic>
            ? ownerField['login'] as String?
            : null);
    final name = json['name'] as String? ?? json['repo'] as String?;

    if (url.isEmpty && owner != null && name != null) {
      url = 'https://github.com/$owner/$name';
    }

    return RepositoryModel(
      url: normalizeRepoUrl(url),
      owner: owner,
      name: name,
      defaultBranch:
          json['defaultBranch'] as String? ?? json['default_branch'] as String?,
    );
  }

  factory RepositoryModel.fromUrl(String raw) {
    return RepositoryModel(url: normalizeRepoUrl(raw));
  }

  static String normalizeRepoUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('github.com/')) {
      return 'https://$trimmed';
    }
    if (!trimmed.contains('://') && trimmed.contains('/')) {
      return 'https://github.com/$trimmed';
    }
    return trimmed;
  }

  final String url;
  final String? owner;
  final String? name;
  final String? defaultBranch;
}

class RepositoryListPage {
  const RepositoryListPage({required this.repositories});

  factory RepositoryListPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ??
        json['repositories'] as List<dynamic>? ??
        json['repos'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];

    final repositories = <RepositoryModel>[];
    for (final item in rawItems) {
      if (item is String) {
        final url = RepositoryModel.normalizeRepoUrl(item);
        if (url.isNotEmpty) {
          repositories.add(RepositoryModel.fromUrl(url));
        }
        continue;
      }
      if (item is Map<String, dynamic>) {
        final model = RepositoryModel.fromJson(item);
        if (model.url.isNotEmpty) {
          repositories.add(model);
        }
      }
    }

    return RepositoryListPage(repositories: repositories);
  }

  final List<RepositoryModel> repositories;
}
