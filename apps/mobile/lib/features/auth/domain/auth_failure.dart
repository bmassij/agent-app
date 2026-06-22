/// Auth-layer failures.
sealed class AuthFailure implements Exception {
  const AuthFailure();
}

class InvalidKeyFailure extends AuthFailure {
  const InvalidKeyFailure([this.message = 'Invalid API key']);

  final String message;
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure([this.message = 'Network error']);

  final String message;
}

class StorageFailure extends AuthFailure {
  const StorageFailure([this.message = 'Secure storage error']);

  final String message;
}

class BiometricFailure extends AuthFailure {
  const BiometricFailure([this.message = 'Biometric authentication failed']);

  final String message;
}

class GithubOAuthFailure extends AuthFailure {
  const GithubOAuthFailure([this.message = 'GitHub connection failed']);

  final String message;
}
