/// Image attachment for task prompts.
class TaskImage {
  const TaskImage({
    this.data,
    this.mimeType,
    this.url,
  }) : assert(
          (data != null && mimeType != null) || url != null,
          'Provide data+mimeType or url',
        );

  final String? data;
  final String? mimeType;
  final String? url;
}

/// Raw image bytes before provider upload validation.
class TaskImageInput {
  const TaskImageInput({
    required this.data,
    required this.mimeType,
  });

  final String data;
  final String mimeType;
}
