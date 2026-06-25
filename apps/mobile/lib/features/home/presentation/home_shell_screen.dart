import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/shared/widgets/app_bottom_nav.dart';
import 'package:cursor_mobile_commander/shared/widgets/offline_banner.dart';

/// Home shell with bottom navigation wrapping tab content.
class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }
}
