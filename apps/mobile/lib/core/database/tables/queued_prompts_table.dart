import 'package:drift/drift.dart';

@DataClassName('QueuedPromptRow')
class QueuedPrompts extends Table {
  TextColumn get id => text()();

  TextColumn get agentId => text().nullable()();

  TextColumn get repoUrl => text()();

  TextColumn get promptText => text()();

  TextColumn get options => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
