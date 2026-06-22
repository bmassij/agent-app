import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import 'package:local_auth/local_auth.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/logging/app_logger.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_remote_source.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_model.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SecureStorageService secureStorage,
    required AuthRemoteSource remoteSource,
    required AppDatabase database,
    LocalAuthentication? localAuth,
    AppLogger? logger,
  })  : _secureStorage = secureStorage,
        _remote = remoteSource,
        _db = database,
        _localAuth = localAuth ?? LocalAuthentication(),
        _logger = logger ?? const AppLogger();

  final SecureStorageService _secureStorage;
  final AuthRemoteSource _remote;
  final AppDatabase _db;
  final LocalAuthentication _localAuth;
  final AppLogger _logger;

  @override
  Future<bool> hasCursorKey() async {
    final key = await _secureStorage.readKey(SecureStorageKeys.cursorApiKey);
    return key != null && key.isNotEmpty;
  }

  @override
  Future<bool> validateSession() async {
    final key = await _secureStorage.readKey(SecureStorageKeys.cursorApiKey);
    if (key == null || key.isEmpty) {
      return false;
    }
    final result = await validateCursorKey(key);
    return result.fold(
      (failure) async {
        if (failure is InvalidKeyFailure) {
          await clearCursorKey();
          return false;
        }
        return true;
      },
      (_) => true,
    );
  }

  @override
  Future<Either<AuthFailure, CursorMeModel>> validateCursorKey(
    String key,
  ) async {
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      return left(const InvalidKeyFailure('API key is required'));
    }
    try {
      final me = await _remote.fetchMe(trimmed);
      return right(me);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return left(const InvalidKeyFailure());
      }
      _logger.error('validateCursorKey network error', error: e);
      return left(NetworkFailure(e.message ?? 'Network error'));
    } catch (e) {
      _logger.error('validateCursorKey failed', error: e);
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, CursorMeModel>> saveAndValidateCursorKey(
    String key,
  ) async {
    final result = await validateCursorKey(key);
    return result.fold(
      left,
      (me) async {
        try {
          await _secureStorage.writeKey(
            SecureStorageKeys.cursorApiKey,
            key.trim(),
          );
          return right(me);
        } catch (e) {
          return left(StorageFailure(e.toString()));
        }
      },
    );
  }

  @override
  Future<void> clearCursorKey() async {
    await _secureStorage.deleteKey(SecureStorageKeys.cursorApiKey);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final settings = await _db.getOrCreateSettings();
    return settings.biometricEnabled;
  }

  @override
  Future<Either<AuthFailure, Unit>> setBiometricEnabled(bool enabled) async {
    try {
      final settings = await _db.getOrCreateSettings();
      await (_db.update(_db.userSettings)
            ..where((t) => t.id.equals(settings.id)))
          .write(
        UserSettingsCompanion(
          biometricEnabled: Value(enabled),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      return right(unit);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Unit>> authenticateWithBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!canCheck && !supported) {
        return left(
          const BiometricFailure('Biometrics not available on this device'),
        );
      }
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock Cursor Mobile Commander',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (!ok) {
        return left(const BiometricFailure());
      }
      return right(unit);
    } catch (e) {
      return left(BiometricFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasGithubToken() async {
    final token =
        await _secureStorage.readKey(SecureStorageKeys.githubAccessToken);
    return token != null && token.isNotEmpty;
  }
}
