/// GitHub OAuth configuration (no secrets committed).
abstract final class GithubConfig {
  /// Register an OAuth App at GitHub → Settings → Developer settings.
  /// Pass at build time: `--dart-define=GITHUB_CLIENT_ID=your_client_id`
  static const String clientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    defaultValue: '',
  );

  static const String redirectUri = 'cursormc://oauth/callback';

  static const String scope = 'repo read:org';

  static bool get isConfigured => clientId.isNotEmpty;
}
