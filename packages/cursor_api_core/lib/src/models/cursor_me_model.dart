/// Response from GET /v1/me.
class CursorMeModel {
  const CursorMeModel({
    required this.apiKeyName,
    this.userEmail,
    this.userId,
    required this.createdAt,
  });

  factory CursorMeModel.fromJson(Map<String, dynamic> json) {
    return CursorMeModel(
      apiKeyName: json['apiKeyName'] as String? ?? 'API Key',
      userEmail: json['userEmail'] as String?,
      userId: json['userId'] as int?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  final String apiKeyName;
  final String? userEmail;
  final int? userId;
  final DateTime createdAt;
}
