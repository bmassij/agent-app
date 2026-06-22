import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/pin_repo_screen.dart';

void main() {
  testWidgets('PinRepoScreen shows URL fields and pin button', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseFutureProvider.overrideWith((ref) async => db),
        ],
        child: const MaterialApp(home: PinRepoScreen()),
      ),
    );

    expect(find.text('Pin Repository'), findsOneWidget);
    expect(find.text('Repository URL'), findsOneWidget);
    expect(find.text('Default branch'), findsOneWidget);
    expect(find.text('Pin repository'), findsOneWidget);
  });
}
