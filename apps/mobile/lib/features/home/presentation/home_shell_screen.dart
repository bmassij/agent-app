import 'package:flutter/material.dart';

import 'package:cursor_mobile_commander/shared/widgets/app_bottom_nav.dart';

/// Home shell with bottom navigation wrapping tab content.
class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({
    required this.currentIndex,
    required this.child,
    super.key,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: currentIndex),
    );
  }
}
