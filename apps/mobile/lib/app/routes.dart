/// Route path constants. Never hardcode path strings outside this file.
abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String connectCursor = '/onboarding/connect-cursor';
  static const String connectGithub = '/onboarding/connect-github';
  static const String pinRepo = '/onboarding/pin-repo';
  static const String firstAgent = '/onboarding/first-agent';

  static const String home = '/home';
  static const String homeProjects = '/home/projects';
  static const String homeAgents = '/home/agents';
  static const String homeSettings = '/home/settings';

  static String projectDetail(String projectId) => '/home/projects/$projectId';

  static const String newAgent = '/home/agents/new';
  static String agentDetail(String agentId) => '/home/agents/$agentId';
  static String agentChat(String agentId) => '/home/agents/$agentId/chat';
  static String runLogs(String agentId, String runId) =>
      '/home/agents/$agentId/chat/run/$runId/logs';

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
