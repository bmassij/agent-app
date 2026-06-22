import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    required this.content,
    this.isThinking = false,
    super.key,
  });

  final String content;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isThinking
                ? AppColors.textSecondary.withValues(alpha: 0.3)
                : AppColors.accent.withValues(alpha: 0.3),
            child: Icon(
              isThinking ? Icons.psychology_outlined : Icons.smart_toy_outlined,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                right: AppSizes.paddingMedium,
                top: 4,
                bottom: 4,
              ),
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: MarkdownBody(
                data: content.isEmpty ? '…' : content,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isThinking
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontStyle:
                            isThinking ? FontStyle.italic : FontStyle.normal,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
