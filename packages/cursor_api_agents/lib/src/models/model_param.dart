/// Per-model parameter (`model.params` in Cloud Agents API).
class ModelParam {
  const ModelParam({required this.id, required this.value});

  Map<String, dynamic> toJson() => {'id': id, 'value': value};

  final String id;
  final Object value;
}
