import 'package:fpdart/fpdart.dart';

import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_model.dart';

/// Authentication and key management contract.
abstract interface class AuthRepository {
  Future<bool> hasCursorKey();

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
