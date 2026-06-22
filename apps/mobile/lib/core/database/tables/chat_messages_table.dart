import 'package:drift/drift.dart';

@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  TextColumn get id => text()();

  TextColumn get runId => text()();

  TextColumn get role => text()();

  TextColumn get content => text()();

  TextColumn get eventType => text()();

  IntColumn get sequenceIndex => integer()();

  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
