import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';

/// OS-backed secure storage for secrets (connections, tokens).
abstract interface class SecureStorageService {
  Future<String?> readKey(String key);
  Future<void> writeKey(String key, String value);
  Future<void> deleteKey(String key);

  /// Workspace connection token with dual-key read/write (M2).
  Future<String?> readCursorToken();

  Future<void> writeCursorToken(String value);

  Future<void> deleteCursorToken();

  /// GitHub integration token with dual-key read/write (M2).
  Future<String?> readGithubToken();

  Future<void> writeGithubToken(String value);

  Future<void> deleteGithubToken();
}

/// Default implementation using [FlutterSecureStorage].
class FlutterSecureStorageService implements SecureStorageService {
  const FlutterSecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readKey(String key) => _storage.read(key: key);

  @override
  Future<void> writeKey(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> deleteKey(String key) => _storage.delete(key: key);

  @override
  Future<String?> readCursorToken() async {
    final primary = await readKey(SecureStorageKeys.providerCursorToken);
    if (primary != null && primary.isNotEmpty) {
      return primary;
    }
    return readKey(SecureStorageKeys.cursorApiKey);
  }

  @override
  Future<void> writeCursorToken(String value) async {
    await writeKey(SecureStorageKeys.providerCursorToken, value);
    await writeKey(SecureStorageKeys.cursorApiKey, value);
  }

  @override
  Future<void> deleteCursorToken() async {
    await deleteKey(SecureStorageKeys.providerCursorToken);
    await deleteKey(SecureStorageKeys.cursorApiKey);
  }

  @override
  Future<String?> readGithubToken() async {
    final primary = await readKey(SecureStorageKeys.integrationGithubToken);
    if (primary != null && primary.isNotEmpty) {
      return primary;
    }
    return readKey(SecureStorageKeys.githubAccessToken);
  }

  @override
  Future<void> writeGithubToken(String value) async {
    await writeKey(SecureStorageKeys.integrationGithubToken, value);
    await writeKey(SecureStorageKeys.githubAccessToken, value);
  }

  @override
  Future<void> deleteGithubToken() async {
    await deleteKey(SecureStorageKeys.integrationGithubToken);
    await deleteKey(SecureStorageKeys.githubAccessToken);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const FlutterSecureStorageService(
    FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});
