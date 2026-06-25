/// Cloud execution environment (`env` in Cloud Agents API).
class CloudEnvConfig {
  const CloudEnvConfig({
    required this.type,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (name != null) 'name': name,
      };

  /// `cloud`, `pool`, or `machine`.
  final String type;
  final String? name;
}
