/// Project pinning and repository failures.
sealed class ProjectFailure implements Exception {
  const ProjectFailure();
}

class InvalidRepoUrlFailure extends ProjectFailure {
  const InvalidRepoUrlFailure([this.message = 'Invalid repository URL']);

  final String message;
}

class ProjectStorageFailure extends ProjectFailure {
  const ProjectStorageFailure([this.message = 'Failed to save project']);

  final String message;
}
