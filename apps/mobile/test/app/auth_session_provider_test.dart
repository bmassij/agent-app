import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_repository.dart';
import 'package:cursor_mobile_commander/features/auth/presentation/auth_provider.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  test('authSessionProvider is false when session invalid', () async {
    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.validateSession()).thenAnswer((_) async => false);

    final container = ProviderContainer(
      overrides: [
        appDatabaseFutureProvider.overrideWith((ref) async => db),
        authRepositoryProvider.overrideWith((ref) async => mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final authenticated = await container.read(authSessionProvider.future);
    expect(authenticated, isFalse);
  });

  test('authSessionProvider is true when session validates', () async {
    final mockRepo = _MockAuthRepository();
    when(() => mockRepo.validateSession()).thenAnswer((_) async => true);

    final container = ProviderContainer(
      overrides: [
        appDatabaseFutureProvider.overrideWith((ref) async => db),
        authRepositoryProvider.overrideWith((ref) async => mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final authenticated = await container.read(authSessionProvider.future);
    expect(authenticated, isTrue);
  });
}
