import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agents_provider.dart';
import 'package:cursor_mobile_commander/features/chat/domain/chat_message_model.dart';
import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/chat_provider.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/assistant_message_bubble.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/chat_composer.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/milestone_marker.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/tool_call_chip.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/user_message_bubble.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.agentId,
    super.key,
  });

  final String agentId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _composer;

  @override
  void initState() {
    super.initState();
    _composer = TextEditingController();
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentId = widget.agentId;
    ref.watch(agentChatProvider(agentId));
    final messagesAsync = ref.watch(chatMessagesProvider(agentId));
    final toolsAsync = ref.watch(toolCallsProvider(agentId));
    final chatState = ref.watch(chatStateProvider(agentId));
    final agentAsync = ref.watch(agentProvider(agentId));

    return Scaffold(
      appBar: AppBar(
        title: agentAsync.when(
          data: (a) => Text(a?.name ?? 'Chat'),
          loading: () => const Text('Chat'),
          error: (_, __) => const Text('Chat'),
        ),
        actions: [
          if (chatState.isRunActive)
            TextButton(
              onPressed: () => ref
                  .read(agentChatProvider(agentId).notifier)
                  .cancelCurrentRun(),
              child: const Text('Cancel'),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(Routes.agentDetail(agentId)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (chatState.errorMessage != null)
            MaterialBanner(
              content: Text(chatState.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () => ref
                      .read(chatStateProvider(agentId).notifier)
                      .clearError(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(message: e.toString()),
              data: (messages) {
                final tools = toolsAsync.valueOrNull ?? const [];
                final items = _buildTimeline(messages, tools);
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Send a message to start the conversation.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, index) => items[index],
                );
              },
            ),
          ),
          ChatComposer(
            controller: _composer,
            isSending: chatState.isSending,
            enabled: !chatState.isRunActive,
            onSend: () {
              final text = _composer.text;
              ref.read(agentChatProvider(agentId).notifier).sendPrompt(text);
              _composer.clear();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeline(
    List<ChatMessageModel> messages,
    List<ToolCallModel> tools,
  ) {
    final widgets = <Widget>[];
    var toolIndex = 0;

    for (final message in messages) {
      while (toolIndex < tools.length &&
          tools[toolIndex].startedAt.isBefore(message.timestamp)) {
        widgets.add(ToolCallChip(toolCall: tools[toolIndex]));
        toolIndex++;
      }

      if (message.isUser) {
        widgets.add(UserMessageBubble(content: message.content));
      } else if (message.isThinking) {
        widgets.add(
          AssistantMessageBubble(
            content: message.content,
            isThinking: true,
          ),
        );
      } else if (message.isMilestone) {
        widgets.add(MilestoneMarker(label: message.content));
      } else if (message.isAssistant || message.role == 'result') {
        widgets.add(AssistantMessageBubble(content: message.content));
      }
    }

    while (toolIndex < tools.length) {
      widgets.add(ToolCallChip(toolCall: tools[toolIndex]));
      toolIndex++;
    }

    return widgets;
  }
}
