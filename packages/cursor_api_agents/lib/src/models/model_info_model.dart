class ModelInfoModel {
  const ModelInfoModel({
    required this.id,
    this.name,
  });

  factory ModelInfoModel.fromJson(Map<String, dynamic> json) {
    return ModelInfoModel(
      id: json['id'] as String? ?? json['model'] as String? ?? '',
      name: json['name'] as String?,
    );
  }

  final String id;
  final String? name;
}

class ModelListPage {
  const ModelListPage({required this.models});

  factory ModelListPage.fromJson(Map<String, dynamic> json) {
    final items =
        json['models'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    return ModelListPage(
      models: items
          .whereType<Map<String, dynamic>>()
          .map(ModelInfoModel.fromJson)
          .toList(),
    );
  }

  final List<ModelInfoModel> models;
}
