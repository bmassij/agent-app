import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/app/routes.dart';
import 'package:cursor_mobile_commander/app/router.dart';

void main() {
  group('authRedirect', () {
    test('sends unauthenticated users to onboarding', () {
      final result = authRedirect(
        auth: const AsyncData(false),
        onboarding: const AsyncData(false),
        location: Routes.homeProjects,
      );

      expect(result, Routes.onboarding);
    });

    test('allows onboarding routes when unauthenticated', () {
      final result = authRedirect(
        auth: const AsyncData(false),
        onboarding: const AsyncData(false),
        location: Routes.connectCursor,
      );

      expect(result, isNull);
    });

    test('sends authenticated incomplete onboarding to connect cursor', () {
      final result = authRedirect(
        auth: const AsyncData(true),
        onboarding: const AsyncData(false),
        location: Routes.homeProjects,
      );

      expect(result, Routes.connectCursor);
    });

    test('sends authenticated completed users away from onboarding', () {
      final result = authRedirect(
        auth: const AsyncData(true),
        onboarding: const AsyncData(true),
        location: Routes.onboarding,
      );

      expect(result, Routes.homeWorkers);
    });

    test('redirects /home to workers tab', () {
      final result = authRedirect(
        auth: const AsyncData(true),
        onboarding: const AsyncData(true),
        location: Routes.home,
      );

      expect(result, Routes.homeWorkers);
    });

    test('redirects legacy /home/agents paths to workers', () {
      final result = authRedirect(
        auth: const AsyncData(true),
        onboarding: const AsyncData(true),
        location: '/home/agents/abc/chat',
      );

      expect(result, '/home/workers/abc/chat');
    });

    test('returns null while auth is loading', () {
      final result = authRedirect(
        auth: const AsyncLoading(),
        onboarding: const AsyncData(false),
        location: Routes.homeProjects,
      );

      expect(result, isNull);
    });
  });
}
