import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_remote_source.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_repository_impl.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';

final authRemoteSourceProvider = Provider<AuthRemoteSource>((ref) {
  return AuthRemoteSource();
});

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final db = await ref.watch(appDatabaseFutureProvider.future);
  return AuthRepositoryImpl(
    secureStorage: ref.watch(secureStorageServiceProvider),
    remoteSource: ref.watch(authRemoteSourceProvider),
    database: db,
  );
});

/// Whether a Cursor API key is stored in secure storage.
final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, bool>(AuthSessionNotifier.new);

class AuthSessionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = await ref.watch(authRepositoryProvider.future);
    return repo.hasCursorKey();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

/// Biometric unlock for the current app session.
final biometricUnlockedProvider =
    NotifierProvider<BiometricUnlockedNotifier, bool>(
  BiometricUnlockedNotifier.new,
);

class BiometricUnlockedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}

/// Key validation / save action state.
final keySetupProvider =
    AsyncNotifierProvider<KeySetupNotifier, Option<AuthFailure>>(
  KeySetupNotifier.new,
);

class KeySetupNotifier extends AsyncNotifier<Option<AuthFailure>> {
  @override
  Future<Option<AuthFailure>> build() async => const None();

  Future<bool> validateAndSave(String key) async {
    state = const AsyncLoading();
    final repo = await ref.read(authRepositoryProvider.future);
    final result = await repo.saveAndValidateCursorKey(key);
    return await result.fold(
      (failure) async {
        state = AsyncData(Some(failure));
        return false;
      },
      (_) async {
        state = const AsyncData(None());
        await ref.read(authSessionProvider.notifier).refresh();
        return true;
      },
    );
  }
}
