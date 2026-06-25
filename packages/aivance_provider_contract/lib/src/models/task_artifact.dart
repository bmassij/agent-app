class TaskArtifact {
  const TaskArtifact({
    required this.path,
    this.url,
    this.sizeBytes,
  });

  final String path;
  final String? url;
  final int? sizeBytes;
}

class TaskArtifactDownload {
  const TaskArtifactDownload({
    required this.path,
    required this.url,
  });

  final String path;
  final String url;
}
