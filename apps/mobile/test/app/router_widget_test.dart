import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/app/router.dart';
import 'package:cursor_mobile_commander/app/theme.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';

class _InMemorySecureStorage implements SecureStorageService {
  final Map<String, String> _values = {};

  @override
  Future<void> deleteKey(String key) async => _values.remove(key);

  @override
  Future<String?> readKey(String key) async => _values[key];

  @override
  Future<void> writeKey(String key, String value) async => _values[key] = value;
}

void main() {
  testWidgets('shows onboarding when no API key is stored', (tester) async {
    final storage = _InMemorySecureStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(storage),
        ],
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
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('shows projects tab when API key is stored', (tester) async {
    final storage = _InMemorySecureStorage();
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_test_key');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(storage),
        ],
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
  });
}
