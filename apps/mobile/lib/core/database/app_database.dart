import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:cursor_mobile_commander/core/database/migrations/0001_initial.dart';
import 'package:cursor_mobile_commander/core/database/tables/agent_sessions_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/chat_messages_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/diff_cache_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/github_cache_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/pinned_projects_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/queued_prompts_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/run_records_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/tool_call_logs_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/usage_records_table.dart';
import 'package:cursor_mobile_commander/core/database/tables/user_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserSettings,
    PinnedProjects,
    AgentSessions,
    RunRecords,
    ChatMessages,
    ToolCallLogs,
    UsageRecords,
    GithubCaches,
    DiffCaches,
    QueuedPrompts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file.
  static Future<AppDatabase> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'cursor_mobile_commander.db'));
    return AppDatabase(NativeDatabase.createInBackground(file));
  }

  /// In-memory database for tests.
  static AppDatabase inMemory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => migration0001Initial.version;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: migration0001Initial.onCreate,
        onUpgrade: migration0001Initial.onUpgrade,
      );

  /// Ensures a default settings row exists.
  Future<UserSetting> getOrCreateSettings() async {
    final existing = await select(userSettings).getSingleOrNull();
    if (existing != null) {
      return existing;
    }
    final id = await into(userSettings).insert(
      UserSettingsCompanion.insert(updatedAt: DateTime.now().toUtc()),
    );
    return (await (select(userSettings)..where((t) => t.id.equals(id)))
            .getSingle());
  }
}
