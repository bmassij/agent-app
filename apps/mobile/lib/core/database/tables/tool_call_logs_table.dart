import 'package:drift/drift.dart';

@DataClassName('ToolCallLogRow')
class ToolCallLogs extends Table {
  TextColumn get callId => text()();

  TextColumn get runId => text()();

  TextColumn get toolName => text()();

  TextColumn get status => text()();

  TextColumn get argsJson => text()();

  TextColumn get resultJson => text().nullable()();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {callId};
}
