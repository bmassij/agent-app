/// Route path constants. Never hardcode path strings outside this file.
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String connectCursor = '/onboarding/connect-cursor';
  static const String keySetup = '/onboarding/connect-cursor/key-setup';
  static const String keySetupScan =
      '/onboarding/connect-cursor/key-setup?scan=true';
  static const String connectGithub = '/onboarding/connect-github';
  static const String pinRepo = '/onboarding/pin-repo';
  static const String firstAgent = '/onboarding/first-agent';

  static const String home = '/home';
  static const String homeProjects = '/home/projects';
  static const String homeWorkers = '/home/workers';

  /// Legacy alias for [homeWorkers] — kept for deep links and bookmarks (M1).
  static const String homeAgents = '/home/agents';

  static const String homeSettings = '/home/settings';

  static String projectDetail(String projectId) => '/home/projects/$projectId';

  static const String newWorker = '/home/workers/new';

  /// Legacy alias for [newWorker].
  static const String newAgent = newWorker;

  static String workerDetail(String workerId) => '/home/workers/$workerId';

  /// Legacy alias — internal IDs remain `agentId` for API compatibility.
  static String agentDetail(String agentId) => workerDetail(agentId);

  static String workerChat(String workerId) => '/home/workers/$workerId/chat';

  /// Legacy alias for [workerChat].
  static String agentChat(String agentId) => workerChat(agentId);

  static String runLogs(String agentId, String runId) =>
      '/home/workers/$agentId/chat/run/$runId/logs';

  static const String keyManage = '/home/settings/keys';
  static const String templates = '/home/settings/templates';
  static String templateEdit(String id) => '/home/settings/templates/edit/$id';

  static String prDetail(String owner, String repo, int prNumber) =>
      '/review/$owner/$repo/pulls/$prNumber';

  static String repoBrowser(String owner, String repo) =>
      '/github/$owner/$repo';

  static String fileViewer(String owner, String repo, String path) =>
      '/github/$owner/$repo/file/$path';
}
