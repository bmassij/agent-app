import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:cursor_mobile_commander/app/app.dart';
import 'package:cursor_mobile_commander/core/config/feature_flags.dart';
import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/core/database/database_provider.dart';
import 'package:cursor_mobile_commander/features/notifications/data/background_task_service.dart';
import 'package:cursor_mobile_commander/features/notifications/data/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.open();
  await database.getOrCreateSettings();

  if (FeatureFlags.notificationsEnabled) {
    await NotificationService(FlutterLocalNotificationsPlugin()).initialize();
  }

  await BackgroundTaskService.register();

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
