import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/connect_github_screen.dart';

void main() {
  testWidgets('ConnectGithubScreen shows connect button', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseFutureProvider.overrideWith((ref) async => db),
        ],
        child: const MaterialApp(home: ConnectGithubScreen()),
      ),
    );

    expect(find.text('Connect GitHub'), findsWidgets);
    expect(find.text('Skip for now'), findsOneWidget);
  });
}
