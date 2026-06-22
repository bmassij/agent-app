import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/app/auth_session_provider.dart';
import 'package:cursor_mobile_commander/app/router.dart';
import 'package:cursor_mobile_commander/app/theme.dart';

/// Root [MaterialApp] configured with go_router and dark theme.
class CommanderApp extends ConsumerWidget {
  const CommanderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider);
    final router = ref.watch(routerProvider);

    if (auth.isLoading) {
      return MaterialApp(
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AuthLoadingScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Cursor Mobile Commander',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
