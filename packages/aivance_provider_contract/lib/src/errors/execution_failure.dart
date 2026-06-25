sealed class ExecutionFailure {
  const ExecutionFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ExecutionUnauthorizedFailure extends ExecutionFailure {
  const ExecutionUnauthorizedFailure([super.message = 'Unauthorized']);
}

final class ExecutionBusyFailure extends ExecutionFailure {
  const ExecutionBusyFailure([super.message = 'Task is busy']);
}

final class ExecutionNetworkFailure extends ExecutionFailure {
  const ExecutionNetworkFailure([super.message = 'Network error']);
}

final class ExecutionUnknownFailure extends ExecutionFailure {
  const ExecutionUnknownFailure([super.message = 'Unknown execution error']);
}

final class ExecutionUnsupportedFailure extends ExecutionFailure {
  const ExecutionUnsupportedFailure(
      [super.message = 'Unsupported by provider']);
}
