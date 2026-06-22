class ArtifactModel {
  const ArtifactModel({
    required this.name,
    required this.type,
    this.downloadUrl,
  });

  factory ArtifactModel.fromJson(Map<String, dynamic> json) {
    return ArtifactModel(
      name: json['name'] as String? ?? 'artifact',
      type: json['type'] as String? ?? 'file',
      downloadUrl: json['downloadUrl'] as String? ?? json['url'] as String?,
    );
  }

  final String name;
  final String type;
  final String? downloadUrl;
}

class ArtifactListPage {
  const ArtifactListPage({required this.artifacts});

  factory ArtifactListPage.fromJson(Map<String, dynamic> json) {
    final items =
        json['artifacts'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return ArtifactListPage(
      artifacts: items
          .whereType<Map<String, dynamic>>()
          .map(ArtifactModel.fromJson)
          .toList(),
    );
  }

  final List<ArtifactModel> artifacts;
}
