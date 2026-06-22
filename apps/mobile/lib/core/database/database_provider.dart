import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/core/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override appDatabaseProvider in main.dart');
});

final appDatabaseFutureProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await AppDatabase.open();
  ref.onDispose(db.close);
  await db.getOrCreateSettings();
  return db;
});
