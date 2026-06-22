import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cursor_mobile_commander/core/logging/app_logger.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/shared/constants/github_config.dart';

/// PKCE helpers exposed for unit tests.
String generatePkceCodeVerifier() {
  final random = Random.secure();
  final values = List<int>.generate(64, (_) => random.nextInt(256));
  return base64UrlEncode(values).replaceAll('=', '');
}

String pkceCodeChallenge(String verifier) {
  final digest = sha256.convert(utf8.encode(verifier));
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}

/// GitHub OAuth 2.0 with PKCE (no backend).
class GithubAuthService {
  GithubAuthService({
    required SecureStorageService secureStorage,
    Dio? dio,
    AppLogger? logger,
  })  : _secureStorage = secureStorage,
        _dio = dio ?? Dio(),
        _logger = logger ?? const AppLogger();

  final SecureStorageService _secureStorage;
  final Dio _dio;
  final AppLogger _logger;

  Uri buildAuthorizeUrl(String codeVerifier) {
    final challenge = pkceCodeChallenge(codeVerifier);
    return Uri.https(
      'github.com',
      '/login/oauth/authorize',
      {
        'client_id': GithubConfig.clientId,
        'redirect_uri': GithubConfig.redirectUri,
        'scope': GithubConfig.scope,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      },
    );
  }

  Future<void> startOAuthFlow() async {
    if (!GithubConfig.isConfigured) {
      throw const GithubOAuthFailure(
        'GITHUB_CLIENT_ID not configured. '
        'Build with --dart-define=GITHUB_CLIENT_ID=your_id',
      );
    }
    final verifier = generatePkceCodeVerifier();
    await _secureStorage.writeKey(
      SecureStorageKeys.oauthCodeVerifier,
      verifier,
    );
    final url = buildAuthorizeUrl(verifier);
    _logger.debug('Opening GitHub OAuth authorize URL');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const GithubOAuthFailure('Could not open browser for GitHub login');
    }
  }

  Future<void> handleOAuthCallback(Uri uri) async {
    if (uri.scheme != 'cursormc' || uri.host != 'oauth') {
      return;
    }
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const GithubOAuthFailure('Missing authorization code');
    }
    final verifier =
        await _secureStorage.readKey(SecureStorageKeys.oauthCodeVerifier);
    if (verifier == null || verifier.isEmpty) {
      throw const GithubOAuthFailure('Missing PKCE verifier');
    }
    await _exchangeCode(code, verifier);
    await _secureStorage.deleteKey(SecureStorageKeys.oauthCodeVerifier);
  }

  Future<void> _exchangeCode(String code, String verifier) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        'https://github.com/login/oauth/access_token',
        data: {
          'client_id': GithubConfig.clientId,
          'code': code,
          'code_verifier': verifier,
          'redirect_uri': GithubConfig.redirectUri,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );
      final data = response.data;
      final token = data?['access_token'] as String?;
      if (token == null || token.isEmpty) {
        final error = data?['error_description'] as String? ??
            data?['error'] as String? ??
            'Token exchange failed';
        throw GithubOAuthFailure(error);
      }
      await _secureStorage.writeKey(
        SecureStorageKeys.githubAccessToken,
        token,
      );
      _logger.debug('GitHub OAuth token stored');
    } on DioException catch (e) {
      throw GithubOAuthFailure(e.message ?? 'Token exchange failed');
    }
  }
}

final githubAuthServiceProvider = Provider<GithubAuthService>((ref) {
  return GithubAuthService(
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});
