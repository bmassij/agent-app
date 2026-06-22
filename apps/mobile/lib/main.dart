import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cursor_mobile_commander/app/app.dart';
import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  await database.getOrCreateSettings();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseFutureProvider.overrideWith((ref) async {
          ref.onDispose(database.close);
          return database;
        }),
      ],
      child: const CommanderApp(),
    ),
  );
}
