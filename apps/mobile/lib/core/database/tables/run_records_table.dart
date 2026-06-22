import 'package:drift/drift.dart';

@DataClassName('RunRecordRow')
class RunRecords extends Table {
  TextColumn get runId => text()();

  TextColumn get agentId => text()();

  TextColumn get status => text()();

  TextColumn get resultText => text().nullable()();

  IntColumn get durationMs => integer().nullable()();

  TextColumn get prUrl => text().nullable()();

  TextColumn get branch => text().nullable()();

  TextColumn get errorCode => text().nullable()();

  TextColumn get errorMessage => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {runId};
}
