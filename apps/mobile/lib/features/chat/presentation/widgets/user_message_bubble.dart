import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({
    required this.content,
    super.key,
  });

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(
          left: 48,
          right: AppSizes.paddingMedium,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.25),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
