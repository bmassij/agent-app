import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/projects/domain/project_failure.dart';

/// Pinned project persistence contract.
abstract interface class ProjectRepository {
  Future<Either<ProjectFailure, Unit>> pinFromUrl({
    required String repoUrl,
    required String defaultBranch,
  });
}
