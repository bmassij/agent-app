import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';

/// Onboarding completion tracked in [UserSettings.onboardingCompleted].
final onboardingCompletedProvider =
    AsyncNotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);

class OnboardingNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final db = await ref.watch(appDatabaseFutureProvider.future);
    final settings = await db.getOrCreateSettings();
    return settings.onboardingCompleted;
  }

  Future<void> markCompleted() async {
    final db = await ref.read(appDatabaseFutureProvider.future);
    final settings = await db.getOrCreateSettings();
    await (db.update(db.userSettings)..where((t) => t.id.equals(settings.id)))
        .write(
      UserSettingsCompanion(
        onboardingCompleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    state = const AsyncData(true);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

/// Whether GitHub token is stored (onboarding step).
final githubConnectedProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(authRepositoryProvider.future);
  return repo.hasGithubToken();
});

/// Count of pinned projects (onboarding step).
final pinnedProjectCountProvider = FutureProvider<int>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  final rows = await db.select(db.pinnedProjects).get();
  return rows.length;
});

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(authRepositoryProvider.future);
  return repo.isBiometricEnabled();
});
