import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_model.dart';

/// Authentication and key management contract.
abstract interface class AuthRepository {
  Future<bool> hasCursorKey();

  /// Validates stored key via GET /v1/me. Clears key on 401.
  /// Returns true on network errors when a key exists (offline access).
  Future<bool> validateSession();

  Future<Either<AuthFailure, CursorMeModel>> validateCursorKey(String key);

  Future<Either<AuthFailure, CursorMeModel>> saveAndValidateCursorKey(
    String key,
  );

  Future<void> clearCursorKey();

  Future<bool> isBiometricEnabled();

  Future<Either<AuthFailure, Unit>> setBiometricEnabled(bool enabled);

  Future<Either<AuthFailure, Unit>> authenticateWithBiometric();

  Future<bool> hasGithubToken();
}
