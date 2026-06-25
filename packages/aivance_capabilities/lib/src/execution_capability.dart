/// Provider-agnostic execution capabilities (not business/Presence capabilities).
enum ExecutionCapability {
  /// Text chat and task prompts.
  chat,

  /// Real-time SSE streaming of task progress.
  streaming,

  /// Image attachments in prompts.
  images,

  /// File attachments in prompts.
  files,

  /// Download run artifacts.
  artifacts,

  /// Follow-up prompts on an existing task session.
  followUps,

  /// List and bind remote repositories.
  repositories,

  /// Plan / agent execution modes.
  planning,

  /// Background polling and async task monitoring.
  backgroundTasks,
}

/// Stable string id for capability routing and telemetry.
extension ExecutionCapabilityId on ExecutionCapability {
  String get id => switch (this) {
        ExecutionCapability.chat => 'execution.chat',
        ExecutionCapability.streaming => 'execution.streaming',
        ExecutionCapability.images => 'execution.images',
        ExecutionCapability.files => 'execution.files',
        ExecutionCapability.artifacts => 'execution.artifacts',
        ExecutionCapability.followUps => 'execution.follow_ups',
        ExecutionCapability.repositories => 'execution.repositories',
        ExecutionCapability.planning => 'execution.planning',
        ExecutionCapability.backgroundTasks => 'execution.background_tasks',
      };
}

/// Parses a capability id back to [ExecutionCapability], or null if unknown.
ExecutionCapability? executionCapabilityFromId(String id) {
  for (final cap in ExecutionCapability.values) {
    if (cap.id == id) {
      return cap;
    }
  }
  return null;
}
