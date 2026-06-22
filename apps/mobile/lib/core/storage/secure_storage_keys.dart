/// Secure storage key names. Values are never stored in SQLite.
abstract final class SecureStorageKeys {
  static const String cursorApiKey = 'cursor_api_key';
  static const String githubAccessToken = 'github_access_token';
  static const String githubRefreshToken = 'github_refresh_token';
  static const String oauthCodeVerifier = 'oauth_code_verifier';
}
