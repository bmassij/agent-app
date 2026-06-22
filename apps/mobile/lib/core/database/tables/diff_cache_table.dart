import 'package:drift/drift.dart';

@DataClassName('DiffCacheRow')
class DiffCaches extends Table {
  TextColumn get prKey => text()();

  TextColumn get patchText => text()();

  IntColumn get fileCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {prKey};
}
