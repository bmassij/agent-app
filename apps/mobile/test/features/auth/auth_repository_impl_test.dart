import 'package:cursor_api_core/cursor_api_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_keys.dart';
import 'package:cursor_mobile_commander/core/storage/secure_storage_service.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_remote_source.dart';
import 'package:cursor_mobile_commander/features/auth/data/auth_repository_impl.dart';
import 'package:cursor_mobile_commander/features/auth/domain/auth_failure.dart';

class _MockAuthRemoteSource extends Mock implements AuthRemoteSource {}

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
  late AppDatabase db;
  late _InMemorySecureStorage storage;
  late _MockAuthRemoteSource remote;

  setUp(() {
    db = AppDatabase.inMemory();
    storage = _InMemorySecureStorage();
    remote = _MockAuthRemoteSource();
  });

  tearDown(() async {
    await db.close();
  });

  AuthRepositoryImpl repo() => AuthRepositoryImpl(
        secureStorage: storage,
        remoteSource: remote,
        database: db,
      );

  final me = CursorMeModel(
    apiKeyName: 'Test Key',
    userEmail: 'user@example.com',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  test('validateCursorKey rejects empty key', () async {
    final result = await repo().validateCursorKey('  ');
    result.fold(
      (failure) => expect(failure, isA<InvalidKeyFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('validateCursorKey returns me on success', () async {
    when(() => remote.fetchMe('cursor_valid')).thenAnswer((_) async => me);

    final result = await repo().validateCursorKey('cursor_valid');
    result.fold(
      (_) => fail('expected right'),
      (value) => expect(value, me),
    );
  });

  test('validateCursorKey maps CursorAuthError to InvalidKeyFailure', () async {
    when(() => remote.fetchMe(any())).thenThrow(const CursorAuthError());

    final result = await repo().validateCursorKey('cursor_bad');
    result.fold(
      (failure) => expect(failure, isA<InvalidKeyFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('validateCursorKey maps 401 to InvalidKeyFailure', () async {
    when(() => remote.fetchMe(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 401,
        ),
      ),
    );

    final result = await repo().validateCursorKey('cursor_bad');
    result.fold(
      (failure) => expect(failure, isA<InvalidKeyFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('validateCursorKey maps network errors', () async {
    when(() => remote.fetchMe(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/me'),
        type: DioExceptionType.connectionTimeout,
        message: 'timeout',
      ),
    );

    final result = await repo().validateCursorKey('cursor_key');
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('saveAndValidateCursorKey stores key in secure storage', () async {
    when(() => remote.fetchMe('cursor_save')).thenAnswer((_) async => me);

    final result = await repo().saveAndValidateCursorKey('cursor_save');
    result.fold(
      (_) => fail('expected right'),
      (_) {},
    );
    expect(
      await storage.readKey(SecureStorageKeys.cursorApiKey),
      'cursor_save',
    );
  });

  test('setBiometricEnabled updates database', () async {
    final result = await repo().setBiometricEnabled(true);
    result.fold(
      (_) => fail('expected right'),
      (_) {},
    );
    expect(await repo().isBiometricEnabled(), isTrue);
  });

  test('validateSession returns false when no key stored', () async {
    expect(await repo().validateSession(), isFalse);
  });

  test('validateSession returns true when stored key is valid', () async {
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_valid');
    when(() => remote.fetchMe('cursor_valid')).thenAnswer((_) async => me);

    expect(await repo().validateSession(), isTrue);
  });

  test('validateSession clears key and returns false on 401', () async {
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_bad');
    when(() => remote.fetchMe('cursor_bad')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 401,
        ),
      ),
    );

    expect(await repo().validateSession(), isFalse);
    expect(await storage.readKey(SecureStorageKeys.cursorApiKey), isNull);
  });

  test('validateSession allows offline when network fails', () async {
    await storage.writeKey(SecureStorageKeys.cursorApiKey, 'cursor_key');
    when(() => remote.fetchMe('cursor_key')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/me'),
        type: DioExceptionType.connectionTimeout,
        message: 'timeout',
      ),
    );

    expect(await repo().validateSession(), isTrue);
    expect(await storage.readKey(SecureStorageKeys.cursorApiKey), 'cursor_key');
  });
}
