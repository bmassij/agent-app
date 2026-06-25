/// File attachment metadata for task prompts.
class TaskFile {
  const TaskFile({
    required this.name,
    required this.mimeType,
    this.url,
    this.data,
  });

  final String name;
  final String mimeType;
  final String? url;
  final String? data;
}

/// Raw file input before provider upload validation.
class TaskFileInput {
  const TaskFileInput({
    required this.name,
    required this.mimeType,
    required this.data,
  });

  final String name;
  final String mimeType;
  final String data;
}
