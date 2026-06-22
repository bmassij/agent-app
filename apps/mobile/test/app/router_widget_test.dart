import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/app/router.dart';
import 'package:cursor_mobile_commander/app/theme.dart';
import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_remote_source.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';
import 'package:cursor_mobile_commander/features/onboarding/presentation/onboarding_provider.dart';

class _InMemorySecureStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> deleteKey(String key) async => _values.remove(key);

  @override
  Future<String?> readKey(String key) async => _values[key];

  @override
  Future<void> writeKey(String key, String value) async => _values[key] = value;
}

class _FakeOnboarding extends OnboardingNotifier {
  _FakeOnboarding(this._done);
  final bool _done;

  @override
  Future<bool> build() async => _done;
}

void main() {
  testWidgets('shows onboarding when no API key is stored', (tester) async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(_InMemorySecureStorage()),
        appDatabaseFutureProvider.overrideWith((ref) async => db),
        authRemoteSourceProvider.overrideWithValue(AuthRemoteSource()),
        onboardingCompletedProvider.overrideWith(() => _FakeOnboarding(false)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              theme: AppTheme.dark,
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Cursor Mobile Commander'), findsOneWidget);
    container.dispose();
  });

  testWidgets('shows projects tab when onboarded with API key', (tester) async {
    final storage = _InMemorySecureStorage();
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_test_key');
    final db = AppDatabase.inMemory();
    await db.getOrCreateSettings();
    final settings = await db.getOrCreateSettings();
    await (db.update(db.userSettings)..where((t) => t.id.equals(settings.id)))
        .write(
      UserSettingsCompanion(
        onboardingCompleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(storage),
        appDatabaseFutureProvider.overrideWith((ref) async => db),
        authRemoteSourceProvider.overrideWithValue(AuthRemoteSource()),
        onboardingCompletedProvider.overrideWith(() => _FakeOnboarding(true)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              theme: AppTheme.dark,
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Projects — coming in Sprint 5'), findsOneWidget);
    container.dispose();
  });
}
