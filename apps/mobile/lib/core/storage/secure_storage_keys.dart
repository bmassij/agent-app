/// Secure storage key names. Values are never stored in SQLite.
abstract final class SecureStorageKeys {
  /// Legacy Cursor API key (read fallback during M2–M4 migration).
  static const String cursorApiKey = 'cursor_api_key';

  /// Target key for workspace connection token (M2 dual-write).
  static const String providerCursorToken = 'provider_cursor_token';

  /// Legacy GitHub token key.
  static const String githubAccessToken = 'github_access_token';

  /// Target key for GitHub integration token (M2 dual-write).
  static const String integrationGithubToken = 'integration_github_token';

  static const String githubRefreshToken = 'github_refresh_token';
  static const String oauthCodeVerifier = 'oauth_code_verifier';
  static const String oauthState = 'oauth_state';
  static const String lastUsedRepoUrl = 'last_used_repo_url';
  static const String updateServerUrl = 'update_server_url';
}
