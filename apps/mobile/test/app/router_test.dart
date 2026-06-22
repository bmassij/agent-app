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

      expect(result, Routes.homeProjects);
    });

    test('redirects /home to projects tab', () {
      final result = authRedirect(
        auth: const AsyncData(true),
        onboarding: const AsyncData(true),
        location: Routes.home,
      );

      expect(result, Routes.homeProjects);
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
