import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'package:cursor_mobile_commander/core/config/feature_flags.dart';
import 'package:cursor_mobile_commander/core/database/app_database.dart';
import 'package:cursor_mobile_commander/features/notifications/data/notification_service.dart';

const backgroundPollTaskName = 'poll_active_tasks';

/// Registers WorkManager periodic polling of active runs (M2).
class BackgroundTaskService {
  static Future<void> register() async {
    if (!FeatureFlags.backgroundPollingEnabled) {
      return;
    }

    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      backgroundPollTaskName,
      backgroundPollTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, _) async {
    if (taskName != backgroundPollTaskName) {
      return false;
    }
    try {
      final db = await AppDatabase.open();
      final runs = await db.select(db.runRecords).get();
      final active = runs.where((r) {
        final status = r.status.toLowerCase();
        return status == 'running' ||
            status == 'creating' ||
            status == 'pending';
      });
      if (active.isEmpty) {
        await db.close();
        return true;
      }

      final notifications =
          NotificationService(FlutterLocalNotificationsPlugin());
      await notifications.initialize();
      await notifications.showTaskComplete(
        title: 'Aivance',
        body: '${active.length} task(s) still in progress',
        id: taskName.hashCode,
      );
      await db.close();
      return true;
    } catch (_) {
      return false;
    }
  });
}
