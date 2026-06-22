import 'package:drift/drift.dart';

@DataClassName('UsageRecordRow')
class UsageRecords extends Table {
  TextColumn get runId => text()();

  IntColumn get inputTokens => integer().withDefault(const Constant(0))();

  IntColumn get outputTokens => integer().withDefault(const Constant(0))();

  IntColumn get totalTokens => integer().withDefault(const Constant(0))();

  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {runId};
}
