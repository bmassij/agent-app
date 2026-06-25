import 'package:cursor_api_agents/src/models/prompt_image.dart';

class CreateRunRequest {
  const CreateRunRequest({
    required this.prompt,
    this.images,
    this.mode,
    this.mcpServers,
  });

  Map<String, dynamic> toJson() {
    return {
      'prompt': {
        'text': prompt,
        if (images != null && images!.isNotEmpty)
          'images': images!.map((i) => i.toJson()).toList(),
      },
      if (mode != null) 'mode': mode,
      if (mcpServers != null && mcpServers!.isNotEmpty)
        'mcpServers': mcpServers,
    };
  }

  final String prompt;
  final List<PromptImage>? images;
  final String? mode;
  final List<Map<String, dynamic>>? mcpServers;
}
