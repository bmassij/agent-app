import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';
import 'package:cursor_mobile_commander/features/projects/data/project_repository_impl.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_failure.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_repository.dart';

final projectRepositoryProvider = FutureProvider<ProjectRepository>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  return ProjectRepositoryImpl(database: db);
});

final pinRepoProvider =
    AsyncNotifierProvider<PinRepoNotifier, Option<ProjectFailure>>(
  PinRepoNotifier.new,
);

class PinRepoNotifier extends AsyncNotifier<Option<ProjectFailure>> {
  @override
  Future<Option<ProjectFailure>> build() async => const None();

  Future<bool> pinFromUrl({
    required String repoUrl,
    required String defaultBranch,
  }) async {
    state = const AsyncLoading();
    final repo = await ref.read(projectRepositoryProvider.future);
    final result = await repo.pinFromUrl(
      repoUrl: repoUrl,
      defaultBranch: defaultBranch,
    );
    return result.fold(
      (failure) {
        state = AsyncData(Some(failure));
        return false;
      },
      (_) {
        state = const AsyncData(None());
        ref.invalidate(pinnedProjectCountProvider);
        return true;
      },
    );
  }
}
