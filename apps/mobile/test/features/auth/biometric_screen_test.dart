import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/biometric_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('BiometricScreen shows unlock prompt', (tester) async {
    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.authenticateWithBiometric()).thenAnswer(
      (_) async => left(const BiometricFailure('cancelled')),
    );

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseFutureProvider.overrideWith((ref) async => db),
          authRepositoryProvider.overrideWith((ref) async => mockRepo),
        ],
        child: MaterialApp(
          home: BiometricScreen(onUnlocked: () {}),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unlock with biometrics'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
