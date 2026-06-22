import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agent_detail_screen.dart';
import 'package:cursor_mobile_commander/features/agents/presentation/agent_list_screen.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/chat_screen.dart';
import 'package:cursor_mobile_commander/features/chat/presentation/new_agent_screen.dart';
import 'package:cursor_mobile_commander/features/tasks/presentation/run_logs_screen.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/key_setup_screen.dart';
import 'package:cursor_mobile_commander/features/home/presentation/home_shell_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/connect_cursor_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/connect_github_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/first_agent_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/pin_repo_screen.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/welcome_screen.dart';
import 'package:cursor_mobile_commander/features/projects/presentation/dashboard_screen.dart';
import 'package:cursor_mobile_commander/features/settings/presentation/settings_screen.dart';
import 'package:cursor_mobile_commander/shared/widgets/error_view.dart';
import 'package:cursor_mobile_commander/shared/widgets/loading_spinner.dart';
import 'package:cursor_mobile_commander/shared/widgets/placeholder_screen.dart';

/// Notifies [GoRouter] when auth or onboarding state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._ref) {
    _ref.listen(authSessionProvider, (_, __) => notifyListeners());
    _ref.listen(onboardingCompletedProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

/// Auth guard redirect logic (extracted for unit testing).
String? authRedirect({
  required AsyncValue<bool> auth,
  required AsyncValue<bool> onboarding,
  required String location,
}) {
  final onOnboarding = location.startsWith(Routes.onboarding);

  if (auth.isLoading || onboarding.isLoading) {
    return null;
  }

  final isAuthenticated = auth.valueOrNull ?? false;
  final onboardingDone = onboarding.valueOrNull ?? false;

  if (!isAuthenticated && !onOnboarding) {
    return Routes.onboarding;
  }

  if (isAuthenticated && !onboardingDone && !onOnboarding) {
    return Routes.connectCursor;
  }

  if (isAuthenticated && onboardingDone && onOnboarding) {
    return Routes.homeProjects;
  }

  if (location == Routes.home) {
    return Routes.homeProjects;
  }

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.onboarding,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authSessionProvider);
      final onboarding = ref.read(onboardingCompletedProvider);
      return authRedirect(
        auth: auth,
        location: state.matchedLocation,
        onboarding: onboarding,
      );
    },
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'connect-cursor',
            builder: (context, state) => const ConnectCursorScreen(),
            routes: [
              GoRoute(
                path: 'key-setup',
                builder: (context, state) => const KeySetupScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'connect-github',
            builder: (context, state) => const ConnectGithubScreen(),
          ),
          GoRoute(
            path: 'pin-repo',
            builder: (context, state) => const PinRepoScreen(),
          ),
          GoRoute(
            path: 'first-agent',
            builder: (context, state) => const FirstAgentScreen(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShellScreen(
            currentIndex: navigationShell.currentIndex,
            child: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeProjects,
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: ':projectId',
                    builder: (context, state) => PlaceholderScreen(
                      title: 'Project ${state.pathParameters['projectId']}',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeAgents,
                builder: (context, state) => const AgentListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const NewAgentScreen(),
                  ),
                  GoRoute(
                    path: ':agentId',
                    builder: (context, state) => AgentDetailScreen(
                      agentId: state.pathParameters['agentId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'chat',
                        builder: (context, state) => ChatScreen(
                          agentId: state.pathParameters['agentId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'run/:runId/logs',
                            builder: (context, state) => RunLogsScreen(
                              agentId: state.pathParameters['agentId']!,
                              runId: state.pathParameters['runId']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homeSettings,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'keys',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'API Keys'),
                  ),
                  GoRoute(
                    path: 'templates',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Templates'),
                    routes: [
                      GoRoute(
                        path: 'edit/:id',
                        builder: (context, state) => PlaceholderScreen(
                          title:
                              'Edit Template ${state.pathParameters['id']}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/review/:owner/:repo/pulls/:prNumber',
        builder: (context, state) => PlaceholderScreen(
          title: 'PR #${state.pathParameters['prNumber']}',
        ),
      ),
      GoRoute(
        path: '/github/:owner/:repo',
        builder: (context, state) => PlaceholderScreen(
          title: '${state.pathParameters['owner']}/'
              '${state.pathParameters['repo']}',
        ),
        routes: [
          GoRoute(
            path: 'file/:path',
            builder: (context, state) => PlaceholderScreen(
              title: state.pathParameters['path'] ?? 'File',
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: ErrorView(message: state.error.toString()),
    ),
  );
});

/// Root widget shown while auth session is loading.
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoadingSpinner(message: 'Loading…'),
    );
  }
}
