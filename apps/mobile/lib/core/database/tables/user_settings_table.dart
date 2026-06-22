import 'package:drift/drift.dart';

/// App settings. Secrets live in secure storage — only opaque refs here.
@DataClassName('UserSetting')
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get cursorKeyRef =>
      text().withDefault(const Constant('secure'))();

  TextColumn get githubTokenRef =>
      text().withDefault(const Constant('secure'))();

  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  TextColumn get defaultModelId => text().nullable()();

  IntColumn get pollIntervalSeconds =>
      integer().withDefault(const Constant(30))();

  DateTimeColumn get updatedAt => dateTime()();
}
