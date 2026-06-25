/// Feature flags for risky M2+ capabilities (rollback via build defines).
abstract final class FeatureFlags {
  static const bool notificationsEnabled = bool.fromEnvironment(
    'NOTIFICATIONS_ENABLED',
    defaultValue: true,
  );

  static const bool offlineQueueEnabled = bool.fromEnvironment(
    'OFFLINE_QUEUE_ENABLED',
    defaultValue: true,
  );

  static const bool backgroundPollingEnabled = bool.fromEnvironment(
    'BACKGROUND_POLLING_ENABLED',
    defaultValue: true,
  );
}
