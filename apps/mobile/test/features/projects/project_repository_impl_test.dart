import 'package:flutter_test/flutter_test.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/projects/data/project_repository_impl.dart';
import 'package:cursor_mobile_commander/features/projects/domain/project_failure.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  ProjectRepositoryImpl repo() => ProjectRepositoryImpl(database: db);

  test('pinFromUrl rejects invalid URL', () async {
    final result = await repo().pinFromUrl(
      repoUrl: 'not-a-url',
      defaultBranch: 'main',
    );
    result.fold(
      (failure) => expect(failure, isA<InvalidRepoUrlFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('pinFromUrl rejects URL without owner/repo', () async {
    final result = await repo().pinFromUrl(
      repoUrl: 'https://github.com/onlyowner',
      defaultBranch: 'main',
    );
    result.fold(
      (failure) => expect(failure, isA<InvalidRepoUrlFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('pinFromUrl persists valid GitHub repository', () async {
    final result = await repo().pinFromUrl(
      repoUrl: 'https://github.com/org/repo',
      defaultBranch: 'develop',
    );
    result.fold(
      (_) => fail('expected right'),
      (_) {},
    );

    final rows = await db.select(db.pinnedProjects).get();
    expect(rows, hasLength(1));
    expect(rows.first.owner, 'org');
    expect(rows.first.name, 'repo');
    expect(rows.first.defaultBranch, 'develop');
  });
}
