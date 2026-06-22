import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/features/chat/domain/tool_call_model.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

class ToolCallChip extends StatefulWidget {
  const ToolCallChip({
    required this.toolCall,
    super.key,
  });

  final ToolCallModel toolCall;

  @override
  State<ToolCallChip> createState() => _ToolCallChipState();
}

class _ToolCallChipState extends State<ToolCallChip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (widget.toolCall.status.toLowerCase()) {
      'running' || 'pending' => Colors.orangeAccent,
      'completed' || 'done' => Colors.greenAccent,
      'failed' || 'error' => AppColors.error,
      _ => AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: 4,
      ),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.toolCall.toolName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Args',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SelectableText(
                    widget.toolCall.argsJson,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (widget.toolCall.resultJson != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Result',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    SelectableText(
                      widget.toolCall.resultJson!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
