/// Image input for agent prompts (`prompt.images` in Cloud Agents API).
class PromptImage {
  const PromptImage({
    this.data,
    this.mimeType,
    this.url,
  }) : assert(
          (data != null && mimeType != null) || url != null,
          'Provide data+mimeType or url',
        );

  Map<String, dynamic> toJson() {
    if (url != null) {
      return {'url': url};
    }
    return {
      'data': data,
      'mimeType': mimeType,
    };
  }

  final String? data;
  final String? mimeType;
  final String? url;
}
