import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/key_setup_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  testWidgets('KeySetupScreen shows validate button and QR option', (tester) async {
    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.validateSession()).thenAnswer((_) async => false);

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseFutureProvider.overrideWith((ref) async => db),
          authRepositoryProvider.overrideWith((ref) async => mockRepo),
        ],
        child: const MaterialApp(home: KeySetupScreen()),
      ),
    );

    expect(find.text('Cursor API Key'), findsOneWidget);
    expect(find.text('Validate & continue'), findsOneWidget);
    expect(find.text('Scan QR code'), findsOneWidget);
  });
}
