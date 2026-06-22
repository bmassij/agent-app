import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';

/// Whether a Cursor API key is present in secure storage.
///
/// Used by the router auth guard. Sprint 2 adds validation via GET /v1/me.
final authSessionProvider = AsyncNotifierProvider<AuthSessionNotifier, bool>(
  AuthSessionNotifier.new,
);

class AuthSessionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final storage = ref.read(secureStorageServiceProvider);
    final key = await storage.readKey(SecureStorageKeys.cursorApiKey);
    return key != null && key.isNotEmpty;
  }

  /// Re-check secure storage after key setup (Sprint 2).
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}
