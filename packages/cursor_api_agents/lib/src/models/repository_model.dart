class RepositoryModel {
  const RepositoryModel({
    required this.url,
    this.owner,
    this.name,
    this.defaultBranch,
  });

  factory RepositoryModel.fromJson(Map<String, dynamic> json) {
    return RepositoryModel(
      url: json['url'] as String? ?? '',
      owner: json['owner'] as String?,
      name: json['name'] as String?,
      defaultBranch: json['defaultBranch'] as String?,
    );
  }

  final String url;
  final String? owner;
  final String? name;
  final String? defaultBranch;
}

class RepositoryListPage {
  const RepositoryListPage({required this.repositories});

  factory RepositoryListPage.fromJson(Map<String, dynamic> json) {
    final items = json['repositories'] as List<dynamic>? ??
        json['repos'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        [];
    return RepositoryListPage(
      repositories: items
          .whereType<Map<String, dynamic>>()
          .map(RepositoryModel.fromJson)
          .toList(),
    );
  }

  final List<RepositoryModel> repositories;
}
