import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// OS-backed secure storage for secrets (API keys, tokens).
abstract interface class SecureStorageService {
  Future<String?> readKey(String key);
  Future<void> writeKey(String key, String value);
  Future<void> deleteKey(String key);
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
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return const FlutterSecureStorageService(
    FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});
