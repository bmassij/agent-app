class ArtifactDownloadResult {
  const ArtifactDownloadResult({
    required this.url,
    this.expiresAt,
  });

  factory ArtifactDownloadResult.fromJson(Map<String, dynamic> json) {
    return ArtifactDownloadResult(
      url: json['url'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  final String url;
  final DateTime? expiresAt;
}
