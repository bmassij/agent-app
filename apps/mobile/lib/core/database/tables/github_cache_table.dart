import 'package:drift/drift.dart';

@DataClassName('GithubCacheRow')
class GithubCaches extends Table {
  TextColumn get cacheKey => text()();

  TextColumn get jsonPayload => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}
