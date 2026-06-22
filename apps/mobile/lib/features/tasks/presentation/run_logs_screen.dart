import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/features/chat/presentation/widgets/assistant_message_bubble.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/tool_call_chip.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/widgets/user_message_bubble.dart';
import 'package:cursor_mobile_commander/features/tasks/presentation/tasks_provider.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';

class RunLogsScreen extends ConsumerWidget {
  const RunLogsScreen({
    required this.agentId,
    required this.runId,
    super.key,
  });

  final String agentId;
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(runLogsProvider(runId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Run $runId'),
      ),
      body: logsAsync.when(
        loading: () => const LoadingSpinner(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (logs) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    for (final message in logs.messages)
                      if (message.isUser)
                        UserMessageBubble(content: message.content)
                      else
                        AssistantMessageBubble(
                          content: message.content,
                          isThinking: message.isThinking,
                        ),
                    for (final tool in logs.tools)
                      ToolCallChip(toolCall: tool),
                  ],
                ),
              ),
              if (logs.totalTokens != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Tokens: ${logs.inputTokens ?? 0} in · '
                    '${logs.outputTokens ?? 0} out · '
                    '${logs.totalTokens} total',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
