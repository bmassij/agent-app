import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/github_auth_service.dart';
import 'package:cursor_mobile_commander/shared/constants/github_config.dart';

void main() {
  test('pkceCodeChallenge is S256 base64url without padding', () {
    const verifier = 'test_verifier_12345';
    final challenge = pkceCodeChallenge(verifier);
    final digest = sha256.convert(utf8.encode(verifier));
    final expected = base64UrlEncode(digest.bytes).replaceAll('=', '');

    expect(challenge, expected);
    expect(challenge.contains('='), isFalse);
  });

  test('generatePkceCodeVerifier produces non-empty url-safe string', () {
    final verifier = generatePkceCodeVerifier();
    expect(verifier.length, greaterThan(40));
    expect(verifier.contains('='), isFalse);
    expect(verifier.contains('+'), isFalse);
    expect(verifier.contains('/'), isFalse);
  });

  test('buildAuthorizeUrl includes PKCE parameters', () {
    final service = GithubAuthService(
      secureStorage: _FakeStorage(),
    );
    const verifier = 'verifier_for_test';
    final url = service.buildAuthorizeUrl(verifier);

    expect(url.host, 'github.com');
    expect(url.path, '/login/oauth/authorize');
    expect(url.queryParameters['code_challenge_method'], 'S256');
    expect(url.queryParameters['code_challenge'], pkceCodeChallenge(verifier));
    expect(url.queryParameters['redirect_uri'], GithubConfig.redirectUri);
  });
}

class _FakeStorage implements SecureStorageService {
  @override
  Future<void> deleteKey(String key) async {}

  @override
  Future<String?> readKey(String key) async => null;

  @override
  Future<void> writeKey(String key, String value) async {}
}
