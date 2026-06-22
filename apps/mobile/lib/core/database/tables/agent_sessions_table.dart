import 'package:drift/drift.dart';

@DataClassName('AgentSessionRow')
class AgentSessions extends Table {
  TextColumn get agentId => text()();

  TextColumn get projectId => text()();

  TextColumn get name => text()();

  TextColumn get status => text()();

  TextColumn get latestRunId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get tags => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {agentId};
}
