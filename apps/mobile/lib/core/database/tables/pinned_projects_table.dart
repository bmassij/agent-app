import 'package:drift/drift.dart';

@DataClassName('PinnedProjectRow')
class PinnedProjects extends Table {
  TextColumn get id => text()();

  TextColumn get repoUrl => text()();

  TextColumn get owner => text()();

  TextColumn get name => text()();

  TextColumn get defaultBranch => text()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
