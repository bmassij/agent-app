import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/app/router.dart';
import 'package:cursor_mobile_commander/app/theme.dart';
import 'package:cursor_mobile_commander/features/auth/data/github_auth_service.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/biometric_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';

/// Root [MaterialApp] with biometric gate and deep-link handling.
class CommanderApp extends ConsumerStatefulWidget {
  const CommanderApp({super.key});

  @override
  ConsumerState<CommanderApp> createState() => _CommanderAppState();
}

class _CommanderAppState extends ConsumerState<CommanderApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _listenDeepLinks();
  }

  Future<void> _listenDeepLinks() async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      await _handleDeepLink(initial);
    }
    _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'cursormc' && uri.host == 'oauth') {
      try {
        await ref.read(githubAuthServiceProvider).handleOAuthCallback(uri);
        ref.invalidate(githubConnectedProvider);
      } catch (_) {
        // UI surfaces errors on connect screen via provider refresh.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authSessionProvider);
    final onboarding = ref.watch(onboardingCompletedProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final unlocked = ref.watch(biometricUnlockedProvider);
    final router = ref.watch(routerProvider);

    if (auth.isLoading || onboarding.isLoading) {
      return MaterialApp(
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AuthLoadingScreen(),
      );
    }

    final showBiometric = auth.valueOrNull == true &&
        onboarding.valueOrNull == true &&
        biometricEnabled.valueOrNull == true &&
        !unlocked;

    if (showBiometric) {
      return MaterialApp(
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: BiometricScreen(
          onUnlocked: () => setState(() {}),
        ),
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
