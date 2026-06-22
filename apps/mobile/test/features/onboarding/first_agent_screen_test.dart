import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/first_agent_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('FirstAgentScreen shows biometric finish options', (tester) async {
    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.setBiometricEnabled(any())).thenAnswer(
      (_) async => right(unit),
    );

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseFutureProvider.overrideWith((ref) async => db),
          authRepositoryProvider.overrideWith((ref) async => mockRepo),
        ],
        child: const MaterialApp(home: FirstAgentScreen()),
      ),
    );

    expect(find.text('Enable biometrics & finish'), findsOneWidget);
    expect(find.text('Finish without biometrics'), findsOneWidget);
  });
}
