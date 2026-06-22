// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cursorKeyRefMeta =
      const VerificationMeta('cursorKeyRef');
  @override
  late final GeneratedColumn<String> cursorKeyRef = GeneratedColumn<String>(
      'cursor_key_ref', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('secure'));
  static const VerificationMeta _githubTokenRefMeta =
      const VerificationMeta('githubTokenRef');
  @override
  late final GeneratedColumn<String> githubTokenRef = GeneratedColumn<String>(
      'github_token_ref', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('secure'));
  static const VerificationMeta _biometricEnabledMeta =
      const VerificationMeta('biometricEnabled');
  @override
  late final GeneratedColumn<bool> biometricEnabled = GeneratedColumn<bool>(
      'biometric_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("biometric_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _onboardingCompletedMeta =
      const VerificationMeta('onboardingCompleted');
  @override
  late final GeneratedColumn<bool> onboardingCompleted = GeneratedColumn<bool>(
      'onboarding_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("onboarding_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _defaultModelIdMeta =
      const VerificationMeta('defaultModelId');
  @override
  late final GeneratedColumn<String> defaultModelId = GeneratedColumn<String>(
      'default_model_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pollIntervalSecondsMeta =
      const VerificationMeta('pollIntervalSeconds');
  @override
  late final GeneratedColumn<int> pollIntervalSeconds = GeneratedColumn<int>(
      'poll_interval_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(30));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cursorKeyRef,
        githubTokenRef,
        biometricEnabled,
        onboardingCompleted,
        defaultModelId,
        pollIntervalSeconds,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cursor_key_ref')) {
      context.handle(
          _cursorKeyRefMeta,
          cursorKeyRef.isAcceptableOrUnknown(
              data['cursor_key_ref']!, _cursorKeyRefMeta));
    }
    if (data.containsKey('github_token_ref')) {
      context.handle(
          _githubTokenRefMeta,
          githubTokenRef.isAcceptableOrUnknown(
              data['github_token_ref']!, _githubTokenRefMeta));
    }
    if (data.containsKey('biometric_enabled')) {
      context.handle(
          _biometricEnabledMeta,
          biometricEnabled.isAcceptableOrUnknown(
              data['biometric_enabled']!, _biometricEnabledMeta));
    }
    if (data.containsKey('onboarding_completed')) {
      context.handle(
          _onboardingCompletedMeta,
          onboardingCompleted.isAcceptableOrUnknown(
              data['onboarding_completed']!, _onboardingCompletedMeta));
    }
    if (data.containsKey('default_model_id')) {
      context.handle(
          _defaultModelIdMeta,
          defaultModelId.isAcceptableOrUnknown(
              data['default_model_id']!, _defaultModelIdMeta));
    }
    if (data.containsKey('poll_interval_seconds')) {
      context.handle(
          _pollIntervalSecondsMeta,
          pollIntervalSeconds.isAcceptableOrUnknown(
              data['poll_interval_seconds']!, _pollIntervalSecondsMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cursorKeyRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cursor_key_ref'])!,
      githubTokenRef: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}github_token_ref'])!,
      biometricEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}biometric_enabled'])!,
      onboardingCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}onboarding_completed'])!,
      defaultModelId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_model_id']),
      pollIntervalSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}poll_interval_seconds'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int id;
  final String cursorKeyRef;
  final String githubTokenRef;
  final bool biometricEnabled;
  final bool onboardingCompleted;
  final String? defaultModelId;
  final int pollIntervalSeconds;
  final DateTime updatedAt;
  const UserSetting(
      {required this.id,
      required this.cursorKeyRef,
      required this.githubTokenRef,
      required this.biometricEnabled,
      required this.onboardingCompleted,
      this.defaultModelId,
      required this.pollIntervalSeconds,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cursor_key_ref'] = Variable<String>(cursorKeyRef);
    map['github_token_ref'] = Variable<String>(githubTokenRef);
    map['biometric_enabled'] = Variable<bool>(biometricEnabled);
    map['onboarding_completed'] = Variable<bool>(onboardingCompleted);
    if (!nullToAbsent || defaultModelId != null) {
      map['default_model_id'] = Variable<String>(defaultModelId);
    }
    map['poll_interval_seconds'] = Variable<int>(pollIntervalSeconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      cursorKeyRef: Value(cursorKeyRef),
      githubTokenRef: Value(githubTokenRef),
      biometricEnabled: Value(biometricEnabled),
      onboardingCompleted: Value(onboardingCompleted),
      defaultModelId: defaultModelId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultModelId),
      pollIntervalSeconds: Value(pollIntervalSeconds),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      cursorKeyRef: serializer.fromJson<String>(json['cursorKeyRef']),
      githubTokenRef: serializer.fromJson<String>(json['githubTokenRef']),
      biometricEnabled: serializer.fromJson<bool>(json['biometricEnabled']),
      onboardingCompleted:
          serializer.fromJson<bool>(json['onboardingCompleted']),
      defaultModelId: serializer.fromJson<String?>(json['defaultModelId']),
      pollIntervalSeconds:
          serializer.fromJson<int>(json['pollIntervalSeconds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursorKeyRef': serializer.toJson<String>(cursorKeyRef),
      'githubTokenRef': serializer.toJson<String>(githubTokenRef),
      'biometricEnabled': serializer.toJson<bool>(biometricEnabled),
      'onboardingCompleted': serializer.toJson<bool>(onboardingCompleted),
      'defaultModelId': serializer.toJson<String?>(defaultModelId),
      'pollIntervalSeconds': serializer.toJson<int>(pollIntervalSeconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserSetting copyWith(
          {int? id,
          String? cursorKeyRef,
          String? githubTokenRef,
          bool? biometricEnabled,
          bool? onboardingCompleted,
          Value<String?> defaultModelId = const Value.absent(),
          int? pollIntervalSeconds,
          DateTime? updatedAt}) =>
      UserSetting(
        id: id ?? this.id,
        cursorKeyRef: cursorKeyRef ?? this.cursorKeyRef,
        githubTokenRef: githubTokenRef ?? this.githubTokenRef,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        defaultModelId:
            defaultModelId.present ? defaultModelId.value : this.defaultModelId,
        pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      id: data.id.present ? data.id.value : this.id,
      cursorKeyRef: data.cursorKeyRef.present
          ? data.cursorKeyRef.value
          : this.cursorKeyRef,
      githubTokenRef: data.githubTokenRef.present
          ? data.githubTokenRef.value
          : this.githubTokenRef,
      biometricEnabled: data.biometricEnabled.present
          ? data.biometricEnabled.value
          : this.biometricEnabled,
      onboardingCompleted: data.onboardingCompleted.present
          ? data.onboardingCompleted.value
          : this.onboardingCompleted,
      defaultModelId: data.defaultModelId.present
          ? data.defaultModelId.value
          : this.defaultModelId,
      pollIntervalSeconds: data.pollIntervalSeconds.present
          ? data.pollIntervalSeconds.value
          : this.pollIntervalSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('cursorKeyRef: $cursorKeyRef, ')
          ..write('githubTokenRef: $githubTokenRef, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('defaultModelId: $defaultModelId, ')
          ..write('pollIntervalSeconds: $pollIntervalSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cursorKeyRef,
      githubTokenRef,
      biometricEnabled,
      onboardingCompleted,
      defaultModelId,
      pollIntervalSeconds,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.cursorKeyRef == this.cursorKeyRef &&
          other.githubTokenRef == this.githubTokenRef &&
          other.biometricEnabled == this.biometricEnabled &&
          other.onboardingCompleted == this.onboardingCompleted &&
          other.defaultModelId == this.defaultModelId &&
          other.pollIntervalSeconds == this.pollIntervalSeconds &&
          other.updatedAt == this.updatedAt);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<String> cursorKeyRef;
  final Value<String> githubTokenRef;
  final Value<bool> biometricEnabled;
  final Value<bool> onboardingCompleted;
  final Value<String?> defaultModelId;
  final Value<int> pollIntervalSeconds;
  final Value<DateTime> updatedAt;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.cursorKeyRef = const Value.absent(),
    this.githubTokenRef = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.defaultModelId = const Value.absent(),
    this.pollIntervalSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.cursorKeyRef = const Value.absent(),
    this.githubTokenRef = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.onboardingCompleted = const Value.absent(),
    this.defaultModelId = const Value.absent(),
    this.pollIntervalSeconds = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<String>? cursorKeyRef,
    Expression<String>? githubTokenRef,
    Expression<bool>? biometricEnabled,
    Expression<bool>? onboardingCompleted,
    Expression<String>? defaultModelId,
    Expression<int>? pollIntervalSeconds,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursorKeyRef != null) 'cursor_key_ref': cursorKeyRef,
      if (githubTokenRef != null) 'github_token_ref': githubTokenRef,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      if (onboardingCompleted != null)
        'onboarding_completed': onboardingCompleted,
      if (defaultModelId != null) 'default_model_id': defaultModelId,
      if (pollIntervalSeconds != null)
        'poll_interval_seconds': pollIntervalSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? cursorKeyRef,
      Value<String>? githubTokenRef,
      Value<bool>? biometricEnabled,
      Value<bool>? onboardingCompleted,
      Value<String?>? defaultModelId,
      Value<int>? pollIntervalSeconds,
      Value<DateTime>? updatedAt}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      cursorKeyRef: cursorKeyRef ?? this.cursorKeyRef,
      githubTokenRef: githubTokenRef ?? this.githubTokenRef,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      defaultModelId: defaultModelId ?? this.defaultModelId,
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursorKeyRef.present) {
      map['cursor_key_ref'] = Variable<String>(cursorKeyRef.value);
    }
    if (githubTokenRef.present) {
      map['github_token_ref'] = Variable<String>(githubTokenRef.value);
    }
    if (biometricEnabled.present) {
      map['biometric_enabled'] = Variable<bool>(biometricEnabled.value);
    }
    if (onboardingCompleted.present) {
      map['onboarding_completed'] = Variable<bool>(onboardingCompleted.value);
    }
    if (defaultModelId.present) {
      map['default_model_id'] = Variable<String>(defaultModelId.value);
    }
    if (pollIntervalSeconds.present) {
      map['poll_interval_seconds'] = Variable<int>(pollIntervalSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('cursorKeyRef: $cursorKeyRef, ')
          ..write('githubTokenRef: $githubTokenRef, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('onboardingCompleted: $onboardingCompleted, ')
          ..write('defaultModelId: $defaultModelId, ')
          ..write('pollIntervalSeconds: $pollIntervalSeconds, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PinnedProjectsTable extends PinnedProjects
    with TableInfo<$PinnedProjectsTable, PinnedProjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _repoUrlMeta =
      const VerificationMeta('repoUrl');
  @override
  late final GeneratedColumn<String> repoUrl = GeneratedColumn<String>(
      'repo_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
      'owner', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultBranchMeta =
      const VerificationMeta('defaultBranch');
  @override
  late final GeneratedColumn<String> defaultBranch = GeneratedColumn<String>(
      'default_branch', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, repoUrl, owner, name, defaultBranch, sortOrder, lastSyncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_projects';
  @override
  VerificationContext validateIntegrity(Insertable<PinnedProjectRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('repo_url')) {
      context.handle(_repoUrlMeta,
          repoUrl.isAcceptableOrUnknown(data['repo_url']!, _repoUrlMeta));
    } else if (isInserting) {
      context.missing(_repoUrlMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
          _ownerMeta, owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta));
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_branch')) {
      context.handle(
          _defaultBranchMeta,
          defaultBranch.isAcceptableOrUnknown(
              data['default_branch']!, _defaultBranchMeta));
    } else if (isInserting) {
      context.missing(_defaultBranchMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PinnedProjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedProjectRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      repoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_url'])!,
      owner: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      defaultBranch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_branch'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $PinnedProjectsTable createAlias(String alias) {
    return $PinnedProjectsTable(attachedDatabase, alias);
  }
}

class PinnedProjectRow extends DataClass
    implements Insertable<PinnedProjectRow> {
  final String id;
  final String repoUrl;
  final String owner;
  final String name;
  final String defaultBranch;
  final int sortOrder;
  final DateTime? lastSyncedAt;
  const PinnedProjectRow(
      {required this.id,
      required this.repoUrl,
      required this.owner,
      required this.name,
      required this.defaultBranch,
      required this.sortOrder,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['repo_url'] = Variable<String>(repoUrl);
    map['owner'] = Variable<String>(owner);
    map['name'] = Variable<String>(name);
    map['default_branch'] = Variable<String>(defaultBranch);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  PinnedProjectsCompanion toCompanion(bool nullToAbsent) {
    return PinnedProjectsCompanion(
      id: Value(id),
      repoUrl: Value(repoUrl),
      owner: Value(owner),
      name: Value(name),
      defaultBranch: Value(defaultBranch),
      sortOrder: Value(sortOrder),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory PinnedProjectRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedProjectRow(
      id: serializer.fromJson<String>(json['id']),
      repoUrl: serializer.fromJson<String>(json['repoUrl']),
      owner: serializer.fromJson<String>(json['owner']),
      name: serializer.fromJson<String>(json['name']),
      defaultBranch: serializer.fromJson<String>(json['defaultBranch']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'repoUrl': serializer.toJson<String>(repoUrl),
      'owner': serializer.toJson<String>(owner),
      'name': serializer.toJson<String>(name),
      'defaultBranch': serializer.toJson<String>(defaultBranch),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  PinnedProjectRow copyWith(
          {String? id,
          String? repoUrl,
          String? owner,
          String? name,
          String? defaultBranch,
          int? sortOrder,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      PinnedProjectRow(
        id: id ?? this.id,
        repoUrl: repoUrl ?? this.repoUrl,
        owner: owner ?? this.owner,
        name: name ?? this.name,
        defaultBranch: defaultBranch ?? this.defaultBranch,
        sortOrder: sortOrder ?? this.sortOrder,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  PinnedProjectRow copyWithCompanion(PinnedProjectsCompanion data) {
    return PinnedProjectRow(
      id: data.id.present ? data.id.value : this.id,
      repoUrl: data.repoUrl.present ? data.repoUrl.value : this.repoUrl,
      owner: data.owner.present ? data.owner.value : this.owner,
      name: data.name.present ? data.name.value : this.name,
      defaultBranch: data.defaultBranch.present
          ? data.defaultBranch.value
          : this.defaultBranch,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedProjectRow(')
          ..write('id: $id, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('owner: $owner, ')
          ..write('name: $name, ')
          ..write('defaultBranch: $defaultBranch, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, repoUrl, owner, name, defaultBranch, sortOrder, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedProjectRow &&
          other.id == this.id &&
          other.repoUrl == this.repoUrl &&
          other.owner == this.owner &&
          other.name == this.name &&
          other.defaultBranch == this.defaultBranch &&
          other.sortOrder == this.sortOrder &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class PinnedProjectsCompanion extends UpdateCompanion<PinnedProjectRow> {
  final Value<String> id;
  final Value<String> repoUrl;
  final Value<String> owner;
  final Value<String> name;
  final Value<String> defaultBranch;
  final Value<int> sortOrder;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const PinnedProjectsCompanion({
    this.id = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.owner = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultBranch = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinnedProjectsCompanion.insert({
    required String id,
    required String repoUrl,
    required String owner,
    required String name,
    required String defaultBranch,
    this.sortOrder = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        repoUrl = Value(repoUrl),
        owner = Value(owner),
        name = Value(name),
        defaultBranch = Value(defaultBranch);
  static Insertable<PinnedProjectRow> custom({
    Expression<String>? id,
    Expression<String>? repoUrl,
    Expression<String>? owner,
    Expression<String>? name,
    Expression<String>? defaultBranch,
    Expression<int>? sortOrder,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (repoUrl != null) 'repo_url': repoUrl,
      if (owner != null) 'owner': owner,
      if (name != null) 'name': name,
      if (defaultBranch != null) 'default_branch': defaultBranch,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinnedProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? repoUrl,
      Value<String>? owner,
      Value<String>? name,
      Value<String>? defaultBranch,
      Value<int>? sortOrder,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return PinnedProjectsCompanion(
      id: id ?? this.id,
      repoUrl: repoUrl ?? this.repoUrl,
      owner: owner ?? this.owner,
      name: name ?? this.name,
      defaultBranch: defaultBranch ?? this.defaultBranch,
      sortOrder: sortOrder ?? this.sortOrder,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (repoUrl.present) {
      map['repo_url'] = Variable<String>(repoUrl.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultBranch.present) {
      map['default_branch'] = Variable<String>(defaultBranch.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedProjectsCompanion(')
          ..write('id: $id, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('owner: $owner, ')
          ..write('name: $name, ')
          ..write('defaultBranch: $defaultBranch, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentSessionsTable extends AgentSessions
    with TableInfo<$AgentSessionsTable, AgentSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _agentIdMeta =
      const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
      'agent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latestRunIdMeta =
      const VerificationMeta('latestRunId');
  @override
  late final GeneratedColumn<String> latestRunId = GeneratedColumn<String>(
      'latest_run_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  @override
  List<GeneratedColumn> get $columns => [
        agentId,
        projectId,
        name,
        status,
        latestRunId,
        createdAt,
        updatedAt,
        tags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<AgentSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta,
          agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('latest_run_id')) {
      context.handle(
          _latestRunIdMeta,
          latestRunId.isAcceptableOrUnknown(
              data['latest_run_id']!, _latestRunIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {agentId};
  @override
  AgentSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentSessionRow(
      agentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      latestRunId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}latest_run_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
    );
  }

  @override
  $AgentSessionsTable createAlias(String alias) {
    return $AgentSessionsTable(attachedDatabase, alias);
  }
}

class AgentSessionRow extends DataClass implements Insertable<AgentSessionRow> {
  final String agentId;
  final String projectId;
  final String name;
  final String status;
  final String? latestRunId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String tags;
  const AgentSessionRow(
      {required this.agentId,
      required this.projectId,
      required this.name,
      required this.status,
      this.latestRunId,
      required this.createdAt,
      required this.updatedAt,
      required this.tags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['agent_id'] = Variable<String>(agentId);
    map['project_id'] = Variable<String>(projectId);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || latestRunId != null) {
      map['latest_run_id'] = Variable<String>(latestRunId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  AgentSessionsCompanion toCompanion(bool nullToAbsent) {
    return AgentSessionsCompanion(
      agentId: Value(agentId),
      projectId: Value(projectId),
      name: Value(name),
      status: Value(status),
      latestRunId: latestRunId == null && nullToAbsent
          ? const Value.absent()
          : Value(latestRunId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tags: Value(tags),
    );
  }

  factory AgentSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentSessionRow(
      agentId: serializer.fromJson<String>(json['agentId']),
      projectId: serializer.fromJson<String>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      latestRunId: serializer.fromJson<String?>(json['latestRunId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'agentId': serializer.toJson<String>(agentId),
      'projectId': serializer.toJson<String>(projectId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'latestRunId': serializer.toJson<String?>(latestRunId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tags': serializer.toJson<String>(tags),
    };
  }

  AgentSessionRow copyWith(
          {String? agentId,
          String? projectId,
          String? name,
          String? status,
          Value<String?> latestRunId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? tags}) =>
      AgentSessionRow(
        agentId: agentId ?? this.agentId,
        projectId: projectId ?? this.projectId,
        name: name ?? this.name,
        status: status ?? this.status,
        latestRunId: latestRunId.present ? latestRunId.value : this.latestRunId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        tags: tags ?? this.tags,
      );
  AgentSessionRow copyWithCompanion(AgentSessionsCompanion data) {
    return AgentSessionRow(
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      latestRunId:
          data.latestRunId.present ? data.latestRunId.value : this.latestRunId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentSessionRow(')
          ..write('agentId: $agentId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('latestRunId: $latestRunId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(agentId, projectId, name, status, latestRunId,
      createdAt, updatedAt, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentSessionRow &&
          other.agentId == this.agentId &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.status == this.status &&
          other.latestRunId == this.latestRunId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tags == this.tags);
}

class AgentSessionsCompanion extends UpdateCompanion<AgentSessionRow> {
  final Value<String> agentId;
  final Value<String> projectId;
  final Value<String> name;
  final Value<String> status;
  final Value<String?> latestRunId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> tags;
  final Value<int> rowid;
  const AgentSessionsCompanion({
    this.agentId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.latestRunId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentSessionsCompanion.insert({
    required String agentId,
    required String projectId,
    required String name,
    required String status,
    this.latestRunId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : agentId = Value(agentId),
        projectId = Value(projectId),
        name = Value(name),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AgentSessionRow> custom({
    Expression<String>? agentId,
    Expression<String>? projectId,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? latestRunId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (agentId != null) 'agent_id': agentId,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (latestRunId != null) 'latest_run_id': latestRunId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentSessionsCompanion copyWith(
      {Value<String>? agentId,
      Value<String>? projectId,
      Value<String>? name,
      Value<String>? status,
      Value<String?>? latestRunId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? tags,
      Value<int>? rowid}) {
    return AgentSessionsCompanion(
      agentId: agentId ?? this.agentId,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      latestRunId: latestRunId ?? this.latestRunId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (latestRunId.present) {
      map['latest_run_id'] = Variable<String>(latestRunId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentSessionsCompanion(')
          ..write('agentId: $agentId, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('latestRunId: $latestRunId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunRecordsTable extends RunRecords
    with TableInfo<$RunRecordsTable, RunRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _agentIdMeta =
      const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
      'agent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultTextMeta =
      const VerificationMeta('resultText');
  @override
  late final GeneratedColumn<String> resultText = GeneratedColumn<String>(
      'result_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _prUrlMeta = const VerificationMeta('prUrl');
  @override
  late final GeneratedColumn<String> prUrl = GeneratedColumn<String>(
      'pr_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
      'branch', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorCodeMeta =
      const VerificationMeta('errorCode');
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
      'error_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        runId,
        agentId,
        status,
        resultText,
        durationMs,
        prUrl,
        branch,
        errorCode,
        errorMessage,
        createdAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run_records';
  @override
  VerificationContext validateIntegrity(Insertable<RunRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta,
          agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    } else if (isInserting) {
      context.missing(_agentIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('result_text')) {
      context.handle(
          _resultTextMeta,
          resultText.isAcceptableOrUnknown(
              data['result_text']!, _resultTextMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('pr_url')) {
      context.handle(
          _prUrlMeta, prUrl.isAcceptableOrUnknown(data['pr_url']!, _prUrlMeta));
    }
    if (data.containsKey('branch')) {
      context.handle(_branchMeta,
          branch.isAcceptableOrUnknown(data['branch']!, _branchMeta));
    }
    if (data.containsKey('error_code')) {
      context.handle(_errorCodeMeta,
          errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId};
  @override
  RunRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunRecordRow(
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      agentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      resultText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_text']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      prUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pr_url']),
      branch: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch']),
      errorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_code']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $RunRecordsTable createAlias(String alias) {
    return $RunRecordsTable(attachedDatabase, alias);
  }
}

class RunRecordRow extends DataClass implements Insertable<RunRecordRow> {
  final String runId;
  final String agentId;
  final String status;
  final String? resultText;
  final int? durationMs;
  final String? prUrl;
  final String? branch;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  const RunRecordRow(
      {required this.runId,
      required this.agentId,
      required this.status,
      this.resultText,
      this.durationMs,
      this.prUrl,
      this.branch,
      this.errorCode,
      this.errorMessage,
      required this.createdAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['agent_id'] = Variable<String>(agentId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resultText != null) {
      map['result_text'] = Variable<String>(resultText);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || prUrl != null) {
      map['pr_url'] = Variable<String>(prUrl);
    }
    if (!nullToAbsent || branch != null) {
      map['branch'] = Variable<String>(branch);
    }
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  RunRecordsCompanion toCompanion(bool nullToAbsent) {
    return RunRecordsCompanion(
      runId: Value(runId),
      agentId: Value(agentId),
      status: Value(status),
      resultText: resultText == null && nullToAbsent
          ? const Value.absent()
          : Value(resultText),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      prUrl:
          prUrl == null && nullToAbsent ? const Value.absent() : Value(prUrl),
      branch:
          branch == null && nullToAbsent ? const Value.absent() : Value(branch),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory RunRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunRecordRow(
      runId: serializer.fromJson<String>(json['runId']),
      agentId: serializer.fromJson<String>(json['agentId']),
      status: serializer.fromJson<String>(json['status']),
      resultText: serializer.fromJson<String?>(json['resultText']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      prUrl: serializer.fromJson<String?>(json['prUrl']),
      branch: serializer.fromJson<String?>(json['branch']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'agentId': serializer.toJson<String>(agentId),
      'status': serializer.toJson<String>(status),
      'resultText': serializer.toJson<String?>(resultText),
      'durationMs': serializer.toJson<int?>(durationMs),
      'prUrl': serializer.toJson<String?>(prUrl),
      'branch': serializer.toJson<String?>(branch),
      'errorCode': serializer.toJson<String?>(errorCode),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  RunRecordRow copyWith(
          {String? runId,
          String? agentId,
          String? status,
          Value<String?> resultText = const Value.absent(),
          Value<int?> durationMs = const Value.absent(),
          Value<String?> prUrl = const Value.absent(),
          Value<String?> branch = const Value.absent(),
          Value<String?> errorCode = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      RunRecordRow(
        runId: runId ?? this.runId,
        agentId: agentId ?? this.agentId,
        status: status ?? this.status,
        resultText: resultText.present ? resultText.value : this.resultText,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        prUrl: prUrl.present ? prUrl.value : this.prUrl,
        branch: branch.present ? branch.value : this.branch,
        errorCode: errorCode.present ? errorCode.value : this.errorCode,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  RunRecordRow copyWithCompanion(RunRecordsCompanion data) {
    return RunRecordRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      status: data.status.present ? data.status.value : this.status,
      resultText:
          data.resultText.present ? data.resultText.value : this.resultText,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      prUrl: data.prUrl.present ? data.prUrl.value : this.prUrl,
      branch: data.branch.present ? data.branch.value : this.branch,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunRecordRow(')
          ..write('runId: $runId, ')
          ..write('agentId: $agentId, ')
          ..write('status: $status, ')
          ..write('resultText: $resultText, ')
          ..write('durationMs: $durationMs, ')
          ..write('prUrl: $prUrl, ')
          ..write('branch: $branch, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      runId,
      agentId,
      status,
      resultText,
      durationMs,
      prUrl,
      branch,
      errorCode,
      errorMessage,
      createdAt,
      completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunRecordRow &&
          other.runId == this.runId &&
          other.agentId == this.agentId &&
          other.status == this.status &&
          other.resultText == this.resultText &&
          other.durationMs == this.durationMs &&
          other.prUrl == this.prUrl &&
          other.branch == this.branch &&
          other.errorCode == this.errorCode &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class RunRecordsCompanion extends UpdateCompanion<RunRecordRow> {
  final Value<String> runId;
  final Value<String> agentId;
  final Value<String> status;
  final Value<String?> resultText;
  final Value<int?> durationMs;
  final Value<String?> prUrl;
  final Value<String?> branch;
  final Value<String?> errorCode;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const RunRecordsCompanion({
    this.runId = const Value.absent(),
    this.agentId = const Value.absent(),
    this.status = const Value.absent(),
    this.resultText = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.prUrl = const Value.absent(),
    this.branch = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunRecordsCompanion.insert({
    required String runId,
    required String agentId,
    required String status,
    this.resultText = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.prUrl = const Value.absent(),
    this.branch = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : runId = Value(runId),
        agentId = Value(agentId),
        status = Value(status),
        createdAt = Value(createdAt);
  static Insertable<RunRecordRow> custom({
    Expression<String>? runId,
    Expression<String>? agentId,
    Expression<String>? status,
    Expression<String>? resultText,
    Expression<int>? durationMs,
    Expression<String>? prUrl,
    Expression<String>? branch,
    Expression<String>? errorCode,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (agentId != null) 'agent_id': agentId,
      if (status != null) 'status': status,
      if (resultText != null) 'result_text': resultText,
      if (durationMs != null) 'duration_ms': durationMs,
      if (prUrl != null) 'pr_url': prUrl,
      if (branch != null) 'branch': branch,
      if (errorCode != null) 'error_code': errorCode,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunRecordsCompanion copyWith(
      {Value<String>? runId,
      Value<String>? agentId,
      Value<String>? status,
      Value<String?>? resultText,
      Value<int?>? durationMs,
      Value<String?>? prUrl,
      Value<String?>? branch,
      Value<String?>? errorCode,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return RunRecordsCompanion(
      runId: runId ?? this.runId,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      resultText: resultText ?? this.resultText,
      durationMs: durationMs ?? this.durationMs,
      prUrl: prUrl ?? this.prUrl,
      branch: branch ?? this.branch,
      errorCode: errorCode ?? this.errorCode,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resultText.present) {
      map['result_text'] = Variable<String>(resultText.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (prUrl.present) {
      map['pr_url'] = Variable<String>(prUrl.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunRecordsCompanion(')
          ..write('runId: $runId, ')
          ..write('agentId: $agentId, ')
          ..write('status: $status, ')
          ..write('resultText: $resultText, ')
          ..write('durationMs: $durationMs, ')
          ..write('prUrl: $prUrl, ')
          ..write('branch: $branch, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sequenceIndexMeta =
      const VerificationMeta('sequenceIndex');
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
      'sequence_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, runId, role, content, eventType, sequenceIndex, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
          _sequenceIndexMeta,
          sequenceIndex.isAcceptableOrUnknown(
              data['sequence_index']!, _sequenceIndexMeta));
    } else if (isInserting) {
      context.missing(_sequenceIndexMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      sequenceIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sequence_index'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  final String id;
  final String runId;
  final String role;
  final String content;
  final String eventType;
  final int sequenceIndex;
  final DateTime timestamp;
  const ChatMessageRow(
      {required this.id,
      required this.runId,
      required this.role,
      required this.content,
      required this.eventType,
      required this.sequenceIndex,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['run_id'] = Variable<String>(runId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['event_type'] = Variable<String>(eventType);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      runId: Value(runId),
      role: Value(role),
      content: Value(content),
      eventType: Value(eventType),
      sequenceIndex: Value(sequenceIndex),
      timestamp: Value(timestamp),
    );
  }

  factory ChatMessageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      runId: serializer.fromJson<String>(json['runId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      eventType: serializer.fromJson<String>(json['eventType']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'runId': serializer.toJson<String>(runId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'eventType': serializer.toJson<String>(eventType),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  ChatMessageRow copyWith(
          {String? id,
          String? runId,
          String? role,
          String? content,
          String? eventType,
          int? sequenceIndex,
          DateTime? timestamp}) =>
      ChatMessageRow(
        id: id ?? this.id,
        runId: runId ?? this.runId,
        role: role ?? this.role,
        content: content ?? this.content,
        eventType: eventType ?? this.eventType,
        sequenceIndex: sequenceIndex ?? this.sequenceIndex,
        timestamp: timestamp ?? this.timestamp,
      );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('eventType: $eventType, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, runId, role, content, eventType, sequenceIndex, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.role == this.role &&
          other.content == this.content &&
          other.eventType == this.eventType &&
          other.sequenceIndex == this.sequenceIndex &&
          other.timestamp == this.timestamp);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<String> id;
  final Value<String> runId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> eventType;
  final Value<int> sequenceIndex;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.eventType = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String runId,
    required String role,
    required String content,
    required String eventType,
    required int sequenceIndex,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        runId = Value(runId),
        role = Value(role),
        content = Value(content),
        eventType = Value(eventType),
        sequenceIndex = Value(sequenceIndex),
        timestamp = Value(timestamp);
  static Insertable<ChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? runId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? eventType,
    Expression<int>? sequenceIndex,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (eventType != null) 'event_type': eventType,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? runId,
      Value<String>? role,
      Value<String>? content,
      Value<String>? eventType,
      Value<int>? sequenceIndex,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      role: role ?? this.role,
      content: content ?? this.content,
      eventType: eventType ?? this.eventType,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('eventType: $eventType, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToolCallLogsTable extends ToolCallLogs
    with TableInfo<$ToolCallLogsTable, ToolCallLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToolCallLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<String> callId = GeneratedColumn<String>(
      'call_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _argsJsonMeta =
      const VerificationMeta('argsJson');
  @override
  late final GeneratedColumn<String> argsJson = GeneratedColumn<String>(
      'args_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultJsonMeta =
      const VerificationMeta('resultJson');
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
      'result_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        callId,
        runId,
        toolName,
        status,
        argsJson,
        resultJson,
        startedAt,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tool_call_logs';
  @override
  VerificationContext validateIntegrity(Insertable<ToolCallLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('call_id')) {
      context.handle(_callIdMeta,
          callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta));
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('args_json')) {
      context.handle(_argsJsonMeta,
          argsJson.isAcceptableOrUnknown(data['args_json']!, _argsJsonMeta));
    } else if (isInserting) {
      context.missing(_argsJsonMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
          _resultJsonMeta,
          resultJson.isAcceptableOrUnknown(
              data['result_json']!, _resultJsonMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {callId};
  @override
  ToolCallLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToolCallLogRow(
      callId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}call_id'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      argsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}args_json'])!,
      resultJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_json']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
    );
  }

  @override
  $ToolCallLogsTable createAlias(String alias) {
    return $ToolCallLogsTable(attachedDatabase, alias);
  }
}

class ToolCallLogRow extends DataClass implements Insertable<ToolCallLogRow> {
  final String callId;
  final String runId;
  final String toolName;
  final String status;
  final String argsJson;
  final String? resultJson;
  final DateTime startedAt;
  final DateTime? completedAt;
  const ToolCallLogRow(
      {required this.callId,
      required this.runId,
      required this.toolName,
      required this.status,
      required this.argsJson,
      this.resultJson,
      required this.startedAt,
      this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['call_id'] = Variable<String>(callId);
    map['run_id'] = Variable<String>(runId);
    map['tool_name'] = Variable<String>(toolName);
    map['status'] = Variable<String>(status);
    map['args_json'] = Variable<String>(argsJson);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ToolCallLogsCompanion toCompanion(bool nullToAbsent) {
    return ToolCallLogsCompanion(
      callId: Value(callId),
      runId: Value(runId),
      toolName: Value(toolName),
      status: Value(status),
      argsJson: Value(argsJson),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ToolCallLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToolCallLogRow(
      callId: serializer.fromJson<String>(json['callId']),
      runId: serializer.fromJson<String>(json['runId']),
      toolName: serializer.fromJson<String>(json['toolName']),
      status: serializer.fromJson<String>(json['status']),
      argsJson: serializer.fromJson<String>(json['argsJson']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'callId': serializer.toJson<String>(callId),
      'runId': serializer.toJson<String>(runId),
      'toolName': serializer.toJson<String>(toolName),
      'status': serializer.toJson<String>(status),
      'argsJson': serializer.toJson<String>(argsJson),
      'resultJson': serializer.toJson<String?>(resultJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ToolCallLogRow copyWith(
          {String? callId,
          String? runId,
          String? toolName,
          String? status,
          String? argsJson,
          Value<String?> resultJson = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> completedAt = const Value.absent()}) =>
      ToolCallLogRow(
        callId: callId ?? this.callId,
        runId: runId ?? this.runId,
        toolName: toolName ?? this.toolName,
        status: status ?? this.status,
        argsJson: argsJson ?? this.argsJson,
        resultJson: resultJson.present ? resultJson.value : this.resultJson,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
      );
  ToolCallLogRow copyWithCompanion(ToolCallLogsCompanion data) {
    return ToolCallLogRow(
      callId: data.callId.present ? data.callId.value : this.callId,
      runId: data.runId.present ? data.runId.value : this.runId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      status: data.status.present ? data.status.value : this.status,
      argsJson: data.argsJson.present ? data.argsJson.value : this.argsJson,
      resultJson:
          data.resultJson.present ? data.resultJson.value : this.resultJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToolCallLogRow(')
          ..write('callId: $callId, ')
          ..write('runId: $runId, ')
          ..write('toolName: $toolName, ')
          ..write('status: $status, ')
          ..write('argsJson: $argsJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(callId, runId, toolName, status, argsJson,
      resultJson, startedAt, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToolCallLogRow &&
          other.callId == this.callId &&
          other.runId == this.runId &&
          other.toolName == this.toolName &&
          other.status == this.status &&
          other.argsJson == this.argsJson &&
          other.resultJson == this.resultJson &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class ToolCallLogsCompanion extends UpdateCompanion<ToolCallLogRow> {
  final Value<String> callId;
  final Value<String> runId;
  final Value<String> toolName;
  final Value<String> status;
  final Value<String> argsJson;
  final Value<String?> resultJson;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ToolCallLogsCompanion({
    this.callId = const Value.absent(),
    this.runId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.status = const Value.absent(),
    this.argsJson = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ToolCallLogsCompanion.insert({
    required String callId,
    required String runId,
    required String toolName,
    required String status,
    required String argsJson,
    this.resultJson = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : callId = Value(callId),
        runId = Value(runId),
        toolName = Value(toolName),
        status = Value(status),
        argsJson = Value(argsJson),
        startedAt = Value(startedAt);
  static Insertable<ToolCallLogRow> custom({
    Expression<String>? callId,
    Expression<String>? runId,
    Expression<String>? toolName,
    Expression<String>? status,
    Expression<String>? argsJson,
    Expression<String>? resultJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (callId != null) 'call_id': callId,
      if (runId != null) 'run_id': runId,
      if (toolName != null) 'tool_name': toolName,
      if (status != null) 'status': status,
      if (argsJson != null) 'args_json': argsJson,
      if (resultJson != null) 'result_json': resultJson,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ToolCallLogsCompanion copyWith(
      {Value<String>? callId,
      Value<String>? runId,
      Value<String>? toolName,
      Value<String>? status,
      Value<String>? argsJson,
      Value<String?>? resultJson,
      Value<DateTime>? startedAt,
      Value<DateTime?>? completedAt,
      Value<int>? rowid}) {
    return ToolCallLogsCompanion(
      callId: callId ?? this.callId,
      runId: runId ?? this.runId,
      toolName: toolName ?? this.toolName,
      status: status ?? this.status,
      argsJson: argsJson ?? this.argsJson,
      resultJson: resultJson ?? this.resultJson,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (callId.present) {
      map['call_id'] = Variable<String>(callId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (argsJson.present) {
      map['args_json'] = Variable<String>(argsJson.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToolCallLogsCompanion(')
          ..write('callId: $callId, ')
          ..write('runId: $runId, ')
          ..write('toolName: $toolName, ')
          ..write('status: $status, ')
          ..write('argsJson: $argsJson, ')
          ..write('resultJson: $resultJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageRecordsTable extends UsageRecords
    with TableInfo<$UsageRecordsTable, UsageRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inputTokensMeta =
      const VerificationMeta('inputTokens');
  @override
  late final GeneratedColumn<int> inputTokens = GeneratedColumn<int>(
      'input_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _outputTokensMeta =
      const VerificationMeta('outputTokens');
  @override
  late final GeneratedColumn<int> outputTokens = GeneratedColumn<int>(
      'output_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalTokensMeta =
      const VerificationMeta('totalTokens');
  @override
  late final GeneratedColumn<int> totalTokens = GeneratedColumn<int>(
      'total_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [runId, inputTokens, outputTokens, totalTokens, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_records';
  @override
  VerificationContext validateIntegrity(Insertable<UsageRecordRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('input_tokens')) {
      context.handle(
          _inputTokensMeta,
          inputTokens.isAcceptableOrUnknown(
              data['input_tokens']!, _inputTokensMeta));
    }
    if (data.containsKey('output_tokens')) {
      context.handle(
          _outputTokensMeta,
          outputTokens.isAcceptableOrUnknown(
              data['output_tokens']!, _outputTokensMeta));
    }
    if (data.containsKey('total_tokens')) {
      context.handle(
          _totalTokensMeta,
          totalTokens.isAcceptableOrUnknown(
              data['total_tokens']!, _totalTokensMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {runId};
  @override
  UsageRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageRecordRow(
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      inputTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}input_tokens'])!,
      outputTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}output_tokens'])!,
      totalTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_tokens'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $UsageRecordsTable createAlias(String alias) {
    return $UsageRecordsTable(attachedDatabase, alias);
  }
}

class UsageRecordRow extends DataClass implements Insertable<UsageRecordRow> {
  final String runId;
  final int inputTokens;
  final int outputTokens;
  final int totalTokens;
  final DateTime recordedAt;
  const UsageRecordRow(
      {required this.runId,
      required this.inputTokens,
      required this.outputTokens,
      required this.totalTokens,
      required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['run_id'] = Variable<String>(runId);
    map['input_tokens'] = Variable<int>(inputTokens);
    map['output_tokens'] = Variable<int>(outputTokens);
    map['total_tokens'] = Variable<int>(totalTokens);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  UsageRecordsCompanion toCompanion(bool nullToAbsent) {
    return UsageRecordsCompanion(
      runId: Value(runId),
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
      totalTokens: Value(totalTokens),
      recordedAt: Value(recordedAt),
    );
  }

  factory UsageRecordRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageRecordRow(
      runId: serializer.fromJson<String>(json['runId']),
      inputTokens: serializer.fromJson<int>(json['inputTokens']),
      outputTokens: serializer.fromJson<int>(json['outputTokens']),
      totalTokens: serializer.fromJson<int>(json['totalTokens']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'runId': serializer.toJson<String>(runId),
      'inputTokens': serializer.toJson<int>(inputTokens),
      'outputTokens': serializer.toJson<int>(outputTokens),
      'totalTokens': serializer.toJson<int>(totalTokens),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  UsageRecordRow copyWith(
          {String? runId,
          int? inputTokens,
          int? outputTokens,
          int? totalTokens,
          DateTime? recordedAt}) =>
      UsageRecordRow(
        runId: runId ?? this.runId,
        inputTokens: inputTokens ?? this.inputTokens,
        outputTokens: outputTokens ?? this.outputTokens,
        totalTokens: totalTokens ?? this.totalTokens,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  UsageRecordRow copyWithCompanion(UsageRecordsCompanion data) {
    return UsageRecordRow(
      runId: data.runId.present ? data.runId.value : this.runId,
      inputTokens:
          data.inputTokens.present ? data.inputTokens.value : this.inputTokens,
      outputTokens: data.outputTokens.present
          ? data.outputTokens.value
          : this.outputTokens,
      totalTokens:
          data.totalTokens.present ? data.totalTokens.value : this.totalTokens,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageRecordRow(')
          ..write('runId: $runId, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(runId, inputTokens, outputTokens, totalTokens, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageRecordRow &&
          other.runId == this.runId &&
          other.inputTokens == this.inputTokens &&
          other.outputTokens == this.outputTokens &&
          other.totalTokens == this.totalTokens &&
          other.recordedAt == this.recordedAt);
}

class UsageRecordsCompanion extends UpdateCompanion<UsageRecordRow> {
  final Value<String> runId;
  final Value<int> inputTokens;
  final Value<int> outputTokens;
  final Value<int> totalTokens;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const UsageRecordsCompanion({
    this.runId = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsageRecordsCompanion.insert({
    required String runId,
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  })  : runId = Value(runId),
        recordedAt = Value(recordedAt);
  static Insertable<UsageRecordRow> custom({
    Expression<String>? runId,
    Expression<int>? inputTokens,
    Expression<int>? outputTokens,
    Expression<int>? totalTokens,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (runId != null) 'run_id': runId,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      if (totalTokens != null) 'total_tokens': totalTokens,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsageRecordsCompanion copyWith(
      {Value<String>? runId,
      Value<int>? inputTokens,
      Value<int>? outputTokens,
      Value<int>? totalTokens,
      Value<DateTime>? recordedAt,
      Value<int>? rowid}) {
    return UsageRecordsCompanion(
      runId: runId ?? this.runId,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (inputTokens.present) {
      map['input_tokens'] = Variable<int>(inputTokens.value);
    }
    if (outputTokens.present) {
      map['output_tokens'] = Variable<int>(outputTokens.value);
    }
    if (totalTokens.present) {
      map['total_tokens'] = Variable<int>(totalTokens.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageRecordsCompanion(')
          ..write('runId: $runId, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GithubCachesTable extends GithubCaches
    with TableInfo<$GithubCachesTable, GithubCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GithubCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta =
      const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
      'cache_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsonPayloadMeta =
      const VerificationMeta('jsonPayload');
  @override
  late final GeneratedColumn<String> jsonPayload = GeneratedColumn<String>(
      'json_payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [cacheKey, jsonPayload, createdAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'github_caches';
  @override
  VerificationContext validateIntegrity(Insertable<GithubCacheRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(_cacheKeyMeta,
          cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta));
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('json_payload')) {
      context.handle(
          _jsonPayloadMeta,
          jsonPayload.isAcceptableOrUnknown(
              data['json_payload']!, _jsonPayloadMeta));
    } else if (isInserting) {
      context.missing(_jsonPayloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  GithubCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GithubCacheRow(
      cacheKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cache_key'])!,
      jsonPayload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}json_payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
    );
  }

  @override
  $GithubCachesTable createAlias(String alias) {
    return $GithubCachesTable(attachedDatabase, alias);
  }
}

class GithubCacheRow extends DataClass implements Insertable<GithubCacheRow> {
  final String cacheKey;
  final String jsonPayload;
  final DateTime createdAt;
  final DateTime expiresAt;
  const GithubCacheRow(
      {required this.cacheKey,
      required this.jsonPayload,
      required this.createdAt,
      required this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['json_payload'] = Variable<String>(jsonPayload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  GithubCachesCompanion toCompanion(bool nullToAbsent) {
    return GithubCachesCompanion(
      cacheKey: Value(cacheKey),
      jsonPayload: Value(jsonPayload),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory GithubCacheRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GithubCacheRow(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      jsonPayload: serializer.fromJson<String>(json['jsonPayload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'jsonPayload': serializer.toJson<String>(jsonPayload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  GithubCacheRow copyWith(
          {String? cacheKey,
          String? jsonPayload,
          DateTime? createdAt,
          DateTime? expiresAt}) =>
      GithubCacheRow(
        cacheKey: cacheKey ?? this.cacheKey,
        jsonPayload: jsonPayload ?? this.jsonPayload,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  GithubCacheRow copyWithCompanion(GithubCachesCompanion data) {
    return GithubCacheRow(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      jsonPayload:
          data.jsonPayload.present ? data.jsonPayload.value : this.jsonPayload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GithubCacheRow(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, jsonPayload, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GithubCacheRow &&
          other.cacheKey == this.cacheKey &&
          other.jsonPayload == this.jsonPayload &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class GithubCachesCompanion extends UpdateCompanion<GithubCacheRow> {
  final Value<String> cacheKey;
  final Value<String> jsonPayload;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const GithubCachesCompanion({
    this.cacheKey = const Value.absent(),
    this.jsonPayload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GithubCachesCompanion.insert({
    required String cacheKey,
    required String jsonPayload,
    required DateTime createdAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  })  : cacheKey = Value(cacheKey),
        jsonPayload = Value(jsonPayload),
        createdAt = Value(createdAt),
        expiresAt = Value(expiresAt);
  static Insertable<GithubCacheRow> custom({
    Expression<String>? cacheKey,
    Expression<String>? jsonPayload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (jsonPayload != null) 'json_payload': jsonPayload,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GithubCachesCompanion copyWith(
      {Value<String>? cacheKey,
      Value<String>? jsonPayload,
      Value<DateTime>? createdAt,
      Value<DateTime>? expiresAt,
      Value<int>? rowid}) {
    return GithubCachesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      jsonPayload: jsonPayload ?? this.jsonPayload,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (jsonPayload.present) {
      map['json_payload'] = Variable<String>(jsonPayload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GithubCachesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonPayload: $jsonPayload, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiffCachesTable extends DiffCaches
    with TableInfo<$DiffCachesTable, DiffCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiffCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prKeyMeta = const VerificationMeta('prKey');
  @override
  late final GeneratedColumn<String> prKey = GeneratedColumn<String>(
      'pr_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patchTextMeta =
      const VerificationMeta('patchText');
  @override
  late final GeneratedColumn<String> patchText = GeneratedColumn<String>(
      'patch_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileCountMeta =
      const VerificationMeta('fileCount');
  @override
  late final GeneratedColumn<int> fileCount = GeneratedColumn<int>(
      'file_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [prKey, patchText, fileCount, createdAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diff_caches';
  @override
  VerificationContext validateIntegrity(Insertable<DiffCacheRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pr_key')) {
      context.handle(
          _prKeyMeta, prKey.isAcceptableOrUnknown(data['pr_key']!, _prKeyMeta));
    } else if (isInserting) {
      context.missing(_prKeyMeta);
    }
    if (data.containsKey('patch_text')) {
      context.handle(_patchTextMeta,
          patchText.isAcceptableOrUnknown(data['patch_text']!, _patchTextMeta));
    } else if (isInserting) {
      context.missing(_patchTextMeta);
    }
    if (data.containsKey('file_count')) {
      context.handle(_fileCountMeta,
          fileCount.isAcceptableOrUnknown(data['file_count']!, _fileCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prKey};
  @override
  DiffCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiffCacheRow(
      prKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pr_key'])!,
      patchText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patch_text'])!,
      fileCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expires_at'])!,
    );
  }

  @override
  $DiffCachesTable createAlias(String alias) {
    return $DiffCachesTable(attachedDatabase, alias);
  }
}

class DiffCacheRow extends DataClass implements Insertable<DiffCacheRow> {
  final String prKey;
  final String patchText;
  final int fileCount;
  final DateTime createdAt;
  final DateTime expiresAt;
  const DiffCacheRow(
      {required this.prKey,
      required this.patchText,
      required this.fileCount,
      required this.createdAt,
      required this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pr_key'] = Variable<String>(prKey);
    map['patch_text'] = Variable<String>(patchText);
    map['file_count'] = Variable<int>(fileCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  DiffCachesCompanion toCompanion(bool nullToAbsent) {
    return DiffCachesCompanion(
      prKey: Value(prKey),
      patchText: Value(patchText),
      fileCount: Value(fileCount),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory DiffCacheRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiffCacheRow(
      prKey: serializer.fromJson<String>(json['prKey']),
      patchText: serializer.fromJson<String>(json['patchText']),
      fileCount: serializer.fromJson<int>(json['fileCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prKey': serializer.toJson<String>(prKey),
      'patchText': serializer.toJson<String>(patchText),
      'fileCount': serializer.toJson<int>(fileCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  DiffCacheRow copyWith(
          {String? prKey,
          String? patchText,
          int? fileCount,
          DateTime? createdAt,
          DateTime? expiresAt}) =>
      DiffCacheRow(
        prKey: prKey ?? this.prKey,
        patchText: patchText ?? this.patchText,
        fileCount: fileCount ?? this.fileCount,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );
  DiffCacheRow copyWithCompanion(DiffCachesCompanion data) {
    return DiffCacheRow(
      prKey: data.prKey.present ? data.prKey.value : this.prKey,
      patchText: data.patchText.present ? data.patchText.value : this.patchText,
      fileCount: data.fileCount.present ? data.fileCount.value : this.fileCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiffCacheRow(')
          ..write('prKey: $prKey, ')
          ..write('patchText: $patchText, ')
          ..write('fileCount: $fileCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(prKey, patchText, fileCount, createdAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiffCacheRow &&
          other.prKey == this.prKey &&
          other.patchText == this.patchText &&
          other.fileCount == this.fileCount &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class DiffCachesCompanion extends UpdateCompanion<DiffCacheRow> {
  final Value<String> prKey;
  final Value<String> patchText;
  final Value<int> fileCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const DiffCachesCompanion({
    this.prKey = const Value.absent(),
    this.patchText = const Value.absent(),
    this.fileCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiffCachesCompanion.insert({
    required String prKey,
    required String patchText,
    this.fileCount = const Value.absent(),
    required DateTime createdAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  })  : prKey = Value(prKey),
        patchText = Value(patchText),
        createdAt = Value(createdAt),
        expiresAt = Value(expiresAt);
  static Insertable<DiffCacheRow> custom({
    Expression<String>? prKey,
    Expression<String>? patchText,
    Expression<int>? fileCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prKey != null) 'pr_key': prKey,
      if (patchText != null) 'patch_text': patchText,
      if (fileCount != null) 'file_count': fileCount,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiffCachesCompanion copyWith(
      {Value<String>? prKey,
      Value<String>? patchText,
      Value<int>? fileCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? expiresAt,
      Value<int>? rowid}) {
    return DiffCachesCompanion(
      prKey: prKey ?? this.prKey,
      patchText: patchText ?? this.patchText,
      fileCount: fileCount ?? this.fileCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prKey.present) {
      map['pr_key'] = Variable<String>(prKey.value);
    }
    if (patchText.present) {
      map['patch_text'] = Variable<String>(patchText.value);
    }
    if (fileCount.present) {
      map['file_count'] = Variable<int>(fileCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiffCachesCompanion(')
          ..write('prKey: $prKey, ')
          ..write('patchText: $patchText, ')
          ..write('fileCount: $fileCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueuedPromptsTable extends QueuedPrompts
    with TableInfo<$QueuedPromptsTable, QueuedPromptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueuedPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _agentIdMeta =
      const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
      'agent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _repoUrlMeta =
      const VerificationMeta('repoUrl');
  @override
  late final GeneratedColumn<String> repoUrl = GeneratedColumn<String>(
      'repo_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _promptTextMeta =
      const VerificationMeta('promptText');
  @override
  late final GeneratedColumn<String> promptText = GeneratedColumn<String>(
      'prompt_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, agentId, repoUrl, promptText, options, createdAt, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queued_prompts';
  @override
  VerificationContext validateIntegrity(Insertable<QueuedPromptRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta,
          agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    }
    if (data.containsKey('repo_url')) {
      context.handle(_repoUrlMeta,
          repoUrl.isAcceptableOrUnknown(data['repo_url']!, _repoUrlMeta));
    } else if (isInserting) {
      context.missing(_repoUrlMeta);
    }
    if (data.containsKey('prompt_text')) {
      context.handle(
          _promptTextMeta,
          promptText.isAcceptableOrUnknown(
              data['prompt_text']!, _promptTextMeta));
    } else if (isInserting) {
      context.missing(_promptTextMeta);
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueuedPromptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueuedPromptRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      agentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_id']),
      repoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repo_url'])!,
      promptText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prompt_text'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $QueuedPromptsTable createAlias(String alias) {
    return $QueuedPromptsTable(attachedDatabase, alias);
  }
}

class QueuedPromptRow extends DataClass implements Insertable<QueuedPromptRow> {
  final String id;
  final String? agentId;
  final String repoUrl;
  final String promptText;
  final String options;
  final DateTime createdAt;
  final String status;
  const QueuedPromptRow(
      {required this.id,
      this.agentId,
      required this.repoUrl,
      required this.promptText,
      required this.options,
      required this.createdAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || agentId != null) {
      map['agent_id'] = Variable<String>(agentId);
    }
    map['repo_url'] = Variable<String>(repoUrl);
    map['prompt_text'] = Variable<String>(promptText);
    map['options'] = Variable<String>(options);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  QueuedPromptsCompanion toCompanion(bool nullToAbsent) {
    return QueuedPromptsCompanion(
      id: Value(id),
      agentId: agentId == null && nullToAbsent
          ? const Value.absent()
          : Value(agentId),
      repoUrl: Value(repoUrl),
      promptText: Value(promptText),
      options: Value(options),
      createdAt: Value(createdAt),
      status: Value(status),
    );
  }

  factory QueuedPromptRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueuedPromptRow(
      id: serializer.fromJson<String>(json['id']),
      agentId: serializer.fromJson<String?>(json['agentId']),
      repoUrl: serializer.fromJson<String>(json['repoUrl']),
      promptText: serializer.fromJson<String>(json['promptText']),
      options: serializer.fromJson<String>(json['options']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'agentId': serializer.toJson<String?>(agentId),
      'repoUrl': serializer.toJson<String>(repoUrl),
      'promptText': serializer.toJson<String>(promptText),
      'options': serializer.toJson<String>(options),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'status': serializer.toJson<String>(status),
    };
  }

  QueuedPromptRow copyWith(
          {String? id,
          Value<String?> agentId = const Value.absent(),
          String? repoUrl,
          String? promptText,
          String? options,
          DateTime? createdAt,
          String? status}) =>
      QueuedPromptRow(
        id: id ?? this.id,
        agentId: agentId.present ? agentId.value : this.agentId,
        repoUrl: repoUrl ?? this.repoUrl,
        promptText: promptText ?? this.promptText,
        options: options ?? this.options,
        createdAt: createdAt ?? this.createdAt,
        status: status ?? this.status,
      );
  QueuedPromptRow copyWithCompanion(QueuedPromptsCompanion data) {
    return QueuedPromptRow(
      id: data.id.present ? data.id.value : this.id,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      repoUrl: data.repoUrl.present ? data.repoUrl.value : this.repoUrl,
      promptText:
          data.promptText.present ? data.promptText.value : this.promptText,
      options: data.options.present ? data.options.value : this.options,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueuedPromptRow(')
          ..write('id: $id, ')
          ..write('agentId: $agentId, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('promptText: $promptText, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, agentId, repoUrl, promptText, options, createdAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueuedPromptRow &&
          other.id == this.id &&
          other.agentId == this.agentId &&
          other.repoUrl == this.repoUrl &&
          other.promptText == this.promptText &&
          other.options == this.options &&
          other.createdAt == this.createdAt &&
          other.status == this.status);
}

class QueuedPromptsCompanion extends UpdateCompanion<QueuedPromptRow> {
  final Value<String> id;
  final Value<String?> agentId;
  final Value<String> repoUrl;
  final Value<String> promptText;
  final Value<String> options;
  final Value<DateTime> createdAt;
  final Value<String> status;
  final Value<int> rowid;
  const QueuedPromptsCompanion({
    this.id = const Value.absent(),
    this.agentId = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.promptText = const Value.absent(),
    this.options = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueuedPromptsCompanion.insert({
    required String id,
    this.agentId = const Value.absent(),
    required String repoUrl,
    required String promptText,
    this.options = const Value.absent(),
    required DateTime createdAt,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        repoUrl = Value(repoUrl),
        promptText = Value(promptText),
        createdAt = Value(createdAt);
  static Insertable<QueuedPromptRow> custom({
    Expression<String>? id,
    Expression<String>? agentId,
    Expression<String>? repoUrl,
    Expression<String>? promptText,
    Expression<String>? options,
    Expression<DateTime>? createdAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (agentId != null) 'agent_id': agentId,
      if (repoUrl != null) 'repo_url': repoUrl,
      if (promptText != null) 'prompt_text': promptText,
      if (options != null) 'options': options,
      if (createdAt != null) 'created_at': createdAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueuedPromptsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? agentId,
      Value<String>? repoUrl,
      Value<String>? promptText,
      Value<String>? options,
      Value<DateTime>? createdAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return QueuedPromptsCompanion(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      repoUrl: repoUrl ?? this.repoUrl,
      promptText: promptText ?? this.promptText,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (repoUrl.present) {
      map['repo_url'] = Variable<String>(repoUrl.value);
    }
    if (promptText.present) {
      map['prompt_text'] = Variable<String>(promptText.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueuedPromptsCompanion(')
          ..write('id: $id, ')
          ..write('agentId: $agentId, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('promptText: $promptText, ')
          ..write('options: $options, ')
          ..write('createdAt: $createdAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $PinnedProjectsTable pinnedProjects = $PinnedProjectsTable(this);
  late final $AgentSessionsTable agentSessions = $AgentSessionsTable(this);
  late final $RunRecordsTable runRecords = $RunRecordsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ToolCallLogsTable toolCallLogs = $ToolCallLogsTable(this);
  late final $UsageRecordsTable usageRecords = $UsageRecordsTable(this);
  late final $GithubCachesTable githubCaches = $GithubCachesTable(this);
  late final $DiffCachesTable diffCaches = $DiffCachesTable(this);
  late final $QueuedPromptsTable queuedPrompts = $QueuedPromptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userSettings,
        pinnedProjects,
        agentSessions,
        runRecords,
        chatMessages,
        toolCallLogs,
        usageRecords,
        githubCaches,
        diffCaches,
        queuedPrompts
      ];
}

typedef $$UserSettingsTableCreateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<int> id,
  Value<String> cursorKeyRef,
  Value<String> githubTokenRef,
  Value<bool> biometricEnabled,
  Value<bool> onboardingCompleted,
  Value<String?> defaultModelId,
  Value<int> pollIntervalSeconds,
  required DateTime updatedAt,
});
typedef $$UserSettingsTableUpdateCompanionBuilder = UserSettingsCompanion
    Function({
  Value<int> id,
  Value<String> cursorKeyRef,
  Value<String> githubTokenRef,
  Value<bool> biometricEnabled,
  Value<bool> onboardingCompleted,
  Value<String?> defaultModelId,
  Value<int> pollIntervalSeconds,
  Value<DateTime> updatedAt,
});

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cursorKeyRef => $composableBuilder(
      column: $table.cursorKeyRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get githubTokenRef => $composableBuilder(
      column: $table.githubTokenRef,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultModelId => $composableBuilder(
      column: $table.defaultModelId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pollIntervalSeconds => $composableBuilder(
      column: $table.pollIntervalSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cursorKeyRef => $composableBuilder(
      column: $table.cursorKeyRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get githubTokenRef => $composableBuilder(
      column: $table.githubTokenRef,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultModelId => $composableBuilder(
      column: $table.defaultModelId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pollIntervalSeconds => $composableBuilder(
      column: $table.pollIntervalSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cursorKeyRef => $composableBuilder(
      column: $table.cursorKeyRef, builder: (column) => column);

  GeneratedColumn<String> get githubTokenRef => $composableBuilder(
      column: $table.githubTokenRef, builder: (column) => column);

  GeneratedColumn<bool> get biometricEnabled => $composableBuilder(
      column: $table.biometricEnabled, builder: (column) => column);

  GeneratedColumn<bool> get onboardingCompleted => $composableBuilder(
      column: $table.onboardingCompleted, builder: (column) => column);

  GeneratedColumn<String> get defaultModelId => $composableBuilder(
      column: $table.defaultModelId, builder: (column) => column);

  GeneratedColumn<int> get pollIntervalSeconds => $composableBuilder(
      column: $table.pollIntervalSeconds, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()> {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> cursorKeyRef = const Value.absent(),
            Value<String> githubTokenRef = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            Value<String?> defaultModelId = const Value.absent(),
            Value<int> pollIntervalSeconds = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserSettingsCompanion(
            id: id,
            cursorKeyRef: cursorKeyRef,
            githubTokenRef: githubTokenRef,
            biometricEnabled: biometricEnabled,
            onboardingCompleted: onboardingCompleted,
            defaultModelId: defaultModelId,
            pollIntervalSeconds: pollIntervalSeconds,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> cursorKeyRef = const Value.absent(),
            Value<String> githubTokenRef = const Value.absent(),
            Value<bool> biometricEnabled = const Value.absent(),
            Value<bool> onboardingCompleted = const Value.absent(),
            Value<String?> defaultModelId = const Value.absent(),
            Value<int> pollIntervalSeconds = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              UserSettingsCompanion.insert(
            id: id,
            cursorKeyRef: cursorKeyRef,
            githubTokenRef: githubTokenRef,
            biometricEnabled: biometricEnabled,
            onboardingCompleted: onboardingCompleted,
            defaultModelId: defaultModelId,
            pollIntervalSeconds: pollIntervalSeconds,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSettingsTable,
    UserSetting,
    $$UserSettingsTableFilterComposer,
    $$UserSettingsTableOrderingComposer,
    $$UserSettingsTableAnnotationComposer,
    $$UserSettingsTableCreateCompanionBuilder,
    $$UserSettingsTableUpdateCompanionBuilder,
    (
      UserSetting,
      BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>
    ),
    UserSetting,
    PrefetchHooks Function()>;
typedef $$PinnedProjectsTableCreateCompanionBuilder = PinnedProjectsCompanion
    Function({
  required String id,
  required String repoUrl,
  required String owner,
  required String name,
  required String defaultBranch,
  Value<int> sortOrder,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$PinnedProjectsTableUpdateCompanionBuilder = PinnedProjectsCompanion
    Function({
  Value<String> id,
  Value<String> repoUrl,
  Value<String> owner,
  Value<String> name,
  Value<String> defaultBranch,
  Value<int> sortOrder,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$PinnedProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $PinnedProjectsTable> {
  $$PinnedProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$PinnedProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $PinnedProjectsTable> {
  $$PinnedProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get owner => $composableBuilder(
      column: $table.owner, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$PinnedProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PinnedProjectsTable> {
  $$PinnedProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get repoUrl =>
      $composableBuilder(column: $table.repoUrl, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get defaultBranch => $composableBuilder(
      column: $table.defaultBranch, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$PinnedProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PinnedProjectsTable,
    PinnedProjectRow,
    $$PinnedProjectsTableFilterComposer,
    $$PinnedProjectsTableOrderingComposer,
    $$PinnedProjectsTableAnnotationComposer,
    $$PinnedProjectsTableCreateCompanionBuilder,
    $$PinnedProjectsTableUpdateCompanionBuilder,
    (
      PinnedProjectRow,
      BaseReferences<_$AppDatabase, $PinnedProjectsTable, PinnedProjectRow>
    ),
    PinnedProjectRow,
    PrefetchHooks Function()> {
  $$PinnedProjectsTableTableManager(
      _$AppDatabase db, $PinnedProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinnedProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinnedProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinnedProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> repoUrl = const Value.absent(),
            Value<String> owner = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> defaultBranch = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PinnedProjectsCompanion(
            id: id,
            repoUrl: repoUrl,
            owner: owner,
            name: name,
            defaultBranch: defaultBranch,
            sortOrder: sortOrder,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String repoUrl,
            required String owner,
            required String name,
            required String defaultBranch,
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PinnedProjectsCompanion.insert(
            id: id,
            repoUrl: repoUrl,
            owner: owner,
            name: name,
            defaultBranch: defaultBranch,
            sortOrder: sortOrder,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PinnedProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PinnedProjectsTable,
    PinnedProjectRow,
    $$PinnedProjectsTableFilterComposer,
    $$PinnedProjectsTableOrderingComposer,
    $$PinnedProjectsTableAnnotationComposer,
    $$PinnedProjectsTableCreateCompanionBuilder,
    $$PinnedProjectsTableUpdateCompanionBuilder,
    (
      PinnedProjectRow,
      BaseReferences<_$AppDatabase, $PinnedProjectsTable, PinnedProjectRow>
    ),
    PinnedProjectRow,
    PrefetchHooks Function()>;
typedef $$AgentSessionsTableCreateCompanionBuilder = AgentSessionsCompanion
    Function({
  required String agentId,
  required String projectId,
  required String name,
  required String status,
  Value<String?> latestRunId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> tags,
  Value<int> rowid,
});
typedef $$AgentSessionsTableUpdateCompanionBuilder = AgentSessionsCompanion
    Function({
  Value<String> agentId,
  Value<String> projectId,
  Value<String> name,
  Value<String> status,
  Value<String?> latestRunId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> tags,
  Value<int> rowid,
});

class $$AgentSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentSessionsTable> {
  $$AgentSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get latestRunId => $composableBuilder(
      column: $table.latestRunId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));
}

class $$AgentSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentSessionsTable> {
  $$AgentSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get latestRunId => $composableBuilder(
      column: $table.latestRunId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));
}

class $$AgentSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentSessionsTable> {
  $$AgentSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get latestRunId => $composableBuilder(
      column: $table.latestRunId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$AgentSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentSessionsTable,
    AgentSessionRow,
    $$AgentSessionsTableFilterComposer,
    $$AgentSessionsTableOrderingComposer,
    $$AgentSessionsTableAnnotationComposer,
    $$AgentSessionsTableCreateCompanionBuilder,
    $$AgentSessionsTableUpdateCompanionBuilder,
    (
      AgentSessionRow,
      BaseReferences<_$AppDatabase, $AgentSessionsTable, AgentSessionRow>
    ),
    AgentSessionRow,
    PrefetchHooks Function()> {
  $$AgentSessionsTableTableManager(_$AppDatabase db, $AgentSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> agentId = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> latestRunId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentSessionsCompanion(
            agentId: agentId,
            projectId: projectId,
            name: name,
            status: status,
            latestRunId: latestRunId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String agentId,
            required String projectId,
            required String name,
            required String status,
            Value<String?> latestRunId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentSessionsCompanion.insert(
            agentId: agentId,
            projectId: projectId,
            name: name,
            status: status,
            latestRunId: latestRunId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentSessionsTable,
    AgentSessionRow,
    $$AgentSessionsTableFilterComposer,
    $$AgentSessionsTableOrderingComposer,
    $$AgentSessionsTableAnnotationComposer,
    $$AgentSessionsTableCreateCompanionBuilder,
    $$AgentSessionsTableUpdateCompanionBuilder,
    (
      AgentSessionRow,
      BaseReferences<_$AppDatabase, $AgentSessionsTable, AgentSessionRow>
    ),
    AgentSessionRow,
    PrefetchHooks Function()>;
typedef $$RunRecordsTableCreateCompanionBuilder = RunRecordsCompanion Function({
  required String runId,
  required String agentId,
  required String status,
  Value<String?> resultText,
  Value<int?> durationMs,
  Value<String?> prUrl,
  Value<String?> branch,
  Value<String?> errorCode,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$RunRecordsTableUpdateCompanionBuilder = RunRecordsCompanion Function({
  Value<String> runId,
  Value<String> agentId,
  Value<String> status,
  Value<String?> resultText,
  Value<int?> durationMs,
  Value<String?> prUrl,
  Value<String?> branch,
  Value<String?> errorCode,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$RunRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RunRecordsTable> {
  $$RunRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prUrl => $composableBuilder(
      column: $table.prUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorCode => $composableBuilder(
      column: $table.errorCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$RunRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RunRecordsTable> {
  $$RunRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prUrl => $composableBuilder(
      column: $table.prUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branch => $composableBuilder(
      column: $table.branch, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorCode => $composableBuilder(
      column: $table.errorCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$RunRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunRecordsTable> {
  $$RunRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resultText => $composableBuilder(
      column: $table.resultText, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get prUrl =>
      $composableBuilder(column: $table.prUrl, builder: (column) => column);

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$RunRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RunRecordsTable,
    RunRecordRow,
    $$RunRecordsTableFilterComposer,
    $$RunRecordsTableOrderingComposer,
    $$RunRecordsTableAnnotationComposer,
    $$RunRecordsTableCreateCompanionBuilder,
    $$RunRecordsTableUpdateCompanionBuilder,
    (
      RunRecordRow,
      BaseReferences<_$AppDatabase, $RunRecordsTable, RunRecordRow>
    ),
    RunRecordRow,
    PrefetchHooks Function()> {
  $$RunRecordsTableTableManager(_$AppDatabase db, $RunRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> runId = const Value.absent(),
            Value<String> agentId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> resultText = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> prUrl = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<String?> errorCode = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunRecordsCompanion(
            runId: runId,
            agentId: agentId,
            status: status,
            resultText: resultText,
            durationMs: durationMs,
            prUrl: prUrl,
            branch: branch,
            errorCode: errorCode,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String runId,
            required String agentId,
            required String status,
            Value<String?> resultText = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> prUrl = const Value.absent(),
            Value<String?> branch = const Value.absent(),
            Value<String?> errorCode = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RunRecordsCompanion.insert(
            runId: runId,
            agentId: agentId,
            status: status,
            resultText: resultText,
            durationMs: durationMs,
            prUrl: prUrl,
            branch: branch,
            errorCode: errorCode,
            errorMessage: errorMessage,
            createdAt: createdAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RunRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RunRecordsTable,
    RunRecordRow,
    $$RunRecordsTableFilterComposer,
    $$RunRecordsTableOrderingComposer,
    $$RunRecordsTableAnnotationComposer,
    $$RunRecordsTableCreateCompanionBuilder,
    $$RunRecordsTableUpdateCompanionBuilder,
    (
      RunRecordRow,
      BaseReferences<_$AppDatabase, $RunRecordsTable, RunRecordRow>
    ),
    RunRecordRow,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  required String id,
  required String runId,
  required String role,
  required String content,
  required String eventType,
  required int sequenceIndex,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<String> id,
  Value<String> runId,
  Value<String> role,
  Value<String> content,
  Value<String> eventType,
  Value<int> sequenceIndex,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
      column: $table.sequenceIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRow,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>
    ),
    ChatMessageRow,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> runId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<int> sequenceIndex = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            runId: runId,
            role: role,
            content: content,
            eventType: eventType,
            sequenceIndex: sequenceIndex,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String runId,
            required String role,
            required String content,
            required String eventType,
            required int sequenceIndex,
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            runId: runId,
            role: role,
            content: content,
            eventType: eventType,
            sequenceIndex: sequenceIndex,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageRow,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow>
    ),
    ChatMessageRow,
    PrefetchHooks Function()>;
typedef $$ToolCallLogsTableCreateCompanionBuilder = ToolCallLogsCompanion
    Function({
  required String callId,
  required String runId,
  required String toolName,
  required String status,
  required String argsJson,
  Value<String?> resultJson,
  required DateTime startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});
typedef $$ToolCallLogsTableUpdateCompanionBuilder = ToolCallLogsCompanion
    Function({
  Value<String> callId,
  Value<String> runId,
  Value<String> toolName,
  Value<String> status,
  Value<String> argsJson,
  Value<String?> resultJson,
  Value<DateTime> startedAt,
  Value<DateTime?> completedAt,
  Value<int> rowid,
});

class $$ToolCallLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ToolCallLogsTable> {
  $$ToolCallLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get callId => $composableBuilder(
      column: $table.callId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$ToolCallLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ToolCallLogsTable> {
  $$ToolCallLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get callId => $composableBuilder(
      column: $table.callId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argsJson => $composableBuilder(
      column: $table.argsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$ToolCallLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToolCallLogsTable> {
  $$ToolCallLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get argsJson =>
      $composableBuilder(column: $table.argsJson, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$ToolCallLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ToolCallLogsTable,
    ToolCallLogRow,
    $$ToolCallLogsTableFilterComposer,
    $$ToolCallLogsTableOrderingComposer,
    $$ToolCallLogsTableAnnotationComposer,
    $$ToolCallLogsTableCreateCompanionBuilder,
    $$ToolCallLogsTableUpdateCompanionBuilder,
    (
      ToolCallLogRow,
      BaseReferences<_$AppDatabase, $ToolCallLogsTable, ToolCallLogRow>
    ),
    ToolCallLogRow,
    PrefetchHooks Function()> {
  $$ToolCallLogsTableTableManager(_$AppDatabase db, $ToolCallLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToolCallLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToolCallLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToolCallLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> callId = const Value.absent(),
            Value<String> runId = const Value.absent(),
            Value<String> toolName = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> argsJson = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToolCallLogsCompanion(
            callId: callId,
            runId: runId,
            toolName: toolName,
            status: status,
            argsJson: argsJson,
            resultJson: resultJson,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String callId,
            required String runId,
            required String toolName,
            required String status,
            required String argsJson,
            Value<String?> resultJson = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToolCallLogsCompanion.insert(
            callId: callId,
            runId: runId,
            toolName: toolName,
            status: status,
            argsJson: argsJson,
            resultJson: resultJson,
            startedAt: startedAt,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ToolCallLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ToolCallLogsTable,
    ToolCallLogRow,
    $$ToolCallLogsTableFilterComposer,
    $$ToolCallLogsTableOrderingComposer,
    $$ToolCallLogsTableAnnotationComposer,
    $$ToolCallLogsTableCreateCompanionBuilder,
    $$ToolCallLogsTableUpdateCompanionBuilder,
    (
      ToolCallLogRow,
      BaseReferences<_$AppDatabase, $ToolCallLogsTable, ToolCallLogRow>
    ),
    ToolCallLogRow,
    PrefetchHooks Function()>;
typedef $$UsageRecordsTableCreateCompanionBuilder = UsageRecordsCompanion
    Function({
  required String runId,
  Value<int> inputTokens,
  Value<int> outputTokens,
  Value<int> totalTokens,
  required DateTime recordedAt,
  Value<int> rowid,
});
typedef $$UsageRecordsTableUpdateCompanionBuilder = UsageRecordsCompanion
    Function({
  Value<String> runId,
  Value<int> inputTokens,
  Value<int> outputTokens,
  Value<int> totalTokens,
  Value<DateTime> recordedAt,
  Value<int> rowid,
});

class $$UsageRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get inputTokens => $composableBuilder(
      column: $table.inputTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get outputTokens => $composableBuilder(
      column: $table.outputTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTokens => $composableBuilder(
      column: $table.totalTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));
}

class $$UsageRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get inputTokens => $composableBuilder(
      column: $table.inputTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get outputTokens => $composableBuilder(
      column: $table.outputTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTokens => $composableBuilder(
      column: $table.totalTokens, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsageRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageRecordsTable> {
  $$UsageRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get inputTokens => $composableBuilder(
      column: $table.inputTokens, builder: (column) => column);

  GeneratedColumn<int> get outputTokens => $composableBuilder(
      column: $table.outputTokens, builder: (column) => column);

  GeneratedColumn<int> get totalTokens => $composableBuilder(
      column: $table.totalTokens, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);
}

class $$UsageRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsageRecordsTable,
    UsageRecordRow,
    $$UsageRecordsTableFilterComposer,
    $$UsageRecordsTableOrderingComposer,
    $$UsageRecordsTableAnnotationComposer,
    $$UsageRecordsTableCreateCompanionBuilder,
    $$UsageRecordsTableUpdateCompanionBuilder,
    (
      UsageRecordRow,
      BaseReferences<_$AppDatabase, $UsageRecordsTable, UsageRecordRow>
    ),
    UsageRecordRow,
    PrefetchHooks Function()> {
  $$UsageRecordsTableTableManager(_$AppDatabase db, $UsageRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> runId = const Value.absent(),
            Value<int> inputTokens = const Value.absent(),
            Value<int> outputTokens = const Value.absent(),
            Value<int> totalTokens = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsageRecordsCompanion(
            runId: runId,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            totalTokens: totalTokens,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String runId,
            Value<int> inputTokens = const Value.absent(),
            Value<int> outputTokens = const Value.absent(),
            Value<int> totalTokens = const Value.absent(),
            required DateTime recordedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsageRecordsCompanion.insert(
            runId: runId,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            totalTokens: totalTokens,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsageRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsageRecordsTable,
    UsageRecordRow,
    $$UsageRecordsTableFilterComposer,
    $$UsageRecordsTableOrderingComposer,
    $$UsageRecordsTableAnnotationComposer,
    $$UsageRecordsTableCreateCompanionBuilder,
    $$UsageRecordsTableUpdateCompanionBuilder,
    (
      UsageRecordRow,
      BaseReferences<_$AppDatabase, $UsageRecordsTable, UsageRecordRow>
    ),
    UsageRecordRow,
    PrefetchHooks Function()>;
typedef $$GithubCachesTableCreateCompanionBuilder = GithubCachesCompanion
    Function({
  required String cacheKey,
  required String jsonPayload,
  required DateTime createdAt,
  required DateTime expiresAt,
  Value<int> rowid,
});
typedef $$GithubCachesTableUpdateCompanionBuilder = GithubCachesCompanion
    Function({
  Value<String> cacheKey,
  Value<String> jsonPayload,
  Value<DateTime> createdAt,
  Value<DateTime> expiresAt,
  Value<int> rowid,
});

class $$GithubCachesTableFilterComposer
    extends Composer<_$AppDatabase, $GithubCachesTable> {
  $$GithubCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jsonPayload => $composableBuilder(
      column: $table.jsonPayload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$GithubCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $GithubCachesTable> {
  $$GithubCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
      column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jsonPayload => $composableBuilder(
      column: $table.jsonPayload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$GithubCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GithubCachesTable> {
  $$GithubCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get jsonPayload => $composableBuilder(
      column: $table.jsonPayload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$GithubCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GithubCachesTable,
    GithubCacheRow,
    $$GithubCachesTableFilterComposer,
    $$GithubCachesTableOrderingComposer,
    $$GithubCachesTableAnnotationComposer,
    $$GithubCachesTableCreateCompanionBuilder,
    $$GithubCachesTableUpdateCompanionBuilder,
    (
      GithubCacheRow,
      BaseReferences<_$AppDatabase, $GithubCachesTable, GithubCacheRow>
    ),
    GithubCacheRow,
    PrefetchHooks Function()> {
  $$GithubCachesTableTableManager(_$AppDatabase db, $GithubCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GithubCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GithubCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GithubCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cacheKey = const Value.absent(),
            Value<String> jsonPayload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GithubCachesCompanion(
            cacheKey: cacheKey,
            jsonPayload: jsonPayload,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cacheKey,
            required String jsonPayload,
            required DateTime createdAt,
            required DateTime expiresAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GithubCachesCompanion.insert(
            cacheKey: cacheKey,
            jsonPayload: jsonPayload,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GithubCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GithubCachesTable,
    GithubCacheRow,
    $$GithubCachesTableFilterComposer,
    $$GithubCachesTableOrderingComposer,
    $$GithubCachesTableAnnotationComposer,
    $$GithubCachesTableCreateCompanionBuilder,
    $$GithubCachesTableUpdateCompanionBuilder,
    (
      GithubCacheRow,
      BaseReferences<_$AppDatabase, $GithubCachesTable, GithubCacheRow>
    ),
    GithubCacheRow,
    PrefetchHooks Function()>;
typedef $$DiffCachesTableCreateCompanionBuilder = DiffCachesCompanion Function({
  required String prKey,
  required String patchText,
  Value<int> fileCount,
  required DateTime createdAt,
  required DateTime expiresAt,
  Value<int> rowid,
});
typedef $$DiffCachesTableUpdateCompanionBuilder = DiffCachesCompanion Function({
  Value<String> prKey,
  Value<String> patchText,
  Value<int> fileCount,
  Value<DateTime> createdAt,
  Value<DateTime> expiresAt,
  Value<int> rowid,
});

class $$DiffCachesTableFilterComposer
    extends Composer<_$AppDatabase, $DiffCachesTable> {
  $$DiffCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get prKey => $composableBuilder(
      column: $table.prKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patchText => $composableBuilder(
      column: $table.patchText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileCount => $composableBuilder(
      column: $table.fileCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$DiffCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiffCachesTable> {
  $$DiffCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get prKey => $composableBuilder(
      column: $table.prKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patchText => $composableBuilder(
      column: $table.patchText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileCount => $composableBuilder(
      column: $table.fileCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$DiffCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiffCachesTable> {
  $$DiffCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get prKey =>
      $composableBuilder(column: $table.prKey, builder: (column) => column);

  GeneratedColumn<String> get patchText =>
      $composableBuilder(column: $table.patchText, builder: (column) => column);

  GeneratedColumn<int> get fileCount =>
      $composableBuilder(column: $table.fileCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$DiffCachesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiffCachesTable,
    DiffCacheRow,
    $$DiffCachesTableFilterComposer,
    $$DiffCachesTableOrderingComposer,
    $$DiffCachesTableAnnotationComposer,
    $$DiffCachesTableCreateCompanionBuilder,
    $$DiffCachesTableUpdateCompanionBuilder,
    (
      DiffCacheRow,
      BaseReferences<_$AppDatabase, $DiffCachesTable, DiffCacheRow>
    ),
    DiffCacheRow,
    PrefetchHooks Function()> {
  $$DiffCachesTableTableManager(_$AppDatabase db, $DiffCachesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiffCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiffCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiffCachesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> prKey = const Value.absent(),
            Value<String> patchText = const Value.absent(),
            Value<int> fileCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiffCachesCompanion(
            prKey: prKey,
            patchText: patchText,
            fileCount: fileCount,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String prKey,
            required String patchText,
            Value<int> fileCount = const Value.absent(),
            required DateTime createdAt,
            required DateTime expiresAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DiffCachesCompanion.insert(
            prKey: prKey,
            patchText: patchText,
            fileCount: fileCount,
            createdAt: createdAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DiffCachesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiffCachesTable,
    DiffCacheRow,
    $$DiffCachesTableFilterComposer,
    $$DiffCachesTableOrderingComposer,
    $$DiffCachesTableAnnotationComposer,
    $$DiffCachesTableCreateCompanionBuilder,
    $$DiffCachesTableUpdateCompanionBuilder,
    (
      DiffCacheRow,
      BaseReferences<_$AppDatabase, $DiffCachesTable, DiffCacheRow>
    ),
    DiffCacheRow,
    PrefetchHooks Function()>;
typedef $$QueuedPromptsTableCreateCompanionBuilder = QueuedPromptsCompanion
    Function({
  required String id,
  Value<String?> agentId,
  required String repoUrl,
  required String promptText,
  Value<String> options,
  required DateTime createdAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$QueuedPromptsTableUpdateCompanionBuilder = QueuedPromptsCompanion
    Function({
  Value<String> id,
  Value<String?> agentId,
  Value<String> repoUrl,
  Value<String> promptText,
  Value<String> options,
  Value<DateTime> createdAt,
  Value<String> status,
  Value<int> rowid,
});

class $$QueuedPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $QueuedPromptsTable> {
  $$QueuedPromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$QueuedPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueuedPromptsTable> {
  $$QueuedPromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repoUrl => $composableBuilder(
      column: $table.repoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$QueuedPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueuedPromptsTable> {
  $$QueuedPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get repoUrl =>
      $composableBuilder(column: $table.repoUrl, builder: (column) => column);

  GeneratedColumn<String> get promptText => $composableBuilder(
      column: $table.promptText, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$QueuedPromptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueuedPromptsTable,
    QueuedPromptRow,
    $$QueuedPromptsTableFilterComposer,
    $$QueuedPromptsTableOrderingComposer,
    $$QueuedPromptsTableAnnotationComposer,
    $$QueuedPromptsTableCreateCompanionBuilder,
    $$QueuedPromptsTableUpdateCompanionBuilder,
    (
      QueuedPromptRow,
      BaseReferences<_$AppDatabase, $QueuedPromptsTable, QueuedPromptRow>
    ),
    QueuedPromptRow,
    PrefetchHooks Function()> {
  $$QueuedPromptsTableTableManager(_$AppDatabase db, $QueuedPromptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueuedPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueuedPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueuedPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> agentId = const Value.absent(),
            Value<String> repoUrl = const Value.absent(),
            Value<String> promptText = const Value.absent(),
            Value<String> options = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueuedPromptsCompanion(
            id: id,
            agentId: agentId,
            repoUrl: repoUrl,
            promptText: promptText,
            options: options,
            createdAt: createdAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> agentId = const Value.absent(),
            required String repoUrl,
            required String promptText,
            Value<String> options = const Value.absent(),
            required DateTime createdAt,
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QueuedPromptsCompanion.insert(
            id: id,
            agentId: agentId,
            repoUrl: repoUrl,
            promptText: promptText,
            options: options,
            createdAt: createdAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueuedPromptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueuedPromptsTable,
    QueuedPromptRow,
    $$QueuedPromptsTableFilterComposer,
    $$QueuedPromptsTableOrderingComposer,
    $$QueuedPromptsTableAnnotationComposer,
    $$QueuedPromptsTableCreateCompanionBuilder,
    $$QueuedPromptsTableUpdateCompanionBuilder,
    (
      QueuedPromptRow,
      BaseReferences<_$AppDatabase, $QueuedPromptsTable, QueuedPromptRow>
    ),
    QueuedPromptRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$PinnedProjectsTableTableManager get pinnedProjects =>
      $$PinnedProjectsTableTableManager(_db, _db.pinnedProjects);
  $$AgentSessionsTableTableManager get agentSessions =>
      $$AgentSessionsTableTableManager(_db, _db.agentSessions);
  $$RunRecordsTableTableManager get runRecords =>
      $$RunRecordsTableTableManager(_db, _db.runRecords);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ToolCallLogsTableTableManager get toolCallLogs =>
      $$ToolCallLogsTableTableManager(_db, _db.toolCallLogs);
  $$UsageRecordsTableTableManager get usageRecords =>
      $$UsageRecordsTableTableManager(_db, _db.usageRecords);
  $$GithubCachesTableTableManager get githubCaches =>
      $$GithubCachesTableTableManager(_db, _db.githubCaches);
  $$DiffCachesTableTableManager get diffCaches =>
      $$DiffCachesTableTableManager(_db, _db.diffCaches);
  $$QueuedPromptsTableTableManager get queuedPrompts =>
      $$QueuedPromptsTableTableManager(_db, _db.queuedPrompts);
}
