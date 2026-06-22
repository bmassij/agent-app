import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/github_auth_service.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/shared/constants/github_config.dart';

class _MemoryStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> deleteKey(String key) async => _values.remove(key);

  @override
  Future<String?> readKey(String key) async => _values[key];

  @override
  Future<void> writeKey(String key, String value) async => _values[key] = value;
}

class _MockDio extends Mock implements Dio {}

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

  test('buildAuthorizeUrl includes PKCE and state parameters', () {
    final service = GithubAuthService(secureStorage: _MemoryStorage());
    const verifier = 'verifier_for_test';
    const state = 'state_for_test';
    final url = service.buildAuthorizeUrl(codeVerifier: verifier, state: state);

    expect(url.host, 'github.com');
    expect(url.path, '/login/oauth/authorize');
    expect(url.queryParameters['code_challenge_method'], 'S256');
    expect(url.queryParameters['code_challenge'], pkceCodeChallenge(verifier));
    expect(url.queryParameters['redirect_uri'], GithubConfig.redirectUri);
    expect(url.queryParameters['state'], state);
  });

  test('handleOAuthCallback rejects mismatched state', () async {
    final storage = _MemoryStorage();
    await storage.writeKey(SecureStorageKeys.oauthState, 'expected_state');
    await storage.writeKey(SecureStorageKeys.oauthCodeVerifier, 'verifier');
    final service = GithubAuthService(secureStorage: storage);

    expect(
      () => service.handleOAuthCallback(
        Uri.parse(
          'cursormc://oauth/callback?code=abc&state=wrong_state',
        ),
      ),
      throwsA(isA<GithubOAuthFailure>()),
    );
  });

  test('handleOAuthCallback rejects GitHub error response', () async {
    final storage = _MemoryStorage();
    final service = GithubAuthService(secureStorage: storage);

    expect(
      () => service.handleOAuthCallback(
        Uri.parse(
          'cursormc://oauth/callback?error=access_denied'
          '&error_description=User%20denied',
        ),
      ),
      throwsA(
        predicate<GithubOAuthFailure>(
          (e) => e.message.contains('denied'),
        ),
      ),
    );
  });

  test('handleOAuthCallback exchanges code when state matches', () async {
    final storage = _MemoryStorage();
    await storage.writeKey(SecureStorageKeys.oauthState, 'valid_state');
    await storage.writeKey(SecureStorageKeys.oauthCodeVerifier, 'verifier');
    final dio = _MockDio();
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/token'),
        data: {'access_token': 'gho_test_token'},
      ),
    );
    final service = GithubAuthService(secureStorage: storage, dio: dio);

    await service.handleOAuthCallback(
      Uri.parse('cursormc://oauth/callback?code=abc&state=valid_state'),
    );

    expect(
      await storage.readKey(SecureStorageKeys.githubAccessToken),
      'gho_test_token',
    );
    expect(await storage.readKey(SecureStorageKeys.oauthState), isNull);
    expect(await storage.readKey(SecureStorageKeys.oauthCodeVerifier), isNull);
  });
}
