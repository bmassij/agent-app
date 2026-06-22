import 'package:drift/drift.dart';

/// Migration from schema version 0 to 1 — initial tables.
class Migration0001Initial {
  int get version => 1;

  Future<void> onCreate(Migrator m) async {
    await m.createAll();
  }

  Future<void> onUpgrade(Migrator m, int from, int to) async {
    if (from < 1) {
      await onCreate(m);
    }
  }
}

final Migration0001Initial migration0001Initial = Migration0001Initial();
