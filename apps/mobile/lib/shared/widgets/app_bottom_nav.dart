import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/shared/constants/colors.dart';

/// Bottom navigation bar for the home shell (Projects, Agents, Settings).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    super.key,
  });

  final int currentIndex;

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.homeProjects);
      case 1:
        context.go(Routes.homeAgents);
      case 2:
        context.go(Routes.homeSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: AppColors.card,
      indicatorColor: AppColors.accent.withValues(alpha: 0.2),
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Projects',
        ),
        NavigationDestination(
          icon: Icon(Icons.smart_toy_outlined),
          selectedIcon: Icon(Icons.smart_toy),
          label: 'Agents',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
