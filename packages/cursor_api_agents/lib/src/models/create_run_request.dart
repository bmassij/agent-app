class CreateRunRequest {
  const CreateRunRequest({required this.messages});

  Map<String, dynamic> toJson() {
    return {
      'messages': messages
          .map((m) => {'role': m.role, 'content': m.content})
          .toList(),
    };
  }

  final List<RunMessage> messages;
}

class RunMessage {
  const RunMessage({required this.role, required this.content});

  final String role;
  final String content;
}
