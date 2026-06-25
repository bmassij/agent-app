import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/network/connectivity_service.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';
import 'package:cursor_mobile_commander/shared/constants/sizes.dart';

/// Banner shown when the device has no network connectivity.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider).valueOrNull ?? true;
    if (online) {
      return const SizedBox.shrink();
    }

    return Material(
      color: AppColors.card,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingMedium,
            vertical: AppSizes.paddingSmall,
          ),
          child: const Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: AppColors.textSecondary,
                size: AppSizes.iconSize,
              ),
              SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: Text(
                  'You are offline. Cached data shown; new tasks will queue.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
