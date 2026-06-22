import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/shared/constants/colors.dart';

/// Maps agent/run status to color and label.
class AgentStatusChip extends StatelessWidget {
  const AgentStatusChip({
    required this.status,
    super.key,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _mapStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, String) _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'running':
      case 'creating':
      case 'pending':
        return (AppColors.accent, 'Running');
      case 'finished':
      case 'completed':
      case 'done':
        return (Colors.greenAccent, 'Done');
      case 'error':
      case 'failed':
        return (AppColors.error, 'Failed');
      case 'cancelled':
        return (AppColors.textSecondary, 'Cancelled');
      case 'busy':
        return (Colors.orangeAccent, 'Busy');
      default:
        return (AppColors.textSecondary, raw);
    }
  }
}
