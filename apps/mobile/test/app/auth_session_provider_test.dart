import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/app/auth_session_provider.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';

class _InMemorySecureStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> deleteKey(String key) async => _values.remove(key);

  @override
  Future<String?> readKey(String key) async => _values[key];

  @override
  Future<void> writeKey(String key, String value) async => _values[key] = value;
}

void main() {
  test('authSessionProvider is false when no API key stored', () async {
    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(
          _InMemorySecureStorage(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final authenticated = await container.read(authSessionProvider.future);
    expect(authenticated, isFalse);
  });

  test('authSessionProvider is true when API key is stored', () async {
    final storage = _InMemorySecureStorage();
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_test_key');

    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);

    final authenticated = await container.read(authSessionProvider.future);
    expect(authenticated, isTrue);
  });
}
