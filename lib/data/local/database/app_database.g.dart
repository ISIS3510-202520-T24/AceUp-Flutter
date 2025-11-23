// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastLoginMeta =
      const VerificationMeta('lastLogin');
  @override
  late final GeneratedColumn<DateTime> lastLogin = GeneratedColumn<DateTime>(
      'last_login', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        uid,
        email,
        nickname,
        avatar,
        createdAt,
        lastLogin,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_login')) {
      context.handle(_lastLoginMeta,
          lastLogin.isAcceptableOrUnknown(data['last_login']!, _lastLoginMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  UserEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntity(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastLogin: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserEntity extends DataClass implements Insertable<UserEntity> {
  final String uid;
  final String email;
  final String nickname;
  final String? avatar;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const UserEntity(
      {required this.uid,
      required this.email,
      required this.nickname,
      this.avatar,
      required this.createdAt,
      this.lastLogin,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['email'] = Variable<String>(email);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastLogin != null) {
      map['last_login'] = Variable<DateTime>(lastLogin);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      uid: Value(uid),
      email: Value(email),
      nickname: Value(nickname),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      createdAt: Value(createdAt),
      lastLogin: lastLogin == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLogin),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntity(
      uid: serializer.fromJson<String>(json['uid']),
      email: serializer.fromJson<String>(json['email']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastLogin: serializer.fromJson<DateTime?>(json['lastLogin']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'email': serializer.toJson<String>(email),
      'nickname': serializer.toJson<String>(nickname),
      'avatar': serializer.toJson<String?>(avatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastLogin': serializer.toJson<DateTime?>(lastLogin),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  UserEntity copyWith(
          {String? uid,
          String? email,
          String? nickname,
          Value<String?> avatar = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastLogin = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      UserEntity(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        nickname: nickname ?? this.nickname,
        avatar: avatar.present ? avatar.value : this.avatar,
        createdAt: createdAt ?? this.createdAt,
        lastLogin: lastLogin.present ? lastLogin.value : this.lastLogin,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  UserEntity copyWithCompanion(UsersCompanion data) {
    return UserEntity(
      uid: data.uid.present ? data.uid.value : this.uid,
      email: data.email.present ? data.email.value : this.email,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastLogin: data.lastLogin.present ? data.lastLogin.value : this.lastLogin,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntity(')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uid, email, nickname, avatar, createdAt,
      lastLogin, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntity &&
          other.uid == this.uid &&
          other.email == this.email &&
          other.nickname == this.nickname &&
          other.avatar == this.avatar &&
          other.createdAt == this.createdAt &&
          other.lastLogin == this.lastLogin &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UsersCompanion extends UpdateCompanion<UserEntity> {
  final Value<String> uid;
  final Value<String> email;
  final Value<String> nickname;
  final Value<String?> avatar;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastLogin;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.uid = const Value.absent(),
    this.email = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastLogin = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String uid,
    required String email,
    required String nickname,
    this.avatar = const Value.absent(),
    required DateTime createdAt,
    this.lastLogin = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        email = Value(email),
        nickname = Value(nickname),
        createdAt = Value(createdAt);
  static Insertable<UserEntity> custom({
    Expression<String>? uid,
    Expression<String>? email,
    Expression<String>? nickname,
    Expression<String>? avatar,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastLogin,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (createdAt != null) 'created_at': createdAt,
      if (lastLogin != null) 'last_login': lastLogin,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? uid,
      Value<String>? email,
      Value<String>? nickname,
      Value<String?>? avatar,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastLogin,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastLogin.present) {
      map['last_login'] = Variable<DateTime>(lastLogin.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('uid: $uid, ')
          ..write('email: $email, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastLogin: $lastLogin, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TermsTable extends Terms with TableInfo<$TermsTable, TermEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terms';
  @override
  VerificationContext validateIntegrity(Insertable<TermEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  TermEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TermEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $TermsTable createAlias(String alias) {
    return $TermsTable(attachedDatabase, alias);
  }
}

class TermEntity extends DataClass implements Insertable<TermEntity> {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const TermEntity(
      {required this.id,
      required this.userId,
      required this.name,
      required this.startDate,
      required this.endDate,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  TermsCompanion toCompanion(bool nullToAbsent) {
    return TermsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory TermEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TermEntity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  TermEntity copyWith(
          {String? id,
          String? userId,
          String? name,
          DateTime? startDate,
          DateTime? endDate,
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      TermEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  TermEntity copyWithCompanion(TermsCompanion data) {
    return TermEntity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TermEntity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, startDate, endDate,
      isActive, createdAt, updatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TermEntity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TermsCompanion extends UpdateCompanion<TermEntity> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const TermsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TermsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        startDate = Value(startDate),
        endDate = Value(endDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TermEntity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TermsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return TermsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('TermsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects
    with TableInfo<$SubjectsTable, SubjectEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creditsMeta =
      const VerificationMeta('credits');
  @override
  late final GeneratedColumn<double> credits = GeneratedColumn<double>(
      'credits', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _finalGradeMeta =
      const VerificationMeta('finalGrade');
  @override
  late final GeneratedColumn<double> finalGrade = GeneratedColumn<double>(
      'final_grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _useFinalGradeOverrideMeta =
      const VerificationMeta('useFinalGradeOverride');
  @override
  late final GeneratedColumn<bool> useFinalGradeOverride =
      GeneratedColumn<bool>('use_final_grade_override', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("use_final_grade_override" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _weightsJsonMeta =
      const VerificationMeta('weightsJson');
  @override
  late final GeneratedColumn<String> weightsJson = GeneratedColumn<String>(
      'weights_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        termId,
        name,
        color,
        credits,
        finalGrade,
        useFinalGradeOverride,
        weightsJson,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<SubjectEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    } else if (isInserting) {
      context.missing(_termIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(_creditsMeta,
          credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta));
    } else if (isInserting) {
      context.missing(_creditsMeta);
    }
    if (data.containsKey('final_grade')) {
      context.handle(
          _finalGradeMeta,
          finalGrade.isAcceptableOrUnknown(
              data['final_grade']!, _finalGradeMeta));
    }
    if (data.containsKey('use_final_grade_override')) {
      context.handle(
          _useFinalGradeOverrideMeta,
          useFinalGradeOverride.isAcceptableOrUnknown(
              data['use_final_grade_override']!, _useFinalGradeOverrideMeta));
    }
    if (data.containsKey('weights_json')) {
      context.handle(
          _weightsJsonMeta,
          weightsJson.isAcceptableOrUnknown(
              data['weights_json']!, _weightsJsonMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  SubjectEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      credits: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credits'])!,
      finalGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_grade']),
      useFinalGradeOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}use_final_grade_override'])!,
      weightsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weights_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class SubjectEntity extends DataClass implements Insertable<SubjectEntity> {
  final String id;
  final String termId;
  final String name;
  final String color;
  final double credits;
  final double? finalGrade;
  final bool useFinalGradeOverride;
  final String weightsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const SubjectEntity(
      {required this.id,
      required this.termId,
      required this.name,
      required this.color,
      required this.credits,
      this.finalGrade,
      required this.useFinalGradeOverride,
      required this.weightsJson,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_id'] = Variable<String>(termId);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    map['credits'] = Variable<double>(credits);
    if (!nullToAbsent || finalGrade != null) {
      map['final_grade'] = Variable<double>(finalGrade);
    }
    map['use_final_grade_override'] = Variable<bool>(useFinalGradeOverride);
    map['weights_json'] = Variable<String>(weightsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      termId: Value(termId),
      name: Value(name),
      color: Value(color),
      credits: Value(credits),
      finalGrade: finalGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(finalGrade),
      useFinalGradeOverride: Value(useFinalGradeOverride),
      weightsJson: Value(weightsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SubjectEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectEntity(
      id: serializer.fromJson<String>(json['id']),
      termId: serializer.fromJson<String>(json['termId']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      credits: serializer.fromJson<double>(json['credits']),
      finalGrade: serializer.fromJson<double?>(json['finalGrade']),
      useFinalGradeOverride:
          serializer.fromJson<bool>(json['useFinalGradeOverride']),
      weightsJson: serializer.fromJson<String>(json['weightsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termId': serializer.toJson<String>(termId),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'credits': serializer.toJson<double>(credits),
      'finalGrade': serializer.toJson<double?>(finalGrade),
      'useFinalGradeOverride': serializer.toJson<bool>(useFinalGradeOverride),
      'weightsJson': serializer.toJson<String>(weightsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SubjectEntity copyWith(
          {String? id,
          String? termId,
          String? name,
          String? color,
          double? credits,
          Value<double?> finalGrade = const Value.absent(),
          bool? useFinalGradeOverride,
          String? weightsJson,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      SubjectEntity(
        id: id ?? this.id,
        termId: termId ?? this.termId,
        name: name ?? this.name,
        color: color ?? this.color,
        credits: credits ?? this.credits,
        finalGrade: finalGrade.present ? finalGrade.value : this.finalGrade,
        useFinalGradeOverride:
            useFinalGradeOverride ?? this.useFinalGradeOverride,
        weightsJson: weightsJson ?? this.weightsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SubjectEntity copyWithCompanion(SubjectsCompanion data) {
    return SubjectEntity(
      id: data.id.present ? data.id.value : this.id,
      termId: data.termId.present ? data.termId.value : this.termId,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      credits: data.credits.present ? data.credits.value : this.credits,
      finalGrade:
          data.finalGrade.present ? data.finalGrade.value : this.finalGrade,
      useFinalGradeOverride: data.useFinalGradeOverride.present
          ? data.useFinalGradeOverride.value
          : this.useFinalGradeOverride,
      weightsJson:
          data.weightsJson.present ? data.weightsJson.value : this.weightsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectEntity(')
          ..write('id: $id, ')
          ..write('termId: $termId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('credits: $credits, ')
          ..write('finalGrade: $finalGrade, ')
          ..write('useFinalGradeOverride: $useFinalGradeOverride, ')
          ..write('weightsJson: $weightsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      termId,
      name,
      color,
      credits,
      finalGrade,
      useFinalGradeOverride,
      weightsJson,
      createdAt,
      updatedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectEntity &&
          other.id == this.id &&
          other.termId == this.termId &&
          other.name == this.name &&
          other.color == this.color &&
          other.credits == this.credits &&
          other.finalGrade == this.finalGrade &&
          other.useFinalGradeOverride == this.useFinalGradeOverride &&
          other.weightsJson == this.weightsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SubjectsCompanion extends UpdateCompanion<SubjectEntity> {
  final Value<String> id;
  final Value<String> termId;
  final Value<String> name;
  final Value<String> color;
  final Value<double> credits;
  final Value<double?> finalGrade;
  final Value<bool> useFinalGradeOverride;
  final Value<String> weightsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.termId = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.credits = const Value.absent(),
    this.finalGrade = const Value.absent(),
    this.useFinalGradeOverride = const Value.absent(),
    this.weightsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String termId,
    required String name,
    required String color,
    required double credits,
    this.finalGrade = const Value.absent(),
    this.useFinalGradeOverride = const Value.absent(),
    this.weightsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        termId = Value(termId),
        name = Value(name),
        color = Value(color),
        credits = Value(credits),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SubjectEntity> custom({
    Expression<String>? id,
    Expression<String>? termId,
    Expression<String>? name,
    Expression<String>? color,
    Expression<double>? credits,
    Expression<double>? finalGrade,
    Expression<bool>? useFinalGradeOverride,
    Expression<String>? weightsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termId != null) 'term_id': termId,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (credits != null) 'credits': credits,
      if (finalGrade != null) 'final_grade': finalGrade,
      if (useFinalGradeOverride != null)
        'use_final_grade_override': useFinalGradeOverride,
      if (weightsJson != null) 'weights_json': weightsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? termId,
      Value<String>? name,
      Value<String>? color,
      Value<double>? credits,
      Value<double?>? finalGrade,
      Value<bool>? useFinalGradeOverride,
      Value<String>? weightsJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      termId: termId ?? this.termId,
      name: name ?? this.name,
      color: color ?? this.color,
      credits: credits ?? this.credits,
      finalGrade: finalGrade ?? this.finalGrade,
      useFinalGradeOverride:
          useFinalGradeOverride ?? this.useFinalGradeOverride,
      weightsJson: weightsJson ?? this.weightsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (credits.present) {
      map['credits'] = Variable<double>(credits.value);
    }
    if (finalGrade.present) {
      map['final_grade'] = Variable<double>(finalGrade.value);
    }
    if (useFinalGradeOverride.present) {
      map['use_final_grade_override'] =
          Variable<bool>(useFinalGradeOverride.value);
    }
    if (weightsJson.present) {
      map['weights_json'] = Variable<String>(weightsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('termId: $termId, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('credits: $credits, ')
          ..write('finalGrade: $finalGrade, ')
          ..write('useFinalGradeOverride: $useFinalGradeOverride, ')
          ..write('weightsJson: $weightsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, AssignmentEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueTimeMeta =
      const VerificationMeta('dueTime');
  @override
  late final GeneratedColumn<String> dueTime = GeneratedColumn<String>(
      'due_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightIdMeta =
      const VerificationMeta('weightId');
  @override
  late final GeneratedColumn<String> weightId = GeneratedColumn<String>(
      'weight_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isGradedMeta =
      const VerificationMeta('isGraded');
  @override
  late final GeneratedColumn<bool> isGraded = GeneratedColumn<bool>(
      'is_graded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_graded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<double> grade = GeneratedColumn<double>(
      'grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _alertsJsonMeta =
      const VerificationMeta('alertsJson');
  @override
  late final GeneratedColumn<String> alertsJson = GeneratedColumn<String>(
      'alerts_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        title,
        description,
        dueDate,
        dueTime,
        weightId,
        priority,
        isCompleted,
        completedAt,
        isGraded,
        grade,
        alertsJson,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(Insertable<AssignmentEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('due_time')) {
      context.handle(_dueTimeMeta,
          dueTime.isAcceptableOrUnknown(data['due_time']!, _dueTimeMeta));
    }
    if (data.containsKey('weight_id')) {
      context.handle(_weightIdMeta,
          weightId.isAcceptableOrUnknown(data['weight_id']!, _weightIdMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('is_graded')) {
      context.handle(_isGradedMeta,
          isGraded.isAcceptableOrUnknown(data['is_graded']!, _isGradedMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('alerts_json')) {
      context.handle(
          _alertsJsonMeta,
          alertsJson.isAcceptableOrUnknown(
              data['alerts_json']!, _alertsJsonMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  AssignmentEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      dueTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}due_time']),
      weightId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_id']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      isGraded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_graded'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grade']),
      alertsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alerts_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class AssignmentEntity extends DataClass
    implements Insertable<AssignmentEntity> {
  final String id;
  final String subjectId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String? dueTime;
  final String? weightId;
  final String priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isGraded;
  final double? grade;
  final String alertsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const AssignmentEntity(
      {required this.id,
      required this.subjectId,
      required this.title,
      this.description,
      required this.dueDate,
      this.dueTime,
      this.weightId,
      required this.priority,
      required this.isCompleted,
      this.completedAt,
      required this.isGraded,
      this.grade,
      required this.alertsJson,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || dueTime != null) {
      map['due_time'] = Variable<String>(dueTime);
    }
    if (!nullToAbsent || weightId != null) {
      map['weight_id'] = Variable<String>(weightId);
    }
    map['priority'] = Variable<String>(priority);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_graded'] = Variable<bool>(isGraded);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<double>(grade);
    }
    map['alerts_json'] = Variable<String>(alertsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: Value(dueDate),
      dueTime: dueTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dueTime),
      weightId: weightId == null && nullToAbsent
          ? const Value.absent()
          : Value(weightId),
      priority: Value(priority),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isGraded: Value(isGraded),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      alertsJson: Value(alertsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory AssignmentEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentEntity(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      dueTime: serializer.fromJson<String?>(json['dueTime']),
      weightId: serializer.fromJson<String?>(json['weightId']),
      priority: serializer.fromJson<String>(json['priority']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isGraded: serializer.fromJson<bool>(json['isGraded']),
      grade: serializer.fromJson<double?>(json['grade']),
      alertsJson: serializer.fromJson<String>(json['alertsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'dueTime': serializer.toJson<String?>(dueTime),
      'weightId': serializer.toJson<String?>(weightId),
      'priority': serializer.toJson<String>(priority),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isGraded': serializer.toJson<bool>(isGraded),
      'grade': serializer.toJson<double?>(grade),
      'alertsJson': serializer.toJson<String>(alertsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  AssignmentEntity copyWith(
          {String? id,
          String? subjectId,
          String? title,
          Value<String?> description = const Value.absent(),
          DateTime? dueDate,
          Value<String?> dueTime = const Value.absent(),
          Value<String?> weightId = const Value.absent(),
          String? priority,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          bool? isGraded,
          Value<double?> grade = const Value.absent(),
          String? alertsJson,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      AssignmentEntity(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        dueDate: dueDate ?? this.dueDate,
        dueTime: dueTime.present ? dueTime.value : this.dueTime,
        weightId: weightId.present ? weightId.value : this.weightId,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        isGraded: isGraded ?? this.isGraded,
        grade: grade.present ? grade.value : this.grade,
        alertsJson: alertsJson ?? this.alertsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  AssignmentEntity copyWithCompanion(AssignmentsCompanion data) {
    return AssignmentEntity(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueTime: data.dueTime.present ? data.dueTime.value : this.dueTime,
      weightId: data.weightId.present ? data.weightId.value : this.weightId,
      priority: data.priority.present ? data.priority.value : this.priority,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      isGraded: data.isGraded.present ? data.isGraded.value : this.isGraded,
      grade: data.grade.present ? data.grade.value : this.grade,
      alertsJson:
          data.alertsJson.present ? data.alertsJson.value : this.alertsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentEntity(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('weightId: $weightId, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isGraded: $isGraded, ')
          ..write('grade: $grade, ')
          ..write('alertsJson: $alertsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      title,
      description,
      dueDate,
      dueTime,
      weightId,
      priority,
      isCompleted,
      completedAt,
      isGraded,
      grade,
      alertsJson,
      createdAt,
      updatedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentEntity &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.dueTime == this.dueTime &&
          other.weightId == this.weightId &&
          other.priority == this.priority &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isGraded == this.isGraded &&
          other.grade == this.grade &&
          other.alertsJson == this.alertsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class AssignmentsCompanion extends UpdateCompanion<AssignmentEntity> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> dueDate;
  final Value<String?> dueTime;
  final Value<String?> weightId;
  final Value<String> priority;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isGraded;
  final Value<double?> grade;
  final Value<String> alertsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueTime = const Value.absent(),
    this.weightId = const Value.absent(),
    this.priority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.grade = const Value.absent(),
    this.alertsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    required String id,
    required String subjectId,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueDate,
    this.dueTime = const Value.absent(),
    this.weightId = const Value.absent(),
    this.priority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.grade = const Value.absent(),
    this.alertsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        title = Value(title),
        dueDate = Value(dueDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AssignmentEntity> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<String>? dueTime,
    Expression<String>? weightId,
    Expression<String>? priority,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isGraded,
    Expression<double>? grade,
    Expression<String>? alertsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (dueTime != null) 'due_time': dueTime,
      if (weightId != null) 'weight_id': weightId,
      if (priority != null) 'priority': priority,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isGraded != null) 'is_graded': isGraded,
      if (grade != null) 'grade': grade,
      if (alertsJson != null) 'alerts_json': alertsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? title,
      Value<String?>? description,
      Value<DateTime>? dueDate,
      Value<String?>? dueTime,
      Value<String?>? weightId,
      Value<String>? priority,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<bool>? isGraded,
      Value<double?>? grade,
      Value<String>? alertsJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      weightId: weightId ?? this.weightId,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isGraded: isGraded ?? this.isGraded,
      grade: grade ?? this.grade,
      alertsJson: alertsJson ?? this.alertsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueTime.present) {
      map['due_time'] = Variable<String>(dueTime.value);
    }
    if (weightId.present) {
      map['weight_id'] = Variable<String>(weightId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isGraded.present) {
      map['is_graded'] = Variable<bool>(isGraded.value);
    }
    if (grade.present) {
      map['grade'] = Variable<double>(grade.value);
    }
    if (alertsJson.present) {
      map['alerts_json'] = Variable<String>(alertsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('AssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueTime: $dueTime, ')
          ..write('weightId: $weightId, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isGraded: $isGraded, ')
          ..write('grade: $grade, ')
          ..write('alertsJson: $alertsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassTemplatesTable extends ClassTemplates
    with TableInfo<$ClassTemplatesTable, ClassTemplateEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recurrenceJsonMeta =
      const VerificationMeta('recurrenceJson');
  @override
  late final GeneratedColumn<String> recurrenceJson = GeneratedColumn<String>(
      'recurrence_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _buildingMeta =
      const VerificationMeta('building');
  @override
  late final GeneratedColumn<String> building = GeneratedColumn<String>(
      'building', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
      'teacher_id', aliasedName, true,
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        name,
        icon,
        startDate,
        endDate,
        startTime,
        endTime,
        recurrenceJson,
        building,
        room,
        teacherId,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<ClassTemplateEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('recurrence_json')) {
      context.handle(
          _recurrenceJsonMeta,
          recurrenceJson.isAcceptableOrUnknown(
              data['recurrence_json']!, _recurrenceJsonMeta));
    } else if (isInserting) {
      context.missing(_recurrenceJsonMeta);
    }
    if (data.containsKey('building')) {
      context.handle(_buildingMeta,
          building.isAcceptableOrUnknown(data['building']!, _buildingMeta));
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  ClassTemplateEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassTemplateEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      recurrenceJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurrence_json'])!,
      building: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}building']),
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room']),
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClassTemplatesTable createAlias(String alias) {
    return $ClassTemplatesTable(attachedDatabase, alias);
  }
}

class ClassTemplateEntity extends DataClass
    implements Insertable<ClassTemplateEntity> {
  final String id;
  final String subjectId;
  final String name;
  final String icon;
  final DateTime startDate;
  final DateTime endDate;
  final String startTime;
  final String endTime;
  final String recurrenceJson;
  final String? building;
  final String? room;
  final String? teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const ClassTemplateEntity(
      {required this.id,
      required this.subjectId,
      required this.name,
      required this.icon,
      required this.startDate,
      required this.endDate,
      required this.startTime,
      required this.endTime,
      required this.recurrenceJson,
      this.building,
      this.room,
      this.teacherId,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['recurrence_json'] = Variable<String>(recurrenceJson);
    if (!nullToAbsent || building != null) {
      map['building'] = Variable<String>(building);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClassTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ClassTemplatesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      name: Value(name),
      icon: Value(icon),
      startDate: Value(startDate),
      endDate: Value(endDate),
      startTime: Value(startTime),
      endTime: Value(endTime),
      recurrenceJson: Value(recurrenceJson),
      building: building == null && nullToAbsent
          ? const Value.absent()
          : Value(building),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClassTemplateEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassTemplateEntity(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      recurrenceJson: serializer.fromJson<String>(json['recurrenceJson']),
      building: serializer.fromJson<String?>(json['building']),
      room: serializer.fromJson<String?>(json['room']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'recurrenceJson': serializer.toJson<String>(recurrenceJson),
      'building': serializer.toJson<String?>(building),
      'room': serializer.toJson<String?>(room),
      'teacherId': serializer.toJson<String?>(teacherId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClassTemplateEntity copyWith(
          {String? id,
          String? subjectId,
          String? name,
          String? icon,
          DateTime? startDate,
          DateTime? endDate,
          String? startTime,
          String? endTime,
          String? recurrenceJson,
          Value<String?> building = const Value.absent(),
          Value<String?> room = const Value.absent(),
          Value<String?> teacherId = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ClassTemplateEntity(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        recurrenceJson: recurrenceJson ?? this.recurrenceJson,
        building: building.present ? building.value : this.building,
        room: room.present ? room.value : this.room,
        teacherId: teacherId.present ? teacherId.value : this.teacherId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ClassTemplateEntity copyWithCompanion(ClassTemplatesCompanion data) {
    return ClassTemplateEntity(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      recurrenceJson: data.recurrenceJson.present
          ? data.recurrenceJson.value
          : this.recurrenceJson,
      building: data.building.present ? data.building.value : this.building,
      room: data.room.present ? data.room.value : this.room,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassTemplateEntity(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('recurrenceJson: $recurrenceJson, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      name,
      icon,
      startDate,
      endDate,
      startTime,
      endTime,
      recurrenceJson,
      building,
      room,
      teacherId,
      createdAt,
      updatedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassTemplateEntity &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.recurrenceJson == this.recurrenceJson &&
          other.building == this.building &&
          other.room == this.room &&
          other.teacherId == this.teacherId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClassTemplatesCompanion extends UpdateCompanion<ClassTemplateEntity> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> name;
  final Value<String> icon;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String> recurrenceJson;
  final Value<String?> building;
  final Value<String?> room;
  final Value<String?> teacherId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClassTemplatesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.recurrenceJson = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassTemplatesCompanion.insert({
    required String id,
    required String subjectId,
    required String name,
    required String icon,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required String recurrenceJson,
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.teacherId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        name = Value(name),
        icon = Value(icon),
        startDate = Value(startDate),
        endDate = Value(endDate),
        startTime = Value(startTime),
        endTime = Value(endTime),
        recurrenceJson = Value(recurrenceJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClassTemplateEntity> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? recurrenceJson,
    Expression<String>? building,
    Expression<String>? room,
    Expression<String>? teacherId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (recurrenceJson != null) 'recurrence_json': recurrenceJson,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacher_id': teacherId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? name,
      Value<String>? icon,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String>? recurrenceJson,
      Value<String?>? building,
      Value<String?>? room,
      Value<String?>? teacherId,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ClassTemplatesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrenceJson: recurrenceJson ?? this.recurrenceJson,
      building: building ?? this.building,
      room: room ?? this.room,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (recurrenceJson.present) {
      map['recurrence_json'] = Variable<String>(recurrenceJson.value);
    }
    if (building.present) {
      map['building'] = Variable<String>(building.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('ClassTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('recurrenceJson: $recurrenceJson, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('teacherId: $teacherId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassExceptionsTable extends ClassExceptions
    with TableInfo<$ClassExceptionsTable, ClassExceptionEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassExceptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _classTemplateIdMeta =
      const VerificationMeta('classTemplateId');
  @override
  late final GeneratedColumn<String> classTemplateId = GeneratedColumn<String>(
      'class_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isCancelledMeta =
      const VerificationMeta('isCancelled');
  @override
  late final GeneratedColumn<bool> isCancelled = GeneratedColumn<bool>(
      'is_cancelled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_cancelled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        classTemplateId,
        date,
        isCancelled,
        notes,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_exceptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<ClassExceptionEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('class_template_id')) {
      context.handle(
          _classTemplateIdMeta,
          classTemplateId.isAcceptableOrUnknown(
              data['class_template_id']!, _classTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_classTemplateIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_cancelled')) {
      context.handle(
          _isCancelledMeta,
          isCancelled.isAcceptableOrUnknown(
              data['is_cancelled']!, _isCancelledMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  ClassExceptionEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassExceptionEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      classTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}class_template_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      isCancelled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cancelled'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClassExceptionsTable createAlias(String alias) {
    return $ClassExceptionsTable(attachedDatabase, alias);
  }
}

class ClassExceptionEntity extends DataClass
    implements Insertable<ClassExceptionEntity> {
  final String id;
  final String classTemplateId;
  final DateTime date;
  final bool isCancelled;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const ClassExceptionEntity(
      {required this.id,
      required this.classTemplateId,
      required this.date,
      required this.isCancelled,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['class_template_id'] = Variable<String>(classTemplateId);
    map['date'] = Variable<DateTime>(date);
    map['is_cancelled'] = Variable<bool>(isCancelled);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClassExceptionsCompanion toCompanion(bool nullToAbsent) {
    return ClassExceptionsCompanion(
      id: Value(id),
      classTemplateId: Value(classTemplateId),
      date: Value(date),
      isCancelled: Value(isCancelled),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClassExceptionEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassExceptionEntity(
      id: serializer.fromJson<String>(json['id']),
      classTemplateId: serializer.fromJson<String>(json['classTemplateId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isCancelled: serializer.fromJson<bool>(json['isCancelled']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'classTemplateId': serializer.toJson<String>(classTemplateId),
      'date': serializer.toJson<DateTime>(date),
      'isCancelled': serializer.toJson<bool>(isCancelled),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClassExceptionEntity copyWith(
          {String? id,
          String? classTemplateId,
          DateTime? date,
          bool? isCancelled,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ClassExceptionEntity(
        id: id ?? this.id,
        classTemplateId: classTemplateId ?? this.classTemplateId,
        date: date ?? this.date,
        isCancelled: isCancelled ?? this.isCancelled,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ClassExceptionEntity copyWithCompanion(ClassExceptionsCompanion data) {
    return ClassExceptionEntity(
      id: data.id.present ? data.id.value : this.id,
      classTemplateId: data.classTemplateId.present
          ? data.classTemplateId.value
          : this.classTemplateId,
      date: data.date.present ? data.date.value : this.date,
      isCancelled:
          data.isCancelled.present ? data.isCancelled.value : this.isCancelled,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassExceptionEntity(')
          ..write('id: $id, ')
          ..write('classTemplateId: $classTemplateId, ')
          ..write('date: $date, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classTemplateId, date, isCancelled, notes,
      createdAt, updatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassExceptionEntity &&
          other.id == this.id &&
          other.classTemplateId == this.classTemplateId &&
          other.date == this.date &&
          other.isCancelled == this.isCancelled &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClassExceptionsCompanion extends UpdateCompanion<ClassExceptionEntity> {
  final Value<String> id;
  final Value<String> classTemplateId;
  final Value<DateTime> date;
  final Value<bool> isCancelled;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClassExceptionsCompanion({
    this.id = const Value.absent(),
    this.classTemplateId = const Value.absent(),
    this.date = const Value.absent(),
    this.isCancelled = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassExceptionsCompanion.insert({
    required String id,
    required String classTemplateId,
    required DateTime date,
    this.isCancelled = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        classTemplateId = Value(classTemplateId),
        date = Value(date),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClassExceptionEntity> custom({
    Expression<String>? id,
    Expression<String>? classTemplateId,
    Expression<DateTime>? date,
    Expression<bool>? isCancelled,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classTemplateId != null) 'class_template_id': classTemplateId,
      if (date != null) 'date': date,
      if (isCancelled != null) 'is_cancelled': isCancelled,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassExceptionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? classTemplateId,
      Value<DateTime>? date,
      Value<bool>? isCancelled,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ClassExceptionsCompanion(
      id: id ?? this.id,
      classTemplateId: classTemplateId ?? this.classTemplateId,
      date: date ?? this.date,
      isCancelled: isCancelled ?? this.isCancelled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (classTemplateId.present) {
      map['class_template_id'] = Variable<String>(classTemplateId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isCancelled.present) {
      map['is_cancelled'] = Variable<bool>(isCancelled.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('ClassExceptionsCompanion(')
          ..write('id: $id, ')
          ..write('classTemplateId: $classTemplateId, ')
          ..write('date: $date, ')
          ..write('isCancelled: $isCancelled, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, ExamEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weightIdMeta =
      const VerificationMeta('weightId');
  @override
  late final GeneratedColumn<String> weightId = GeneratedColumn<String>(
      'weight_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buildingMeta =
      const VerificationMeta('building');
  @override
  late final GeneratedColumn<String> building = GeneratedColumn<String>(
      'building', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
      'room', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
      'teacher_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isGradedMeta =
      const VerificationMeta('isGraded');
  @override
  late final GeneratedColumn<bool> isGraded = GeneratedColumn<bool>(
      'is_graded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_graded" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<double> grade = GeneratedColumn<double>(
      'grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        name,
        date,
        startTime,
        endTime,
        weightId,
        building,
        room,
        teacherId,
        isCompleted,
        completedAt,
        isGraded,
        grade,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(Insertable<ExamEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('weight_id')) {
      context.handle(_weightIdMeta,
          weightId.isAcceptableOrUnknown(data['weight_id']!, _weightIdMeta));
    }
    if (data.containsKey('building')) {
      context.handle(_buildingMeta,
          building.isAcceptableOrUnknown(data['building']!, _buildingMeta));
    }
    if (data.containsKey('room')) {
      context.handle(
          _roomMeta, room.isAcceptableOrUnknown(data['room']!, _roomMeta));
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('is_graded')) {
      context.handle(_isGradedMeta,
          isGraded.isAcceptableOrUnknown(data['is_graded']!, _isGradedMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  ExamEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      weightId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weight_id']),
      building: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}building']),
      room: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room']),
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_id']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      isGraded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_graded'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}grade']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class ExamEntity extends DataClass implements Insertable<ExamEntity> {
  final String id;
  final String subjectId;
  final String name;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? weightId;
  final String? building;
  final String? room;
  final String? teacherId;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isGraded;
  final double? grade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const ExamEntity(
      {required this.id,
      required this.subjectId,
      required this.name,
      required this.date,
      required this.startTime,
      required this.endTime,
      this.weightId,
      this.building,
      this.room,
      this.teacherId,
      required this.isCompleted,
      this.completedAt,
      required this.isGraded,
      this.grade,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    if (!nullToAbsent || weightId != null) {
      map['weight_id'] = Variable<String>(weightId);
    }
    if (!nullToAbsent || building != null) {
      map['building'] = Variable<String>(building);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_graded'] = Variable<bool>(isGraded);
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<double>(grade);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      name: Value(name),
      date: Value(date),
      startTime: Value(startTime),
      endTime: Value(endTime),
      weightId: weightId == null && nullToAbsent
          ? const Value.absent()
          : Value(weightId),
      building: building == null && nullToAbsent
          ? const Value.absent()
          : Value(building),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isGraded: Value(isGraded),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ExamEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamEntity(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      weightId: serializer.fromJson<String?>(json['weightId']),
      building: serializer.fromJson<String?>(json['building']),
      room: serializer.fromJson<String?>(json['room']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isGraded: serializer.fromJson<bool>(json['isGraded']),
      grade: serializer.fromJson<double?>(json['grade']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'weightId': serializer.toJson<String?>(weightId),
      'building': serializer.toJson<String?>(building),
      'room': serializer.toJson<String?>(room),
      'teacherId': serializer.toJson<String?>(teacherId),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isGraded': serializer.toJson<bool>(isGraded),
      'grade': serializer.toJson<double?>(grade),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ExamEntity copyWith(
          {String? id,
          String? subjectId,
          String? name,
          DateTime? date,
          String? startTime,
          String? endTime,
          Value<String?> weightId = const Value.absent(),
          Value<String?> building = const Value.absent(),
          Value<String?> room = const Value.absent(),
          Value<String?> teacherId = const Value.absent(),
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          bool? isGraded,
          Value<double?> grade = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ExamEntity(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        date: date ?? this.date,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        weightId: weightId.present ? weightId.value : this.weightId,
        building: building.present ? building.value : this.building,
        room: room.present ? room.value : this.room,
        teacherId: teacherId.present ? teacherId.value : this.teacherId,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        isGraded: isGraded ?? this.isGraded,
        grade: grade.present ? grade.value : this.grade,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ExamEntity copyWithCompanion(ExamsCompanion data) {
    return ExamEntity(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      weightId: data.weightId.present ? data.weightId.value : this.weightId,
      building: data.building.present ? data.building.value : this.building,
      room: data.room.present ? data.room.value : this.room,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      isGraded: data.isGraded.present ? data.isGraded.value : this.isGraded,
      grade: data.grade.present ? data.grade.value : this.grade,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamEntity(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weightId: $weightId, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('teacherId: $teacherId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isGraded: $isGraded, ')
          ..write('grade: $grade, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      subjectId,
      name,
      date,
      startTime,
      endTime,
      weightId,
      building,
      room,
      teacherId,
      isCompleted,
      completedAt,
      isGraded,
      grade,
      createdAt,
      updatedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamEntity &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.weightId == this.weightId &&
          other.building == this.building &&
          other.room == this.room &&
          other.teacherId == this.teacherId &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.isGraded == this.isGraded &&
          other.grade == this.grade &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ExamsCompanion extends UpdateCompanion<ExamEntity> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String?> weightId;
  final Value<String?> building;
  final Value<String?> room;
  final Value<String?> teacherId;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<bool> isGraded;
  final Value<double?> grade;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.weightId = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.grade = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamsCompanion.insert({
    required String id,
    required String subjectId,
    required String name,
    required DateTime date,
    required String startTime,
    required String endTime,
    this.weightId = const Value.absent(),
    this.building = const Value.absent(),
    this.room = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.grade = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        name = Value(name),
        date = Value(date),
        startTime = Value(startTime),
        endTime = Value(endTime),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ExamEntity> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? weightId,
    Expression<String>? building,
    Expression<String>? room,
    Expression<String>? teacherId,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<bool>? isGraded,
    Expression<double>? grade,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (weightId != null) 'weight_id': weightId,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacher_id': teacherId,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (isGraded != null) 'is_graded': isGraded,
      if (grade != null) 'grade': grade,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? name,
      Value<DateTime>? date,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String?>? weightId,
      Value<String?>? building,
      Value<String?>? room,
      Value<String?>? teacherId,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<bool>? isGraded,
      Value<double?>? grade,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ExamsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weightId: weightId ?? this.weightId,
      building: building ?? this.building,
      room: room ?? this.room,
      teacherId: teacherId ?? this.teacherId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isGraded: isGraded ?? this.isGraded,
      grade: grade ?? this.grade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (weightId.present) {
      map['weight_id'] = Variable<String>(weightId.value);
    }
    if (building.present) {
      map['building'] = Variable<String>(building.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isGraded.present) {
      map['is_graded'] = Variable<bool>(isGraded.value);
    }
    if (grade.present) {
      map['grade'] = Variable<double>(grade.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('ExamsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('weightId: $weightId, ')
          ..write('building: $building, ')
          ..write('room: $room, ')
          ..write('teacherId: $teacherId, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('isGraded: $isGraded, ')
          ..write('grade: $grade, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeachersTable extends Teachers
    with TableInfo<$TeachersTable, TeacherEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeachersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
      'position', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _affiliationMeta =
      const VerificationMeta('affiliation');
  @override
  late final GeneratedColumn<String> affiliation = GeneratedColumn<String>(
      'affiliation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _webPageMeta =
      const VerificationMeta('webPage');
  @override
  late final GeneratedColumn<String> webPage = GeneratedColumn<String>(
      'web_page', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _officeHoursJsonMeta =
      const VerificationMeta('officeHoursJson');
  @override
  late final GeneratedColumn<String> officeHoursJson = GeneratedColumn<String>(
      'office_hours_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        position,
        department,
        affiliation,
        email,
        phone,
        webPage,
        officeHoursJson,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teachers';
  @override
  VerificationContext validateIntegrity(Insertable<TeacherEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    }
    if (data.containsKey('affiliation')) {
      context.handle(
          _affiliationMeta,
          affiliation.isAcceptableOrUnknown(
              data['affiliation']!, _affiliationMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('web_page')) {
      context.handle(_webPageMeta,
          webPage.isAcceptableOrUnknown(data['web_page']!, _webPageMeta));
    }
    if (data.containsKey('office_hours_json')) {
      context.handle(
          _officeHoursJsonMeta,
          officeHoursJson.isAcceptableOrUnknown(
              data['office_hours_json']!, _officeHoursJsonMeta));
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  TeacherEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}position']),
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department']),
      affiliation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}affiliation']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      webPage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}web_page']),
      officeHoursJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}office_hours_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $TeachersTable createAlias(String alias) {
    return $TeachersTable(attachedDatabase, alias);
  }
}

class TeacherEntity extends DataClass implements Insertable<TeacherEntity> {
  final String id;
  final String userId;
  final String name;
  final String? position;
  final String? department;
  final String? affiliation;
  final String? email;
  final String? phone;
  final String? webPage;
  final String officeHoursJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const TeacherEntity(
      {required this.id,
      required this.userId,
      required this.name,
      this.position,
      this.department,
      this.affiliation,
      this.email,
      this.phone,
      this.webPage,
      required this.officeHoursJson,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    if (!nullToAbsent || affiliation != null) {
      map['affiliation'] = Variable<String>(affiliation);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || webPage != null) {
      map['web_page'] = Variable<String>(webPage);
    }
    map['office_hours_json'] = Variable<String>(officeHoursJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  TeachersCompanion toCompanion(bool nullToAbsent) {
    return TeachersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
      affiliation: affiliation == null && nullToAbsent
          ? const Value.absent()
          : Value(affiliation),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      webPage: webPage == null && nullToAbsent
          ? const Value.absent()
          : Value(webPage),
      officeHoursJson: Value(officeHoursJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory TeacherEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherEntity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<String?>(json['position']),
      department: serializer.fromJson<String?>(json['department']),
      affiliation: serializer.fromJson<String?>(json['affiliation']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      webPage: serializer.fromJson<String?>(json['webPage']),
      officeHoursJson: serializer.fromJson<String>(json['officeHoursJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<String?>(position),
      'department': serializer.toJson<String?>(department),
      'affiliation': serializer.toJson<String?>(affiliation),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'webPage': serializer.toJson<String?>(webPage),
      'officeHoursJson': serializer.toJson<String>(officeHoursJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  TeacherEntity copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> position = const Value.absent(),
          Value<String?> department = const Value.absent(),
          Value<String?> affiliation = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> webPage = const Value.absent(),
          String? officeHoursJson,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      TeacherEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        position: position.present ? position.value : this.position,
        department: department.present ? department.value : this.department,
        affiliation: affiliation.present ? affiliation.value : this.affiliation,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        webPage: webPage.present ? webPage.value : this.webPage,
        officeHoursJson: officeHoursJson ?? this.officeHoursJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  TeacherEntity copyWithCompanion(TeachersCompanion data) {
    return TeacherEntity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      department:
          data.department.present ? data.department.value : this.department,
      affiliation:
          data.affiliation.present ? data.affiliation.value : this.affiliation,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      webPage: data.webPage.present ? data.webPage.value : this.webPage,
      officeHoursJson: data.officeHoursJson.present
          ? data.officeHoursJson.value
          : this.officeHoursJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherEntity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('department: $department, ')
          ..write('affiliation: $affiliation, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('webPage: $webPage, ')
          ..write('officeHoursJson: $officeHoursJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      name,
      position,
      department,
      affiliation,
      email,
      phone,
      webPage,
      officeHoursJson,
      createdAt,
      updatedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherEntity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.position == this.position &&
          other.department == this.department &&
          other.affiliation == this.affiliation &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.webPage == this.webPage &&
          other.officeHoursJson == this.officeHoursJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class TeachersCompanion extends UpdateCompanion<TeacherEntity> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> position;
  final Value<String?> department;
  final Value<String?> affiliation;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> webPage;
  final Value<String> officeHoursJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const TeachersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.department = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.webPage = const Value.absent(),
    this.officeHoursJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeachersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.position = const Value.absent(),
    this.department = const Value.absent(),
    this.affiliation = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.webPage = const Value.absent(),
    this.officeHoursJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<TeacherEntity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? position,
    Expression<String>? department,
    Expression<String>? affiliation,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? webPage,
    Expression<String>? officeHoursJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (department != null) 'department': department,
      if (affiliation != null) 'affiliation': affiliation,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (webPage != null) 'web_page': webPage,
      if (officeHoursJson != null) 'office_hours_json': officeHoursJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeachersCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? position,
      Value<String?>? department,
      Value<String?>? affiliation,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String?>? webPage,
      Value<String>? officeHoursJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return TeachersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      affiliation: affiliation ?? this.affiliation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      webPage: webPage ?? this.webPage,
      officeHoursJson: officeHoursJson ?? this.officeHoursJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (affiliation.present) {
      map['affiliation'] = Variable<String>(affiliation.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (webPage.present) {
      map['web_page'] = Variable<String>(webPage.value);
    }
    if (officeHoursJson.present) {
      map['office_hours_json'] = Variable<String>(officeHoursJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('TeachersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('department: $department, ')
          ..write('affiliation: $affiliation, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('webPage: $webPage, ')
          ..write('officeHoursJson: $officeHoursJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidaysTable extends Holidays
    with TableInfo<$HolidaysTable, HolidayEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        startDate,
        endDate,
        source,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holidays';
  @override
  VerificationContext validateIntegrity(Insertable<HolidayEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  HolidayEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $HolidaysTable createAlias(String alias) {
    return $HolidaysTable(attachedDatabase, alias);
  }
}

class HolidayEntity extends DataClass implements Insertable<HolidayEntity> {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const HolidayEntity(
      {required this.id,
      required this.userId,
      required this.name,
      required this.startDate,
      required this.endDate,
      required this.source,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  HolidaysCompanion toCompanion(bool nullToAbsent) {
    return HolidaysCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      startDate: Value(startDate),
      endDate: Value(endDate),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory HolidayEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayEntity(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  HolidayEntity copyWith(
          {String? id,
          String? userId,
          String? name,
          DateTime? startDate,
          DateTime? endDate,
          String? source,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      HolidayEntity(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  HolidayEntity copyWithCompanion(HolidaysCompanion data) {
    return HolidayEntity(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayEntity(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, startDate, endDate, source,
      createdAt, updatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayEntity &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class HolidaysCompanion extends UpdateCompanion<HolidayEntity> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const HolidaysCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidaysCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        startDate = Value(startDate),
        endDate = Value(endDate),
        source = Value(source),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<HolidayEntity> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? source,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return HolidaysCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('HolidaysCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultClassDurationMeta =
      const VerificationMeta('defaultClassDuration');
  @override
  late final GeneratedColumn<int> defaultClassDuration = GeneratedColumn<int>(
      'default_class_duration', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _weekdaysJsonMeta =
      const VerificationMeta('weekdaysJson');
  @override
  late final GeneratedColumn<String> weekdaysJson = GeneratedColumn<String>(
      'weekdays_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[1,2,3,4,5]'));
  static const VerificationMeta _gradingScaleJsonMeta =
      const VerificationMeta('gradingScaleJson');
  @override
  late final GeneratedColumn<String> gradingScaleJson = GeneratedColumn<String>(
      'grading_scale_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _holidayCountryMeta =
      const VerificationMeta('holidayCountry');
  @override
  late final GeneratedColumn<String> holidayCountry = GeneratedColumn<String>(
      'holiday_country', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('CO'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        defaultClassDuration,
        weekdaysJson,
        gradingScaleJson,
        holidayCountry,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('default_class_duration')) {
      context.handle(
          _defaultClassDurationMeta,
          defaultClassDuration.isAcceptableOrUnknown(
              data['default_class_duration']!, _defaultClassDurationMeta));
    }
    if (data.containsKey('weekdays_json')) {
      context.handle(
          _weekdaysJsonMeta,
          weekdaysJson.isAcceptableOrUnknown(
              data['weekdays_json']!, _weekdaysJsonMeta));
    }
    if (data.containsKey('grading_scale_json')) {
      context.handle(
          _gradingScaleJsonMeta,
          gradingScaleJson.isAcceptableOrUnknown(
              data['grading_scale_json']!, _gradingScaleJsonMeta));
    } else if (isInserting) {
      context.missing(_gradingScaleJsonMeta);
    }
    if (data.containsKey('holiday_country')) {
      context.handle(
          _holidayCountryMeta,
          holidayCountry.isAcceptableOrUnknown(
              data['holiday_country']!, _holidayCountryMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  SettingsEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntity(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      defaultClassDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}default_class_duration'])!,
      weekdaysJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weekdays_json'])!,
      gradingScaleJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}grading_scale_json'])!,
      holidayCountry: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}holiday_country'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsEntity extends DataClass implements Insertable<SettingsEntity> {
  final String userId;
  final int defaultClassDuration;
  final String weekdaysJson;
  final String gradingScaleJson;
  final String holidayCountry;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const SettingsEntity(
      {required this.userId,
      required this.defaultClassDuration,
      required this.weekdaysJson,
      required this.gradingScaleJson,
      required this.holidayCountry,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['default_class_duration'] = Variable<int>(defaultClassDuration);
    map['weekdays_json'] = Variable<String>(weekdaysJson);
    map['grading_scale_json'] = Variable<String>(gradingScaleJson);
    map['holiday_country'] = Variable<String>(holidayCountry);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      userId: Value(userId),
      defaultClassDuration: Value(defaultClassDuration),
      weekdaysJson: Value(weekdaysJson),
      gradingScaleJson: Value(gradingScaleJson),
      holidayCountry: Value(holidayCountry),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory SettingsEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntity(
      userId: serializer.fromJson<String>(json['userId']),
      defaultClassDuration:
          serializer.fromJson<int>(json['defaultClassDuration']),
      weekdaysJson: serializer.fromJson<String>(json['weekdaysJson']),
      gradingScaleJson: serializer.fromJson<String>(json['gradingScaleJson']),
      holidayCountry: serializer.fromJson<String>(json['holidayCountry']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'defaultClassDuration': serializer.toJson<int>(defaultClassDuration),
      'weekdaysJson': serializer.toJson<String>(weekdaysJson),
      'gradingScaleJson': serializer.toJson<String>(gradingScaleJson),
      'holidayCountry': serializer.toJson<String>(holidayCountry),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  SettingsEntity copyWith(
          {String? userId,
          int? defaultClassDuration,
          String? weekdaysJson,
          String? gradingScaleJson,
          String? holidayCountry,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      SettingsEntity(
        userId: userId ?? this.userId,
        defaultClassDuration: defaultClassDuration ?? this.defaultClassDuration,
        weekdaysJson: weekdaysJson ?? this.weekdaysJson,
        gradingScaleJson: gradingScaleJson ?? this.gradingScaleJson,
        holidayCountry: holidayCountry ?? this.holidayCountry,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  SettingsEntity copyWithCompanion(SettingsCompanion data) {
    return SettingsEntity(
      userId: data.userId.present ? data.userId.value : this.userId,
      defaultClassDuration: data.defaultClassDuration.present
          ? data.defaultClassDuration.value
          : this.defaultClassDuration,
      weekdaysJson: data.weekdaysJson.present
          ? data.weekdaysJson.value
          : this.weekdaysJson,
      gradingScaleJson: data.gradingScaleJson.present
          ? data.gradingScaleJson.value
          : this.gradingScaleJson,
      holidayCountry: data.holidayCountry.present
          ? data.holidayCountry.value
          : this.holidayCountry,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntity(')
          ..write('userId: $userId, ')
          ..write('defaultClassDuration: $defaultClassDuration, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('gradingScaleJson: $gradingScaleJson, ')
          ..write('holidayCountry: $holidayCountry, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, defaultClassDuration, weekdaysJson,
      gradingScaleJson, holidayCountry, updatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsEntity &&
          other.userId == this.userId &&
          other.defaultClassDuration == this.defaultClassDuration &&
          other.weekdaysJson == this.weekdaysJson &&
          other.gradingScaleJson == this.gradingScaleJson &&
          other.holidayCountry == this.holidayCountry &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SettingsCompanion extends UpdateCompanion<SettingsEntity> {
  final Value<String> userId;
  final Value<int> defaultClassDuration;
  final Value<String> weekdaysJson;
  final Value<String> gradingScaleJson;
  final Value<String> holidayCountry;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const SettingsCompanion({
    this.userId = const Value.absent(),
    this.defaultClassDuration = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    this.gradingScaleJson = const Value.absent(),
    this.holidayCountry = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String userId,
    this.defaultClassDuration = const Value.absent(),
    this.weekdaysJson = const Value.absent(),
    required String gradingScaleJson,
    this.holidayCountry = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        gradingScaleJson = Value(gradingScaleJson),
        updatedAt = Value(updatedAt);
  static Insertable<SettingsEntity> custom({
    Expression<String>? userId,
    Expression<int>? defaultClassDuration,
    Expression<String>? weekdaysJson,
    Expression<String>? gradingScaleJson,
    Expression<String>? holidayCountry,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (defaultClassDuration != null)
        'default_class_duration': defaultClassDuration,
      if (weekdaysJson != null) 'weekdays_json': weekdaysJson,
      if (gradingScaleJson != null) 'grading_scale_json': gradingScaleJson,
      if (holidayCountry != null) 'holiday_country': holidayCountry,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? userId,
      Value<int>? defaultClassDuration,
      Value<String>? weekdaysJson,
      Value<String>? gradingScaleJson,
      Value<String>? holidayCountry,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return SettingsCompanion(
      userId: userId ?? this.userId,
      defaultClassDuration: defaultClassDuration ?? this.defaultClassDuration,
      weekdaysJson: weekdaysJson ?? this.weekdaysJson,
      gradingScaleJson: gradingScaleJson ?? this.gradingScaleJson,
      holidayCountry: holidayCountry ?? this.holidayCountry,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (defaultClassDuration.present) {
      map['default_class_duration'] = Variable<int>(defaultClassDuration.value);
    }
    if (weekdaysJson.present) {
      map['weekdays_json'] = Variable<String>(weekdaysJson.value);
    }
    if (gradingScaleJson.present) {
      map['grading_scale_json'] = Variable<String>(gradingScaleJson.value);
    }
    if (holidayCountry.present) {
      map['holiday_country'] = Variable<String>(holidayCountry.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('SettingsCompanion(')
          ..write('userId: $userId, ')
          ..write('defaultClassDuration: $defaultClassDuration, ')
          ..write('weekdaysJson: $weekdaysJson, ')
          ..write('gradingScaleJson: $gradingScaleJson, ')
          ..write('holidayCountry: $holidayCountry, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, GroupEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _membersJsonMeta =
      const VerificationMeta('membersJson');
  @override
  late final GeneratedColumn<String> membersJson = GeneratedColumn<String>(
      'members_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _inviteCodeMeta =
      const VerificationMeta('inviteCode');
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
      'invite_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        color,
        ownerId,
        membersJson,
        inviteCode,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<GroupEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('members_json')) {
      context.handle(
          _membersJsonMeta,
          membersJson.isAcceptableOrUnknown(
              data['members_json']!, _membersJsonMeta));
    }
    if (data.containsKey('invite_code')) {
      context.handle(
          _inviteCodeMeta,
          inviteCode.isAcceptableOrUnknown(
              data['invite_code']!, _inviteCodeMeta));
    } else if (isInserting) {
      context.missing(_inviteCodeMeta);
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
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  GroupEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      membersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}members_json'])!,
      inviteCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invite_code'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class GroupEntity extends DataClass implements Insertable<GroupEntity> {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String ownerId;
  final String membersJson;
  final String inviteCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const GroupEntity(
      {required this.id,
      required this.name,
      this.description,
      required this.color,
      required this.ownerId,
      required this.membersJson,
      required this.inviteCode,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['color'] = Variable<String>(color);
    map['owner_id'] = Variable<String>(ownerId);
    map['members_json'] = Variable<String>(membersJson);
    map['invite_code'] = Variable<String>(inviteCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: Value(color),
      ownerId: Value(ownerId),
      membersJson: Value(membersJson),
      inviteCode: Value(inviteCode),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory GroupEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupEntity(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<String>(json['color']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      membersJson: serializer.fromJson<String>(json['membersJson']),
      inviteCode: serializer.fromJson<String>(json['inviteCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<String>(color),
      'ownerId': serializer.toJson<String>(ownerId),
      'membersJson': serializer.toJson<String>(membersJson),
      'inviteCode': serializer.toJson<String>(inviteCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  GroupEntity copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? color,
          String? ownerId,
          String? membersJson,
          String? inviteCode,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      GroupEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        color: color ?? this.color,
        ownerId: ownerId ?? this.ownerId,
        membersJson: membersJson ?? this.membersJson,
        inviteCode: inviteCode ?? this.inviteCode,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  GroupEntity copyWithCompanion(GroupsCompanion data) {
    return GroupEntity(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      color: data.color.present ? data.color.value : this.color,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      membersJson:
          data.membersJson.present ? data.membersJson.value : this.membersJson,
      inviteCode:
          data.inviteCode.present ? data.inviteCode.value : this.inviteCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupEntity(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('ownerId: $ownerId, ')
          ..write('membersJson: $membersJson, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, color, ownerId,
      membersJson, inviteCode, createdAt, updatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupEntity &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color &&
          other.ownerId == this.ownerId &&
          other.membersJson == this.membersJson &&
          other.inviteCode == this.inviteCode &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class GroupsCompanion extends UpdateCompanion<GroupEntity> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> color;
  final Value<String> ownerId;
  final Value<String> membersJson;
  final Value<String> inviteCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.membersJson = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String color,
    required String ownerId,
    this.membersJson = const Value.absent(),
    required String inviteCode,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        color = Value(color),
        ownerId = Value(ownerId),
        inviteCode = Value(inviteCode),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<GroupEntity> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? color,
    Expression<String>? ownerId,
    Expression<String>? membersJson,
    Expression<String>? inviteCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (ownerId != null) 'owner_id': ownerId,
      if (membersJson != null) 'members_json': membersJson,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? color,
      Value<String>? ownerId,
      Value<String>? membersJson,
      Value<String>? inviteCode,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      ownerId: ownerId ?? this.ownerId,
      membersJson: membersJson ?? this.membersJson,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (membersJson.present) {
      map['members_json'] = Variable<String>(membersJson.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('ownerId: $ownerId, ')
          ..write('membersJson: $membersJson, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyAvailabilitiesTable extends WeeklyAvailabilities
    with TableInfo<$WeeklyAvailabilitiesTable, WeeklyAvailabilityEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyAvailabilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekIdentifierMeta =
      const VerificationMeta('weekIdentifier');
  @override
  late final GeneratedColumn<String> weekIdentifier = GeneratedColumn<String>(
      'week_identifier', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekStartDateMeta =
      const VerificationMeta('weekStartDate');
  @override
  late final GeneratedColumn<DateTime> weekStartDate =
      GeneratedColumn<DateTime>('week_start_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weekEndDateMeta =
      const VerificationMeta('weekEndDate');
  @override
  late final GeneratedColumn<DateTime> weekEndDate = GeneratedColumn<DateTime>(
      'week_end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dailySlotsJsonMeta =
      const VerificationMeta('dailySlotsJson');
  @override
  late final GeneratedColumn<String> dailySlotsJson = GeneratedColumn<String>(
      'daily_slots_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAtMeta =
      const VerificationMeta('calculatedAt');
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
      'calculated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        weekIdentifier,
        weekStartDate,
        weekEndDate,
        dailySlotsJson,
        calculatedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_availabilities';
  @override
  VerificationContext validateIntegrity(
      Insertable<WeeklyAvailabilityEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('week_identifier')) {
      context.handle(
          _weekIdentifierMeta,
          weekIdentifier.isAcceptableOrUnknown(
              data['week_identifier']!, _weekIdentifierMeta));
    } else if (isInserting) {
      context.missing(_weekIdentifierMeta);
    }
    if (data.containsKey('week_start_date')) {
      context.handle(
          _weekStartDateMeta,
          weekStartDate.isAcceptableOrUnknown(
              data['week_start_date']!, _weekStartDateMeta));
    } else if (isInserting) {
      context.missing(_weekStartDateMeta);
    }
    if (data.containsKey('week_end_date')) {
      context.handle(
          _weekEndDateMeta,
          weekEndDate.isAcceptableOrUnknown(
              data['week_end_date']!, _weekEndDateMeta));
    } else if (isInserting) {
      context.missing(_weekEndDateMeta);
    }
    if (data.containsKey('daily_slots_json')) {
      context.handle(
          _dailySlotsJsonMeta,
          dailySlotsJson.isAcceptableOrUnknown(
              data['daily_slots_json']!, _dailySlotsJsonMeta));
    } else if (isInserting) {
      context.missing(_dailySlotsJsonMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
          _calculatedAtMeta,
          calculatedAt.isAcceptableOrUnknown(
              data['calculated_at']!, _calculatedAtMeta));
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  WeeklyAvailabilityEntity map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyAvailabilityEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      weekIdentifier: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}week_identifier'])!,
      weekStartDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}week_start_date'])!,
      weekEndDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}week_end_date'])!,
      dailySlotsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}daily_slots_json'])!,
      calculatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}calculated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $WeeklyAvailabilitiesTable createAlias(String alias) {
    return $WeeklyAvailabilitiesTable(attachedDatabase, alias);
  }
}

class WeeklyAvailabilityEntity extends DataClass
    implements Insertable<WeeklyAvailabilityEntity> {
  final String id;
  final String groupId;
  final String weekIdentifier;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final String dailySlotsJson;
  final DateTime calculatedAt;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  const WeeklyAvailabilityEntity(
      {required this.id,
      required this.groupId,
      required this.weekIdentifier,
      required this.weekStartDate,
      required this.weekEndDate,
      required this.dailySlotsJson,
      required this.calculatedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['week_identifier'] = Variable<String>(weekIdentifier);
    map['week_start_date'] = Variable<DateTime>(weekStartDate);
    map['week_end_date'] = Variable<DateTime>(weekEndDate);
    map['daily_slots_json'] = Variable<String>(dailySlotsJson);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  WeeklyAvailabilitiesCompanion toCompanion(bool nullToAbsent) {
    return WeeklyAvailabilitiesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      weekIdentifier: Value(weekIdentifier),
      weekStartDate: Value(weekStartDate),
      weekEndDate: Value(weekEndDate),
      dailySlotsJson: Value(dailySlotsJson),
      calculatedAt: Value(calculatedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory WeeklyAvailabilityEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyAvailabilityEntity(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      weekIdentifier: serializer.fromJson<String>(json['weekIdentifier']),
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      weekEndDate: serializer.fromJson<DateTime>(json['weekEndDate']),
      dailySlotsJson: serializer.fromJson<String>(json['dailySlotsJson']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'weekIdentifier': serializer.toJson<String>(weekIdentifier),
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'weekEndDate': serializer.toJson<DateTime>(weekEndDate),
      'dailySlotsJson': serializer.toJson<String>(dailySlotsJson),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  WeeklyAvailabilityEntity copyWith(
          {String? id,
          String? groupId,
          String? weekIdentifier,
          DateTime? weekStartDate,
          DateTime? weekEndDate,
          String? dailySlotsJson,
          DateTime? calculatedAt,
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      WeeklyAvailabilityEntity(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        weekIdentifier: weekIdentifier ?? this.weekIdentifier,
        weekStartDate: weekStartDate ?? this.weekStartDate,
        weekEndDate: weekEndDate ?? this.weekEndDate,
        dailySlotsJson: dailySlotsJson ?? this.dailySlotsJson,
        calculatedAt: calculatedAt ?? this.calculatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  WeeklyAvailabilityEntity copyWithCompanion(
      WeeklyAvailabilitiesCompanion data) {
    return WeeklyAvailabilityEntity(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      weekIdentifier: data.weekIdentifier.present
          ? data.weekIdentifier.value
          : this.weekIdentifier,
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      weekEndDate:
          data.weekEndDate.present ? data.weekEndDate.value : this.weekEndDate,
      dailySlotsJson: data.dailySlotsJson.present
          ? data.dailySlotsJson.value
          : this.dailySlotsJson,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyAvailabilityEntity(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('weekIdentifier: $weekIdentifier, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('dailySlotsJson: $dailySlotsJson, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, weekIdentifier, weekStartDate,
      weekEndDate, dailySlotsJson, calculatedAt, syncStatus, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyAvailabilityEntity &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.weekIdentifier == this.weekIdentifier &&
          other.weekStartDate == this.weekStartDate &&
          other.weekEndDate == this.weekEndDate &&
          other.dailySlotsJson == this.dailySlotsJson &&
          other.calculatedAt == this.calculatedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class WeeklyAvailabilitiesCompanion
    extends UpdateCompanion<WeeklyAvailabilityEntity> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> weekIdentifier;
  final Value<DateTime> weekStartDate;
  final Value<DateTime> weekEndDate;
  final Value<String> dailySlotsJson;
  final Value<DateTime> calculatedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const WeeklyAvailabilitiesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.weekIdentifier = const Value.absent(),
    this.weekStartDate = const Value.absent(),
    this.weekEndDate = const Value.absent(),
    this.dailySlotsJson = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyAvailabilitiesCompanion.insert({
    required String id,
    required String groupId,
    required String weekIdentifier,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required String dailySlotsJson,
    required DateTime calculatedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        weekIdentifier = Value(weekIdentifier),
        weekStartDate = Value(weekStartDate),
        weekEndDate = Value(weekEndDate),
        dailySlotsJson = Value(dailySlotsJson),
        calculatedAt = Value(calculatedAt);
  static Insertable<WeeklyAvailabilityEntity> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? weekIdentifier,
    Expression<DateTime>? weekStartDate,
    Expression<DateTime>? weekEndDate,
    Expression<String>? dailySlotsJson,
    Expression<DateTime>? calculatedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (weekIdentifier != null) 'week_identifier': weekIdentifier,
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (weekEndDate != null) 'week_end_date': weekEndDate,
      if (dailySlotsJson != null) 'daily_slots_json': dailySlotsJson,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyAvailabilitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? weekIdentifier,
      Value<DateTime>? weekStartDate,
      Value<DateTime>? weekEndDate,
      Value<String>? dailySlotsJson,
      Value<DateTime>? calculatedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return WeeklyAvailabilitiesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      weekIdentifier: weekIdentifier ?? this.weekIdentifier,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      dailySlotsJson: dailySlotsJson ?? this.dailySlotsJson,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (weekIdentifier.present) {
      map['week_identifier'] = Variable<String>(weekIdentifier.value);
    }
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<DateTime>(weekStartDate.value);
    }
    if (weekEndDate.present) {
      map['week_end_date'] = Variable<DateTime>(weekEndDate.value);
    }
    if (dailySlotsJson.present) {
      map['daily_slots_json'] = Variable<String>(dailySlotsJson.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
    return (StringBuffer('WeeklyAvailabilitiesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('weekIdentifier: $weekIdentifier, ')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('dailySlotsJson: $dailySlotsJson, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataJsonMeta =
      const VerificationMeta('dataJson');
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
      'data_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentPathMeta =
      const VerificationMeta('documentPath');
  @override
  late final GeneratedColumn<String> documentPath = GeneratedColumn<String>(
      'document_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        dataJson,
        documentPath,
        createdAt,
        retryCount,
        errorMessage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(_dataJsonMeta,
          dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta));
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('document_path')) {
      context.handle(
          _documentPathMeta,
          documentPath.isAcceptableOrUnknown(
              data['document_path']!, _documentPathMeta));
    } else if (isInserting) {
      context.missing(_documentPathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_json'])!,
      documentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_path'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueEntity extends DataClass implements Insertable<SyncQueueEntity> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String dataJson;
  final String documentPath;
  final DateTime createdAt;
  final int retryCount;
  final String? errorMessage;
  const SyncQueueEntity(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.dataJson,
      required this.documentPath,
      required this.createdAt,
      required this.retryCount,
      this.errorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['data_json'] = Variable<String>(dataJson);
    map['document_path'] = Variable<String>(documentPath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      dataJson: Value(dataJson),
      documentPath: Value(documentPath),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntity(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      documentPath: serializer.fromJson<String>(json['documentPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'dataJson': serializer.toJson<String>(dataJson),
      'documentPath': serializer.toJson<String>(documentPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueEntity copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? dataJson,
          String? documentPath,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent()}) =>
      SyncQueueEntity(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        dataJson: dataJson ?? this.dataJson,
        documentPath: documentPath ?? this.documentPath,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );
  SyncQueueEntity copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueEntity(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      documentPath: data.documentPath.present
          ? data.documentPath.value
          : this.documentPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntity(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('dataJson: $dataJson, ')
          ..write('documentPath: $documentPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, dataJson,
      documentPath, createdAt, retryCount, errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntity &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.dataJson == this.dataJson &&
          other.documentPath == this.documentPath &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueEntity> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> dataJson;
  final Value<String> documentPath;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.documentPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String dataJson,
    required String documentPath,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        dataJson = Value(dataJson),
        documentPath = Value(documentPath),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueEntity> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? dataJson,
    Expression<String>? documentPath,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (dataJson != null) 'data_json': dataJson,
      if (documentPath != null) 'document_path': documentPath,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? dataJson,
      Value<String>? documentPath,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? errorMessage}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      dataJson: dataJson ?? this.dataJson,
      documentPath: documentPath ?? this.documentPath,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (documentPath.present) {
      map['document_path'] = Variable<String>(documentPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('dataJson: $dataJson, ')
          ..write('documentPath: $documentPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TermsTable terms = $TermsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $ClassTemplatesTable classTemplates = $ClassTemplatesTable(this);
  late final $ClassExceptionsTable classExceptions =
      $ClassExceptionsTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $TeachersTable teachers = $TeachersTable(this);
  late final $HolidaysTable holidays = $HolidaysTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $WeeklyAvailabilitiesTable weeklyAvailabilities =
      $WeeklyAvailabilitiesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final TermDao termDao = TermDao(this as AppDatabase);
  late final SubjectDao subjectDao = SubjectDao(this as AppDatabase);
  late final AssignmentDao assignmentDao = AssignmentDao(this as AppDatabase);
  late final ClassDao classDao = ClassDao(this as AppDatabase);
  late final ExamDao examDao = ExamDao(this as AppDatabase);
  late final TeacherDao teacherDao = TeacherDao(this as AppDatabase);
  late final HolidayDao holidayDao = HolidayDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final GroupDao groupDao = GroupDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        terms,
        subjects,
        assignments,
        classTemplates,
        classExceptions,
        exams,
        teachers,
        holidays,
        settings,
        groups,
        weeklyAvailabilities,
        syncQueue
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String uid,
  required String email,
  required String nickname,
  Value<String?> avatar,
  required DateTime createdAt,
  Value<DateTime?> lastLogin,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> uid,
  Value<String> email,
  Value<String> nickname,
  Value<String?> avatar,
  Value<DateTime> createdAt,
  Value<DateTime?> lastLogin,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLogin => $composableBuilder(
      column: $table.lastLogin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLogin =>
      $composableBuilder(column: $table.lastLogin, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            uid: uid,
            email: email,
            nickname: nickname,
            avatar: avatar,
            createdAt: createdAt,
            lastLogin: lastLogin,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uid,
            required String email,
            required String nickname,
            Value<String?> avatar = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastLogin = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            uid: uid,
            email: email,
            nickname: nickname,
            avatar: avatar,
            createdAt: createdAt,
            lastLogin: lastLogin,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserEntity,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserEntity, BaseReferences<_$AppDatabase, $UsersTable, UserEntity>),
    UserEntity,
    PrefetchHooks Function()>;
typedef $$TermsTableCreateCompanionBuilder = TermsCompanion Function({
  required String id,
  required String userId,
  required String name,
  required DateTime startDate,
  required DateTime endDate,
  Value<bool> isActive,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$TermsTableUpdateCompanionBuilder = TermsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$TermsTableFilterComposer extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$TermsTableOrderingComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TermsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$TermsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TermsTable,
    TermEntity,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (TermEntity, BaseReferences<_$AppDatabase, $TermsTable, TermEntity>),
    TermEntity,
    PrefetchHooks Function()> {
  $$TermsTableTableManager(_$AppDatabase db, $TermsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required DateTime startDate,
            required DateTime endDate,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TermsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TermsTable,
    TermEntity,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (TermEntity, BaseReferences<_$AppDatabase, $TermsTable, TermEntity>),
    TermEntity,
    PrefetchHooks Function()>;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  required String id,
  required String termId,
  required String name,
  required String color,
  required double credits,
  Value<double?> finalGrade,
  Value<bool> useFinalGradeOverride,
  Value<String> weightsJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<String> id,
  Value<String> termId,
  Value<String> name,
  Value<String> color,
  Value<double> credits,
  Value<double?> finalGrade,
  Value<bool> useFinalGradeOverride,
  Value<String> weightsJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => column);

  GeneratedColumn<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride, builder: (column) => column);

  GeneratedColumn<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    SubjectEntity,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (
      SubjectEntity,
      BaseReferences<_$AppDatabase, $SubjectsTable, SubjectEntity>
    ),
    SubjectEntity,
    PrefetchHooks Function()> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> termId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<double> credits = const Value.absent(),
            Value<double?> finalGrade = const Value.absent(),
            Value<bool> useFinalGradeOverride = const Value.absent(),
            Value<String> weightsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            termId: termId,
            name: name,
            color: color,
            credits: credits,
            finalGrade: finalGrade,
            useFinalGradeOverride: useFinalGradeOverride,
            weightsJson: weightsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String termId,
            required String name,
            required String color,
            required double credits,
            Value<double?> finalGrade = const Value.absent(),
            Value<bool> useFinalGradeOverride = const Value.absent(),
            Value<String> weightsJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            termId: termId,
            name: name,
            color: color,
            credits: credits,
            finalGrade: finalGrade,
            useFinalGradeOverride: useFinalGradeOverride,
            weightsJson: weightsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    SubjectEntity,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (
      SubjectEntity,
      BaseReferences<_$AppDatabase, $SubjectsTable, SubjectEntity>
    ),
    SubjectEntity,
    PrefetchHooks Function()>;
typedef $$AssignmentsTableCreateCompanionBuilder = AssignmentsCompanion
    Function({
  required String id,
  required String subjectId,
  required String title,
  Value<String?> description,
  required DateTime dueDate,
  Value<String?> dueTime,
  Value<String?> weightId,
  Value<String> priority,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> isGraded,
  Value<double?> grade,
  Value<String> alertsJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$AssignmentsTableUpdateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> title,
  Value<String?> description,
  Value<DateTime> dueDate,
  Value<String?> dueTime,
  Value<String?> weightId,
  Value<String> priority,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> isGraded,
  Value<double?> grade,
  Value<String> alertsJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightId => $composableBuilder(
      column: $table.weightId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get alertsJson => $composableBuilder(
      column: $table.alertsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dueTime => $composableBuilder(
      column: $table.dueTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightId => $composableBuilder(
      column: $table.weightId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get alertsJson => $composableBuilder(
      column: $table.alertsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get dueTime =>
      $composableBuilder(column: $table.dueTime, builder: (column) => column);

  GeneratedColumn<String> get weightId =>
      $composableBuilder(column: $table.weightId, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get isGraded =>
      $composableBuilder(column: $table.isGraded, builder: (column) => column);

  GeneratedColumn<double> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get alertsJson => $composableBuilder(
      column: $table.alertsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$AssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    AssignmentEntity,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (
      AssignmentEntity,
      BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentEntity>
    ),
    AssignmentEntity,
    PrefetchHooks Function()> {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<String?> dueTime = const Value.absent(),
            Value<String?> weightId = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<double?> grade = const Value.absent(),
            Value<String> alertsJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion(
            id: id,
            subjectId: subjectId,
            title: title,
            description: description,
            dueDate: dueDate,
            dueTime: dueTime,
            weightId: weightId,
            priority: priority,
            isCompleted: isCompleted,
            completedAt: completedAt,
            isGraded: isGraded,
            grade: grade,
            alertsJson: alertsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String title,
            Value<String?> description = const Value.absent(),
            required DateTime dueDate,
            Value<String?> dueTime = const Value.absent(),
            Value<String?> weightId = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<double?> grade = const Value.absent(),
            Value<String> alertsJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion.insert(
            id: id,
            subjectId: subjectId,
            title: title,
            description: description,
            dueDate: dueDate,
            dueTime: dueTime,
            weightId: weightId,
            priority: priority,
            isCompleted: isCompleted,
            completedAt: completedAt,
            isGraded: isGraded,
            grade: grade,
            alertsJson: alertsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    AssignmentEntity,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (
      AssignmentEntity,
      BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentEntity>
    ),
    AssignmentEntity,
    PrefetchHooks Function()>;
typedef $$ClassTemplatesTableCreateCompanionBuilder = ClassTemplatesCompanion
    Function({
  required String id,
  required String subjectId,
  required String name,
  required String icon,
  required DateTime startDate,
  required DateTime endDate,
  required String startTime,
  required String endTime,
  required String recurrenceJson,
  Value<String?> building,
  Value<String?> room,
  Value<String?> teacherId,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ClassTemplatesTableUpdateCompanionBuilder = ClassTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> name,
  Value<String> icon,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> startTime,
  Value<String> endTime,
  Value<String> recurrenceJson,
  Value<String?> building,
  Value<String?> room,
  Value<String?> teacherId,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ClassTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassTemplatesTable> {
  $$ClassTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceJson => $composableBuilder(
      column: $table.recurrenceJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get building => $composableBuilder(
      column: $table.building, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ClassTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassTemplatesTable> {
  $$ClassTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceJson => $composableBuilder(
      column: $table.recurrenceJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get building => $composableBuilder(
      column: $table.building, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ClassTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassTemplatesTable> {
  $$ClassTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get recurrenceJson => $composableBuilder(
      column: $table.recurrenceJson, builder: (column) => column);

  GeneratedColumn<String> get building =>
      $composableBuilder(column: $table.building, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ClassTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassTemplatesTable,
    ClassTemplateEntity,
    $$ClassTemplatesTableFilterComposer,
    $$ClassTemplatesTableOrderingComposer,
    $$ClassTemplatesTableAnnotationComposer,
    $$ClassTemplatesTableCreateCompanionBuilder,
    $$ClassTemplatesTableUpdateCompanionBuilder,
    (
      ClassTemplateEntity,
      BaseReferences<_$AppDatabase, $ClassTemplatesTable, ClassTemplateEntity>
    ),
    ClassTemplateEntity,
    PrefetchHooks Function()> {
  $$ClassTemplatesTableTableManager(
      _$AppDatabase db, $ClassTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> icon = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String> recurrenceJson = const Value.absent(),
            Value<String?> building = const Value.absent(),
            Value<String?> room = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassTemplatesCompanion(
            id: id,
            subjectId: subjectId,
            name: name,
            icon: icon,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            recurrenceJson: recurrenceJson,
            building: building,
            room: room,
            teacherId: teacherId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String name,
            required String icon,
            required DateTime startDate,
            required DateTime endDate,
            required String startTime,
            required String endTime,
            required String recurrenceJson,
            Value<String?> building = const Value.absent(),
            Value<String?> room = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassTemplatesCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name,
            icon: icon,
            startDate: startDate,
            endDate: endDate,
            startTime: startTime,
            endTime: endTime,
            recurrenceJson: recurrenceJson,
            building: building,
            room: room,
            teacherId: teacherId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClassTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassTemplatesTable,
    ClassTemplateEntity,
    $$ClassTemplatesTableFilterComposer,
    $$ClassTemplatesTableOrderingComposer,
    $$ClassTemplatesTableAnnotationComposer,
    $$ClassTemplatesTableCreateCompanionBuilder,
    $$ClassTemplatesTableUpdateCompanionBuilder,
    (
      ClassTemplateEntity,
      BaseReferences<_$AppDatabase, $ClassTemplatesTable, ClassTemplateEntity>
    ),
    ClassTemplateEntity,
    PrefetchHooks Function()>;
typedef $$ClassExceptionsTableCreateCompanionBuilder = ClassExceptionsCompanion
    Function({
  required String id,
  required String classTemplateId,
  required DateTime date,
  Value<bool> isCancelled,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ClassExceptionsTableUpdateCompanionBuilder = ClassExceptionsCompanion
    Function({
  Value<String> id,
  Value<String> classTemplateId,
  Value<DateTime> date,
  Value<bool> isCancelled,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ClassExceptionsTableFilterComposer
    extends Composer<_$AppDatabase, $ClassExceptionsTable> {
  $$ClassExceptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get classTemplateId => $composableBuilder(
      column: $table.classTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ClassExceptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassExceptionsTable> {
  $$ClassExceptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get classTemplateId => $composableBuilder(
      column: $table.classTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ClassExceptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassExceptionsTable> {
  $$ClassExceptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get classTemplateId => $composableBuilder(
      column: $table.classTemplateId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isCancelled => $composableBuilder(
      column: $table.isCancelled, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ClassExceptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassExceptionsTable,
    ClassExceptionEntity,
    $$ClassExceptionsTableFilterComposer,
    $$ClassExceptionsTableOrderingComposer,
    $$ClassExceptionsTableAnnotationComposer,
    $$ClassExceptionsTableCreateCompanionBuilder,
    $$ClassExceptionsTableUpdateCompanionBuilder,
    (
      ClassExceptionEntity,
      BaseReferences<_$AppDatabase, $ClassExceptionsTable, ClassExceptionEntity>
    ),
    ClassExceptionEntity,
    PrefetchHooks Function()> {
  $$ClassExceptionsTableTableManager(
      _$AppDatabase db, $ClassExceptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassExceptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassExceptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassExceptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> classTemplateId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> isCancelled = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassExceptionsCompanion(
            id: id,
            classTemplateId: classTemplateId,
            date: date,
            isCancelled: isCancelled,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String classTemplateId,
            required DateTime date,
            Value<bool> isCancelled = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassExceptionsCompanion.insert(
            id: id,
            classTemplateId: classTemplateId,
            date: date,
            isCancelled: isCancelled,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClassExceptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassExceptionsTable,
    ClassExceptionEntity,
    $$ClassExceptionsTableFilterComposer,
    $$ClassExceptionsTableOrderingComposer,
    $$ClassExceptionsTableAnnotationComposer,
    $$ClassExceptionsTableCreateCompanionBuilder,
    $$ClassExceptionsTableUpdateCompanionBuilder,
    (
      ClassExceptionEntity,
      BaseReferences<_$AppDatabase, $ClassExceptionsTable, ClassExceptionEntity>
    ),
    ClassExceptionEntity,
    PrefetchHooks Function()>;
typedef $$ExamsTableCreateCompanionBuilder = ExamsCompanion Function({
  required String id,
  required String subjectId,
  required String name,
  required DateTime date,
  required String startTime,
  required String endTime,
  Value<String?> weightId,
  Value<String?> building,
  Value<String?> room,
  Value<String?> teacherId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> isGraded,
  Value<double?> grade,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ExamsTableUpdateCompanionBuilder = ExamsCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> name,
  Value<DateTime> date,
  Value<String> startTime,
  Value<String> endTime,
  Value<String?> weightId,
  Value<String?> building,
  Value<String?> room,
  Value<String?> teacherId,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<bool> isGraded,
  Value<double?> grade,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$ExamsTableFilterComposer extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightId => $composableBuilder(
      column: $table.weightId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get building => $composableBuilder(
      column: $table.building, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$ExamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightId => $composableBuilder(
      column: $table.weightId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get building => $composableBuilder(
      column: $table.building, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get room => $composableBuilder(
      column: $table.room, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get weightId =>
      $composableBuilder(column: $table.weightId, builder: (column) => column);

  GeneratedColumn<String> get building =>
      $composableBuilder(column: $table.building, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get isGraded =>
      $composableBuilder(column: $table.isGraded, builder: (column) => column);

  GeneratedColumn<double> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$ExamsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExamsTable,
    ExamEntity,
    $$ExamsTableFilterComposer,
    $$ExamsTableOrderingComposer,
    $$ExamsTableAnnotationComposer,
    $$ExamsTableCreateCompanionBuilder,
    $$ExamsTableUpdateCompanionBuilder,
    (ExamEntity, BaseReferences<_$AppDatabase, $ExamsTable, ExamEntity>),
    ExamEntity,
    PrefetchHooks Function()> {
  $$ExamsTableTableManager(_$AppDatabase db, $ExamsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String?> weightId = const Value.absent(),
            Value<String?> building = const Value.absent(),
            Value<String?> room = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<double?> grade = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamsCompanion(
            id: id,
            subjectId: subjectId,
            name: name,
            date: date,
            startTime: startTime,
            endTime: endTime,
            weightId: weightId,
            building: building,
            room: room,
            teacherId: teacherId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            isGraded: isGraded,
            grade: grade,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String name,
            required DateTime date,
            required String startTime,
            required String endTime,
            Value<String?> weightId = const Value.absent(),
            Value<String?> building = const Value.absent(),
            Value<String?> room = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<double?> grade = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamsCompanion.insert(
            id: id,
            subjectId: subjectId,
            name: name,
            date: date,
            startTime: startTime,
            endTime: endTime,
            weightId: weightId,
            building: building,
            room: room,
            teacherId: teacherId,
            isCompleted: isCompleted,
            completedAt: completedAt,
            isGraded: isGraded,
            grade: grade,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExamsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExamsTable,
    ExamEntity,
    $$ExamsTableFilterComposer,
    $$ExamsTableOrderingComposer,
    $$ExamsTableAnnotationComposer,
    $$ExamsTableCreateCompanionBuilder,
    $$ExamsTableUpdateCompanionBuilder,
    (ExamEntity, BaseReferences<_$AppDatabase, $ExamsTable, ExamEntity>),
    ExamEntity,
    PrefetchHooks Function()>;
typedef $$TeachersTableCreateCompanionBuilder = TeachersCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<String?> position,
  Value<String?> department,
  Value<String?> affiliation,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> webPage,
  Value<String> officeHoursJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$TeachersTableUpdateCompanionBuilder = TeachersCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String?> position,
  Value<String?> department,
  Value<String?> affiliation,
  Value<String?> email,
  Value<String?> phone,
  Value<String?> webPage,
  Value<String> officeHoursJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$TeachersTableFilterComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get webPage => $composableBuilder(
      column: $table.webPage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get officeHoursJson => $composableBuilder(
      column: $table.officeHoursJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$TeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get webPage => $composableBuilder(
      column: $table.webPage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get officeHoursJson => $composableBuilder(
      column: $table.officeHoursJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$TeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<String> get affiliation => $composableBuilder(
      column: $table.affiliation, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get webPage =>
      $composableBuilder(column: $table.webPage, builder: (column) => column);

  GeneratedColumn<String> get officeHoursJson => $composableBuilder(
      column: $table.officeHoursJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$TeachersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TeachersTable,
    TeacherEntity,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (
      TeacherEntity,
      BaseReferences<_$AppDatabase, $TeachersTable, TeacherEntity>
    ),
    TeacherEntity,
    PrefetchHooks Function()> {
  $$TeachersTableTableManager(_$AppDatabase db, $TeachersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeachersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> position = const Value.absent(),
            Value<String?> department = const Value.absent(),
            Value<String?> affiliation = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> webPage = const Value.absent(),
            Value<String> officeHoursJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeachersCompanion(
            id: id,
            userId: userId,
            name: name,
            position: position,
            department: department,
            affiliation: affiliation,
            email: email,
            phone: phone,
            webPage: webPage,
            officeHoursJson: officeHoursJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<String?> position = const Value.absent(),
            Value<String?> department = const Value.absent(),
            Value<String?> affiliation = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> webPage = const Value.absent(),
            Value<String> officeHoursJson = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TeachersCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            position: position,
            department: department,
            affiliation: affiliation,
            email: email,
            phone: phone,
            webPage: webPage,
            officeHoursJson: officeHoursJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TeachersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TeachersTable,
    TeacherEntity,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (
      TeacherEntity,
      BaseReferences<_$AppDatabase, $TeachersTable, TeacherEntity>
    ),
    TeacherEntity,
    PrefetchHooks Function()>;
typedef $$HolidaysTableCreateCompanionBuilder = HolidaysCompanion Function({
  required String id,
  required String userId,
  required String name,
  required DateTime startDate,
  required DateTime endDate,
  required String source,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$HolidaysTableUpdateCompanionBuilder = HolidaysCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$HolidaysTableFilterComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$HolidaysTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$HolidaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidaysTable> {
  $$HolidaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$HolidaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HolidaysTable,
    HolidayEntity,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (
      HolidayEntity,
      BaseReferences<_$AppDatabase, $HolidaysTable, HolidayEntity>
    ),
    HolidayEntity,
    PrefetchHooks Function()> {
  $$HolidaysTableTableManager(_$AppDatabase db, $HolidaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HolidaysCompanion(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required DateTime startDate,
            required DateTime endDate,
            required String source,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HolidaysCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HolidaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HolidaysTable,
    HolidayEntity,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (
      HolidayEntity,
      BaseReferences<_$AppDatabase, $HolidaysTable, HolidayEntity>
    ),
    HolidayEntity,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String userId,
  Value<int> defaultClassDuration,
  Value<String> weekdaysJson,
  required String gradingScaleJson,
  Value<String> holidayCountry,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> userId,
  Value<int> defaultClassDuration,
  Value<String> weekdaysJson,
  Value<String> gradingScaleJson,
  Value<String> holidayCountry,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultClassDuration => $composableBuilder(
      column: $table.defaultClassDuration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gradingScaleJson => $composableBuilder(
      column: $table.gradingScaleJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get holidayCountry => $composableBuilder(
      column: $table.holidayCountry,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultClassDuration => $composableBuilder(
      column: $table.defaultClassDuration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gradingScaleJson => $composableBuilder(
      column: $table.gradingScaleJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get holidayCountry => $composableBuilder(
      column: $table.holidayCountry,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get defaultClassDuration => $composableBuilder(
      column: $table.defaultClassDuration, builder: (column) => column);

  GeneratedColumn<String> get weekdaysJson => $composableBuilder(
      column: $table.weekdaysJson, builder: (column) => column);

  GeneratedColumn<String> get gradingScaleJson => $composableBuilder(
      column: $table.gradingScaleJson, builder: (column) => column);

  GeneratedColumn<String> get holidayCountry => $composableBuilder(
      column: $table.holidayCountry, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingsEntity,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (
      SettingsEntity,
      BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntity>
    ),
    SettingsEntity,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int> defaultClassDuration = const Value.absent(),
            Value<String> weekdaysJson = const Value.absent(),
            Value<String> gradingScaleJson = const Value.absent(),
            Value<String> holidayCountry = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            userId: userId,
            defaultClassDuration: defaultClassDuration,
            weekdaysJson: weekdaysJson,
            gradingScaleJson: gradingScaleJson,
            holidayCountry: holidayCountry,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<int> defaultClassDuration = const Value.absent(),
            Value<String> weekdaysJson = const Value.absent(),
            required String gradingScaleJson,
            Value<String> holidayCountry = const Value.absent(),
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            userId: userId,
            defaultClassDuration: defaultClassDuration,
            weekdaysJson: weekdaysJson,
            gradingScaleJson: gradingScaleJson,
            holidayCountry: holidayCountry,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingsEntity,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (
      SettingsEntity,
      BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntity>
    ),
    SettingsEntity,
    PrefetchHooks Function()>;
typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String color,
  required String ownerId,
  Value<String> membersJson,
  required String inviteCode,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> color,
  Value<String> ownerId,
  Value<String> membersJson,
  Value<String> inviteCode,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get membersJson => $composableBuilder(
      column: $table.membersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get membersJson => $composableBuilder(
      column: $table.membersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get membersJson => $composableBuilder(
      column: $table.membersJson, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    GroupEntity,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (GroupEntity, BaseReferences<_$AppDatabase, $GroupsTable, GroupEntity>),
    GroupEntity,
    PrefetchHooks Function()> {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> membersJson = const Value.absent(),
            Value<String> inviteCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            description: description,
            color: color,
            ownerId: ownerId,
            membersJson: membersJson,
            inviteCode: inviteCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String color,
            required String ownerId,
            Value<String> membersJson = const Value.absent(),
            required String inviteCode,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            description: description,
            color: color,
            ownerId: ownerId,
            membersJson: membersJson,
            inviteCode: inviteCode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    GroupEntity,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (GroupEntity, BaseReferences<_$AppDatabase, $GroupsTable, GroupEntity>),
    GroupEntity,
    PrefetchHooks Function()>;
typedef $$WeeklyAvailabilitiesTableCreateCompanionBuilder
    = WeeklyAvailabilitiesCompanion Function({
  required String id,
  required String groupId,
  required String weekIdentifier,
  required DateTime weekStartDate,
  required DateTime weekEndDate,
  required String dailySlotsJson,
  required DateTime calculatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$WeeklyAvailabilitiesTableUpdateCompanionBuilder
    = WeeklyAvailabilitiesCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> weekIdentifier,
  Value<DateTime> weekStartDate,
  Value<DateTime> weekEndDate,
  Value<String> dailySlotsJson,
  Value<DateTime> calculatedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

class $$WeeklyAvailabilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyAvailabilitiesTable> {
  $$WeeklyAvailabilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekIdentifier => $composableBuilder(
      column: $table.weekIdentifier,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get weekStartDate => $composableBuilder(
      column: $table.weekStartDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get weekEndDate => $composableBuilder(
      column: $table.weekEndDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dailySlotsJson => $composableBuilder(
      column: $table.dailySlotsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$WeeklyAvailabilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyAvailabilitiesTable> {
  $$WeeklyAvailabilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekIdentifier => $composableBuilder(
      column: $table.weekIdentifier,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get weekStartDate => $composableBuilder(
      column: $table.weekStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get weekEndDate => $composableBuilder(
      column: $table.weekEndDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dailySlotsJson => $composableBuilder(
      column: $table.dailySlotsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$WeeklyAvailabilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyAvailabilitiesTable> {
  $$WeeklyAvailabilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get weekIdentifier => $composableBuilder(
      column: $table.weekIdentifier, builder: (column) => column);

  GeneratedColumn<DateTime> get weekStartDate => $composableBuilder(
      column: $table.weekStartDate, builder: (column) => column);

  GeneratedColumn<DateTime> get weekEndDate => $composableBuilder(
      column: $table.weekEndDate, builder: (column) => column);

  GeneratedColumn<String> get dailySlotsJson => $composableBuilder(
      column: $table.dailySlotsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);
}

class $$WeeklyAvailabilitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeeklyAvailabilitiesTable,
    WeeklyAvailabilityEntity,
    $$WeeklyAvailabilitiesTableFilterComposer,
    $$WeeklyAvailabilitiesTableOrderingComposer,
    $$WeeklyAvailabilitiesTableAnnotationComposer,
    $$WeeklyAvailabilitiesTableCreateCompanionBuilder,
    $$WeeklyAvailabilitiesTableUpdateCompanionBuilder,
    (
      WeeklyAvailabilityEntity,
      BaseReferences<_$AppDatabase, $WeeklyAvailabilitiesTable,
          WeeklyAvailabilityEntity>
    ),
    WeeklyAvailabilityEntity,
    PrefetchHooks Function()> {
  $$WeeklyAvailabilitiesTableTableManager(
      _$AppDatabase db, $WeeklyAvailabilitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyAvailabilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyAvailabilitiesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyAvailabilitiesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> weekIdentifier = const Value.absent(),
            Value<DateTime> weekStartDate = const Value.absent(),
            Value<DateTime> weekEndDate = const Value.absent(),
            Value<String> dailySlotsJson = const Value.absent(),
            Value<DateTime> calculatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeeklyAvailabilitiesCompanion(
            id: id,
            groupId: groupId,
            weekIdentifier: weekIdentifier,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            dailySlotsJson: dailySlotsJson,
            calculatedAt: calculatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String weekIdentifier,
            required DateTime weekStartDate,
            required DateTime weekEndDate,
            required String dailySlotsJson,
            required DateTime calculatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeeklyAvailabilitiesCompanion.insert(
            id: id,
            groupId: groupId,
            weekIdentifier: weekIdentifier,
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            dailySlotsJson: dailySlotsJson,
            calculatedAt: calculatedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeeklyAvailabilitiesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $WeeklyAvailabilitiesTable,
        WeeklyAvailabilityEntity,
        $$WeeklyAvailabilitiesTableFilterComposer,
        $$WeeklyAvailabilitiesTableOrderingComposer,
        $$WeeklyAvailabilitiesTableAnnotationComposer,
        $$WeeklyAvailabilitiesTableCreateCompanionBuilder,
        $$WeeklyAvailabilitiesTableUpdateCompanionBuilder,
        (
          WeeklyAvailabilityEntity,
          BaseReferences<_$AppDatabase, $WeeklyAvailabilitiesTable,
              WeeklyAvailabilityEntity>
        ),
        WeeklyAvailabilityEntity,
        PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String operation,
  required String dataJson,
  required String documentPath,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> errorMessage,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> dataJson,
  Value<String> documentPath,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> errorMessage,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentPath => $composableBuilder(
      column: $table.documentPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<String> get documentPath => $composableBuilder(
      column: $table.documentPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntity,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntity,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntity>
    ),
    SyncQueueEntity,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> dataJson = const Value.absent(),
            Value<String> documentPath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            dataJson: dataJson,
            documentPath: documentPath,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMessage: errorMessage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String operation,
            required String dataJson,
            required String documentPath,
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            dataJson: dataJson,
            documentPath: documentPath,
            createdAt: createdAt,
            retryCount: retryCount,
            errorMessage: errorMessage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueEntity,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueEntity,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueEntity>
    ),
    SyncQueueEntity,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$TermsTableTableManager get terms =>
      $$TermsTableTableManager(_db, _db.terms);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$ClassTemplatesTableTableManager get classTemplates =>
      $$ClassTemplatesTableTableManager(_db, _db.classTemplates);
  $$ClassExceptionsTableTableManager get classExceptions =>
      $$ClassExceptionsTableTableManager(_db, _db.classExceptions);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$TeachersTableTableManager get teachers =>
      $$TeachersTableTableManager(_db, _db.teachers);
  $$HolidaysTableTableManager get holidays =>
      $$HolidaysTableTableManager(_db, _db.holidays);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$WeeklyAvailabilitiesTableTableManager get weeklyAvailabilities =>
      $$WeeklyAvailabilitiesTableTableManager(_db, _db.weeklyAvailabilities);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
