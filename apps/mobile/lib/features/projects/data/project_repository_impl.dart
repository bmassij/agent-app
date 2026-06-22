import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_failure.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  ProjectRepositoryImpl({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  @override
  Future<Either<ProjectFailure, Unit>> pinFromUrl({
    required String repoUrl,
    required String defaultBranch,
  }) async {
    final url = repoUrl.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.contains('github.com')) {
      return left(
        const InvalidRepoUrlFailure('Enter a valid GitHub repository URL'),
      );
    }
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) {
      return left(
        const InvalidRepoUrlFailure(
          'URL must be https://github.com/owner/repo',
        ),
      );
    }
    final owner = segments[0];
    final name = segments[1];
    final branch = defaultBranch.trim().isEmpty ? 'main' : defaultBranch.trim();

    try {
      await _db.into(_db.pinnedProjects).insertOnConflictUpdate(
            PinnedProjectsCompanion.insert(
              id: '$owner/$name',
              repoUrl: url,
              owner: owner,
              name: name,
              defaultBranch: branch,
              sortOrder: const Value(0),
            ),
          );
      return right(unit);
    } catch (e) {
      return left(ProjectStorageFailure(e.toString()));
    }
  }
}
