// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
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
  static const VerificationMeta _memberUidsMeta =
      const VerificationMeta('memberUids');
  @override
  late final GeneratedColumn<String> memberUids = GeneratedColumn<String>(
      'member_uids', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
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
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, memberUids, imageUrl, createdBy, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<Group> instance,
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
    if (data.containsKey('member_uids')) {
      context.handle(
          _memberUidsMeta,
          memberUids.isAcceptableOrUnknown(
              data['member_uids']!, _memberUidsMeta));
    } else if (isInserting) {
      context.missing(_memberUidsMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      memberUids: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}member_uids'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String id;
  final String name;
  final String memberUids;
  final String? imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Group(
      {required this.id,
      required this.name,
      required this.memberUids,
      this.imageUrl,
      required this.createdBy,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['member_uids'] = Variable<String>(memberUids);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      memberUids: Value(memberUids),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      memberUids: serializer.fromJson<String>(json['memberUids']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'memberUids': serializer.toJson<String>(memberUids),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Group copyWith(
          {String? id,
          String? name,
          String? memberUids,
          Value<String?> imageUrl = const Value.absent(),
          String? createdBy,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        memberUids: memberUids ?? this.memberUids,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      memberUids:
          data.memberUids.present ? data.memberUids.value : this.memberUids,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('memberUids: $memberUids, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, memberUids, imageUrl, createdBy, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.memberUids == this.memberUids &&
          other.imageUrl == this.imageUrl &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> memberUids;
  final Value<String?> imageUrl;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.memberUids = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    required String name,
    required String memberUids,
    this.imageUrl = const Value.absent(),
    required String createdBy,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        memberUids = Value(memberUids),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? memberUids,
    Expression<String>? imageUrl,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (memberUids != null) 'member_uids': memberUids,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? memberUids,
      Value<String?>? imageUrl,
      Value<String>? createdBy,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      memberUids: memberUids ?? this.memberUids,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (memberUids.present) {
      map['member_uids'] = Variable<String>(memberUids.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('memberUids: $memberUids, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupMembersTable extends GroupMembers
    with TableInfo<$GroupMembersTable, GroupMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupMembersTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userNickMeta =
      const VerificationMeta('userNick');
  @override
  late final GeneratedColumn<String> userNick = GeneratedColumn<String>(
      'user_nick', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userEmailMeta =
      const VerificationMeta('userEmail');
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
      'user_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, groupId, userId, userNick, userEmail, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'group_members';
  @override
  VerificationContext validateIntegrity(Insertable<GroupMember> instance,
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
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_nick')) {
      context.handle(_userNickMeta,
          userNick.isAcceptableOrUnknown(data['user_nick']!, _userNickMeta));
    } else if (isInserting) {
      context.missing(_userNickMeta);
    }
    if (data.containsKey('user_email')) {
      context.handle(_userEmailMeta,
          userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta));
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {groupId, userId},
      ];
  @override
  GroupMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      userNick: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_nick'])!,
      userEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_email'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
    );
  }

  @override
  $GroupMembersTable createAlias(String alias) {
    return $GroupMembersTable(attachedDatabase, alias);
  }
}

class GroupMember extends DataClass implements Insertable<GroupMember> {
  final String id;
  final String groupId;
  final String userId;
  final String userNick;
  final String userEmail;
  final DateTime joinedAt;
  const GroupMember(
      {required this.id,
      required this.groupId,
      required this.userId,
      required this.userNick,
      required this.userEmail,
      required this.joinedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['user_id'] = Variable<String>(userId);
    map['user_nick'] = Variable<String>(userNick);
    map['user_email'] = Variable<String>(userEmail);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  GroupMembersCompanion toCompanion(bool nullToAbsent) {
    return GroupMembersCompanion(
      id: Value(id),
      groupId: Value(groupId),
      userId: Value(userId),
      userNick: Value(userNick),
      userEmail: Value(userEmail),
      joinedAt: Value(joinedAt),
    );
  }

  factory GroupMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupMember(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      userId: serializer.fromJson<String>(json['userId']),
      userNick: serializer.fromJson<String>(json['userNick']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'userId': serializer.toJson<String>(userId),
      'userNick': serializer.toJson<String>(userNick),
      'userEmail': serializer.toJson<String>(userEmail),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  GroupMember copyWith(
          {String? id,
          String? groupId,
          String? userId,
          String? userNick,
          String? userEmail,
          DateTime? joinedAt}) =>
      GroupMember(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        userId: userId ?? this.userId,
        userNick: userNick ?? this.userNick,
        userEmail: userEmail ?? this.userEmail,
        joinedAt: joinedAt ?? this.joinedAt,
      );
  GroupMember copyWithCompanion(GroupMembersCompanion data) {
    return GroupMember(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      userId: data.userId.present ? data.userId.value : this.userId,
      userNick: data.userNick.present ? data.userNick.value : this.userNick,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupMember(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('userNick: $userNick, ')
          ..write('userEmail: $userEmail, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, groupId, userId, userNick, userEmail, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMember &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.userId == this.userId &&
          other.userNick == this.userNick &&
          other.userEmail == this.userEmail &&
          other.joinedAt == this.joinedAt);
}

class GroupMembersCompanion extends UpdateCompanion<GroupMember> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> userId;
  final Value<String> userNick;
  final Value<String> userEmail;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const GroupMembersCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.userId = const Value.absent(),
    this.userNick = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupMembersCompanion.insert({
    required String id,
    required String groupId,
    required String userId,
    required String userNick,
    required String userEmail,
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        userId = Value(userId),
        userNick = Value(userNick),
        userEmail = Value(userEmail),
        joinedAt = Value(joinedAt);
  static Insertable<GroupMember> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? userId,
    Expression<String>? userNick,
    Expression<String>? userEmail,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (userId != null) 'user_id': userId,
      if (userNick != null) 'user_nick': userNick,
      if (userEmail != null) 'user_email': userEmail,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? userId,
      Value<String>? userNick,
      Value<String>? userEmail,
      Value<DateTime>? joinedAt,
      Value<int>? rowid}) {
    return GroupMembersCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userNick: userNick ?? this.userNick,
      userEmail: userEmail ?? this.userEmail,
      joinedAt: joinedAt ?? this.joinedAt,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (userNick.present) {
      map['user_nick'] = Variable<String>(userNick.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupMembersCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('userId: $userId, ')
          ..write('userNick: $userNick, ')
          ..write('userEmail: $userEmail, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalendarEventsTable extends CalendarEvents
    with TableInfo<$CalendarEventsTable, CalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalendarEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerNameMeta =
      const VerificationMeta('ownerName');
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
      'owner_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        startTime,
        endTime,
        eventType,
        ownerId,
        ownerName,
        colorValue,
        groupId,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calendar_events';
  @override
  VerificationContext validateIntegrity(Insertable<CalendarEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(_ownerNameMeta,
          ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta));
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalendarEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      ownerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CalendarEventsTable createAlias(String alias) {
    return $CalendarEventsTable(attachedDatabase, alias);
  }
}

class CalendarEvent extends DataClass implements Insertable<CalendarEvent> {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String eventType;
  final String ownerId;
  final String ownerName;
  final int colorValue;
  final String? groupId;
  final DateTime cachedAt;
  const CalendarEvent(
      {required this.id,
      required this.title,
      required this.startTime,
      required this.endTime,
      required this.eventType,
      required this.ownerId,
      required this.ownerName,
      required this.colorValue,
      this.groupId,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    map['event_type'] = Variable<String>(eventType);
    map['owner_id'] = Variable<String>(ownerId);
    map['owner_name'] = Variable<String>(ownerName);
    map['color_value'] = Variable<int>(colorValue);
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CalendarEventsCompanion(
      id: Value(id),
      title: Value(title),
      startTime: Value(startTime),
      endTime: Value(endTime),
      eventType: Value(eventType),
      ownerId: Value(ownerId),
      ownerName: Value(ownerName),
      colorValue: Value(colorValue),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      cachedAt: Value(cachedAt),
    );
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalendarEvent(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
      eventType: serializer.fromJson<String>(json['eventType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
      'eventType': serializer.toJson<String>(eventType),
      'ownerId': serializer.toJson<String>(ownerId),
      'ownerName': serializer.toJson<String>(ownerName),
      'colorValue': serializer.toJson<int>(colorValue),
      'groupId': serializer.toJson<String?>(groupId),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CalendarEvent copyWith(
          {String? id,
          String? title,
          DateTime? startTime,
          DateTime? endTime,
          String? eventType,
          String? ownerId,
          String? ownerName,
          int? colorValue,
          Value<String?> groupId = const Value.absent(),
          DateTime? cachedAt}) =>
      CalendarEvent(
        id: id ?? this.id,
        title: title ?? this.title,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        eventType: eventType ?? this.eventType,
        ownerId: ownerId ?? this.ownerId,
        ownerName: ownerName ?? this.ownerName,
        colorValue: colorValue ?? this.colorValue,
        groupId: groupId.present ? groupId.value : this.groupId,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CalendarEvent copyWithCompanion(CalendarEventsCompanion data) {
    return CalendarEvent(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEvent(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('eventType: $eventType, ')
          ..write('ownerId: $ownerId, ')
          ..write('ownerName: $ownerName, ')
          ..write('colorValue: $colorValue, ')
          ..write('groupId: $groupId, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, startTime, endTime, eventType,
      ownerId, ownerName, colorValue, groupId, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalendarEvent &&
          other.id == this.id &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.eventType == this.eventType &&
          other.ownerId == this.ownerId &&
          other.ownerName == this.ownerName &&
          other.colorValue == this.colorValue &&
          other.groupId == this.groupId &&
          other.cachedAt == this.cachedAt);
}

class CalendarEventsCompanion extends UpdateCompanion<CalendarEvent> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  final Value<String> eventType;
  final Value<String> ownerId;
  final Value<String> ownerName;
  final Value<int> colorValue;
  final Value<String?> groupId;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CalendarEventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.eventType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.groupId = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalendarEventsCompanion.insert({
    required String id,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    required String eventType,
    required String ownerId,
    required String ownerName,
    required int colorValue,
    this.groupId = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        startTime = Value(startTime),
        endTime = Value(endTime),
        eventType = Value(eventType),
        ownerId = Value(ownerId),
        ownerName = Value(ownerName),
        colorValue = Value(colorValue),
        cachedAt = Value(cachedAt);
  static Insertable<CalendarEvent> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? eventType,
    Expression<String>? ownerId,
    Expression<String>? ownerName,
    Expression<int>? colorValue,
    Expression<String>? groupId,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (eventType != null) 'event_type': eventType,
      if (ownerId != null) 'owner_id': ownerId,
      if (ownerName != null) 'owner_name': ownerName,
      if (colorValue != null) 'color_value': colorValue,
      if (groupId != null) 'group_id': groupId,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalendarEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? startTime,
      Value<DateTime>? endTime,
      Value<String>? eventType,
      Value<String>? ownerId,
      Value<String>? ownerName,
      Value<int>? colorValue,
      Value<String?>? groupId,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CalendarEventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      eventType: eventType ?? this.eventType,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      colorValue: colorValue ?? this.colorValue,
      groupId: groupId ?? this.groupId,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalendarEventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('eventType: $eventType, ')
          ..write('ownerId: $ownerId, ')
          ..write('ownerName: $ownerName, ')
          ..write('colorValue: $colorValue, ')
          ..write('groupId: $groupId, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FreeBlocksTable extends FreeBlocks
    with TableInfo<$FreeBlocksTable, FreeBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FreeBlocksTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES "groups" (id) ON DELETE CASCADE'));
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startHourMeta =
      const VerificationMeta('startHour');
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
      'start_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startMinuteMeta =
      const VerificationMeta('startMinute');
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
      'start_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endHourMeta =
      const VerificationMeta('endHour');
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
      'end_hour', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endMinuteMeta =
      const VerificationMeta('endMinute');
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
      'end_minute', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _freeMembersMeta =
      const VerificationMeta('freeMembers');
  @override
  late final GeneratedColumn<String> freeMembers = GeneratedColumn<String>(
      'free_members', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAtMeta =
      const VerificationMeta('calculatedAt');
  @override
  late final GeneratedColumn<DateTime> calculatedAt = GeneratedColumn<DateTime>(
      'calculated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        weekday,
        startHour,
        startMinute,
        endHour,
        endMinute,
        freeMembers,
        calculatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'free_blocks';
  @override
  VerificationContext validateIntegrity(Insertable<FreeBlock> instance,
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
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(_startHourMeta,
          startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta));
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
          _startMinuteMeta,
          startMinute.isAcceptableOrUnknown(
              data['start_minute']!, _startMinuteMeta));
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(_endHourMeta,
          endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta));
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(_endMinuteMeta,
          endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta));
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('free_members')) {
      context.handle(
          _freeMembersMeta,
          freeMembers.isAcceptableOrUnknown(
              data['free_members']!, _freeMembersMeta));
    } else if (isInserting) {
      context.missing(_freeMembersMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
          _calculatedAtMeta,
          calculatedAt.isAcceptableOrUnknown(
              data['calculated_at']!, _calculatedAtMeta));
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FreeBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FreeBlock(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      startHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_hour'])!,
      startMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_minute'])!,
      endHour: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_hour'])!,
      endMinute: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_minute'])!,
      freeMembers: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}free_members'])!,
      calculatedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}calculated_at'])!,
    );
  }

  @override
  $FreeBlocksTable createAlias(String alias) {
    return $FreeBlocksTable(attachedDatabase, alias);
  }
}

class FreeBlock extends DataClass implements Insertable<FreeBlock> {
  final String id;
  final String groupId;
  final int weekday;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String freeMembers;
  final DateTime calculatedAt;
  const FreeBlock(
      {required this.id,
      required this.groupId,
      required this.weekday,
      required this.startHour,
      required this.startMinute,
      required this.endHour,
      required this.endMinute,
      required this.freeMembers,
      required this.calculatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['weekday'] = Variable<int>(weekday);
    map['start_hour'] = Variable<int>(startHour);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_hour'] = Variable<int>(endHour);
    map['end_minute'] = Variable<int>(endMinute);
    map['free_members'] = Variable<String>(freeMembers);
    map['calculated_at'] = Variable<DateTime>(calculatedAt);
    return map;
  }

  FreeBlocksCompanion toCompanion(bool nullToAbsent) {
    return FreeBlocksCompanion(
      id: Value(id),
      groupId: Value(groupId),
      weekday: Value(weekday),
      startHour: Value(startHour),
      startMinute: Value(startMinute),
      endHour: Value(endHour),
      endMinute: Value(endMinute),
      freeMembers: Value(freeMembers),
      calculatedAt: Value(calculatedAt),
    );
  }

  factory FreeBlock.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FreeBlock(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startHour: serializer.fromJson<int>(json['startHour']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endHour: serializer.fromJson<int>(json['endHour']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      freeMembers: serializer.fromJson<String>(json['freeMembers']),
      calculatedAt: serializer.fromJson<DateTime>(json['calculatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'weekday': serializer.toJson<int>(weekday),
      'startHour': serializer.toJson<int>(startHour),
      'startMinute': serializer.toJson<int>(startMinute),
      'endHour': serializer.toJson<int>(endHour),
      'endMinute': serializer.toJson<int>(endMinute),
      'freeMembers': serializer.toJson<String>(freeMembers),
      'calculatedAt': serializer.toJson<DateTime>(calculatedAt),
    };
  }

  FreeBlock copyWith(
          {String? id,
          String? groupId,
          int? weekday,
          int? startHour,
          int? startMinute,
          int? endHour,
          int? endMinute,
          String? freeMembers,
          DateTime? calculatedAt}) =>
      FreeBlock(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        weekday: weekday ?? this.weekday,
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
        freeMembers: freeMembers ?? this.freeMembers,
        calculatedAt: calculatedAt ?? this.calculatedAt,
      );
  FreeBlock copyWithCompanion(FreeBlocksCompanion data) {
    return FreeBlock(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      startMinute:
          data.startMinute.present ? data.startMinute.value : this.startMinute,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      freeMembers:
          data.freeMembers.present ? data.freeMembers.value : this.freeMembers,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FreeBlock(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('weekday: $weekday, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('freeMembers: $freeMembers, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, groupId, weekday, startHour, startMinute,
      endHour, endMinute, freeMembers, calculatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FreeBlock &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.weekday == this.weekday &&
          other.startHour == this.startHour &&
          other.startMinute == this.startMinute &&
          other.endHour == this.endHour &&
          other.endMinute == this.endMinute &&
          other.freeMembers == this.freeMembers &&
          other.calculatedAt == this.calculatedAt);
}

class FreeBlocksCompanion extends UpdateCompanion<FreeBlock> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<int> weekday;
  final Value<int> startHour;
  final Value<int> startMinute;
  final Value<int> endHour;
  final Value<int> endMinute;
  final Value<String> freeMembers;
  final Value<DateTime> calculatedAt;
  final Value<int> rowid;
  const FreeBlocksCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startHour = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endHour = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.freeMembers = const Value.absent(),
    this.calculatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FreeBlocksCompanion.insert({
    required String id,
    required String groupId,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required String freeMembers,
    required DateTime calculatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        weekday = Value(weekday),
        startHour = Value(startHour),
        startMinute = Value(startMinute),
        endHour = Value(endHour),
        endMinute = Value(endMinute),
        freeMembers = Value(freeMembers),
        calculatedAt = Value(calculatedAt);
  static Insertable<FreeBlock> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<int>? weekday,
    Expression<int>? startHour,
    Expression<int>? startMinute,
    Expression<int>? endHour,
    Expression<int>? endMinute,
    Expression<String>? freeMembers,
    Expression<DateTime>? calculatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (weekday != null) 'weekday': weekday,
      if (startHour != null) 'start_hour': startHour,
      if (startMinute != null) 'start_minute': startMinute,
      if (endHour != null) 'end_hour': endHour,
      if (endMinute != null) 'end_minute': endMinute,
      if (freeMembers != null) 'free_members': freeMembers,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FreeBlocksCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<int>? weekday,
      Value<int>? startHour,
      Value<int>? startMinute,
      Value<int>? endHour,
      Value<int>? endMinute,
      Value<String>? freeMembers,
      Value<DateTime>? calculatedAt,
      Value<int>? rowid}) {
    return FreeBlocksCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      weekday: weekday ?? this.weekday,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      freeMembers: freeMembers ?? this.freeMembers,
      calculatedAt: calculatedAt ?? this.calculatedAt,
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
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (freeMembers.present) {
      map['free_members'] = Variable<String>(freeMembers.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<DateTime>(calculatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FreeBlocksCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('weekday: $weekday, ')
          ..write('startHour: $startHour, ')
          ..write('startMinute: $startMinute, ')
          ..write('endHour: $endHour, ')
          ..write('endMinute: $endMinute, ')
          ..write('freeMembers: $freeMembers, ')
          ..write('calculatedAt: $calculatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUsersTable extends CachedUsers
    with TableInfo<$CachedUsersTable, CachedUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
      'uid', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nickMeta = const VerificationMeta('nick');
  @override
  late final GeneratedColumn<String> nick = GeneratedColumn<String>(
      'nick', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarPathMeta =
      const VerificationMeta('avatarPath');
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
      'avatar_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [uid, nick, email, photoUrl, avatarPath, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_users';
  @override
  VerificationContext validateIntegrity(Insertable<CachedUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uid')) {
      context.handle(
          _uidMeta, uid.isAcceptableOrUnknown(data['uid']!, _uidMeta));
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('nick')) {
      context.handle(
          _nickMeta, nick.isAcceptableOrUnknown(data['nick']!, _nickMeta));
    } else if (isInserting) {
      context.missing(_nickMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
          _avatarPathMeta,
          avatarPath.isAcceptableOrUnknown(
              data['avatar_path']!, _avatarPathMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uid};
  @override
  CachedUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUser(
      uid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uid'])!,
      nick: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nick'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      avatarPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_path']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedUsersTable createAlias(String alias) {
    return $CachedUsersTable(attachedDatabase, alias);
  }
}

class CachedUser extends DataClass implements Insertable<CachedUser> {
  final String uid;
  final String nick;
  final String email;
  final String? photoUrl;
  final String? avatarPath;
  final DateTime cachedAt;
  const CachedUser(
      {required this.uid,
      required this.nick,
      required this.email,
      this.photoUrl,
      this.avatarPath,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uid'] = Variable<String>(uid);
    map['nick'] = Variable<String>(nick);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedUsersCompanion toCompanion(bool nullToAbsent) {
    return CachedUsersCompanion(
      uid: Value(uid),
      nick: Value(nick),
      email: Value(email),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUser(
      uid: serializer.fromJson<String>(json['uid']),
      nick: serializer.fromJson<String>(json['nick']),
      email: serializer.fromJson<String>(json['email']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uid': serializer.toJson<String>(uid),
      'nick': serializer.toJson<String>(nick),
      'email': serializer.toJson<String>(email),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedUser copyWith(
          {String? uid,
          String? nick,
          String? email,
          Value<String?> photoUrl = const Value.absent(),
          Value<String?> avatarPath = const Value.absent(),
          DateTime? cachedAt}) =>
      CachedUser(
        uid: uid ?? this.uid,
        nick: nick ?? this.nick,
        email: email ?? this.email,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedUser copyWithCompanion(CachedUsersCompanion data) {
    return CachedUser(
      uid: data.uid.present ? data.uid.value : this.uid,
      nick: data.nick.present ? data.nick.value : this.nick,
      email: data.email.present ? data.email.value : this.email,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      avatarPath:
          data.avatarPath.present ? data.avatarPath.value : this.avatarPath,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUser(')
          ..write('uid: $uid, ')
          ..write('nick: $nick, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uid, nick, email, photoUrl, avatarPath, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUser &&
          other.uid == this.uid &&
          other.nick == this.nick &&
          other.email == this.email &&
          other.photoUrl == this.photoUrl &&
          other.avatarPath == this.avatarPath &&
          other.cachedAt == this.cachedAt);
}

class CachedUsersCompanion extends UpdateCompanion<CachedUser> {
  final Value<String> uid;
  final Value<String> nick;
  final Value<String> email;
  final Value<String?> photoUrl;
  final Value<String?> avatarPath;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedUsersCompanion({
    this.uid = const Value.absent(),
    this.nick = const Value.absent(),
    this.email = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUsersCompanion.insert({
    required String uid,
    required String nick,
    required String email,
    this.photoUrl = const Value.absent(),
    this.avatarPath = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : uid = Value(uid),
        nick = Value(nick),
        email = Value(email),
        cachedAt = Value(cachedAt);
  static Insertable<CachedUser> custom({
    Expression<String>? uid,
    Expression<String>? nick,
    Expression<String>? email,
    Expression<String>? photoUrl,
    Expression<String>? avatarPath,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uid != null) 'uid': uid,
      if (nick != null) 'nick': nick,
      if (email != null) 'email': email,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUsersCompanion copyWith(
      {Value<String>? uid,
      Value<String>? nick,
      Value<String>? email,
      Value<String?>? photoUrl,
      Value<String?>? avatarPath,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedUsersCompanion(
      uid: uid ?? this.uid,
      nick: nick ?? this.nick,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (nick.present) {
      map['nick'] = Variable<String>(nick.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUsersCompanion(')
          ..write('uid: $uid, ')
          ..write('nick: $nick, ')
          ..write('email: $email, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
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
      'data_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        dataJson,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
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
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String operation;
  final String? dataJson;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      this.dataJson,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
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
      'dataJson': serializer.toJson<String?>(dataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? operation,
          Value<String?> dataJson = const Value.absent(),
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        dataJson: dataJson.present ? dataJson.value : this.dataJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('dataJson: $dataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, dataJson,
      createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.dataJson == this.dataJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String?> dataJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    this.dataJson = const Value.absent(),
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? dataJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (dataJson != null) 'data_json': dataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String?>? dataJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      dataJson: dataJson ?? this.dataJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
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
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TermsTable extends Terms with TableInfo<$TermsTable, Term> {
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
      'start_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, startDate, endDate, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terms';
  @override
  VerificationContext validateIntegrity(Insertable<Term> instance,
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
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Term map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Term(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $TermsTable createAlias(String alias) {
    return $TermsTable(attachedDatabase, alias);
  }
}

class Term extends DataClass implements Insertable<Term> {
  final String id;
  final String userId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime cachedAt;
  const Term(
      {required this.id,
      required this.userId,
      required this.name,
      this.startDate,
      this.endDate,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  TermsCompanion toCompanion(bool nullToAbsent) {
    return TermsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      cachedAt: Value(cachedAt),
    );
  }

  factory Term.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Term(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  Term copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<DateTime?> startDate = const Value.absent(),
          Value<DateTime?> endDate = const Value.absent(),
          DateTime? cachedAt}) =>
      Term(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  Term copyWithCompanion(TermsCompanion data) {
    return Term(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Term(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, startDate, endDate, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Term &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.cachedAt == this.cachedAt);
}

class TermsCompanion extends UpdateCompanion<Term> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const TermsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TermsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name);
  static Insertable<Term> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TermsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<DateTime?>? startDate,
      Value<DateTime?>? endDate,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return TermsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
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
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES terms (id) ON DELETE CASCADE'));
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, termId, userId, name, code, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
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
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String termId;
  final String userId;
  final String name;
  final String? code;
  final DateTime cachedAt;
  const Subject(
      {required this.id,
      required this.termId,
      required this.userId,
      required this.name,
      this.code,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['term_id'] = Variable<String>(termId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      termId: Value(termId),
      userId: Value(userId),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      cachedAt: Value(cachedAt),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      termId: serializer.fromJson<String>(json['termId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'termId': serializer.toJson<String>(termId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  Subject copyWith(
          {String? id,
          String? termId,
          String? userId,
          String? name,
          Value<String?> code = const Value.absent(),
          DateTime? cachedAt}) =>
      Subject(
        id: id ?? this.id,
        termId: termId ?? this.termId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        code: code.present ? code.value : this.code,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      termId: data.termId.present ? data.termId.value : this.termId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('termId: $termId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, termId, userId, name, code, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.termId == this.termId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.code == this.code &&
          other.cachedAt == this.cachedAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> termId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> code;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.termId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String termId,
    required String userId,
    required String name,
    this.code = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        termId = Value(termId),
        userId = Value(userId),
        name = Value(name);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? termId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (termId != null) 'term_id': termId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? termId,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? code,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      termId: termId ?? this.termId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      code: code ?? this.code,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
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
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassTemplatesTable extends ClassTemplates
    with TableInfo<$ClassTemplatesTable, ClassTemplate> {
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
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES subjects (id) ON DELETE CASCADE'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        userId,
        dayOfWeek,
        startTime,
        endTime,
        location,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_templates';
  @override
  VerificationContext validateIntegrity(Insertable<ClassTemplate> instance,
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
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
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
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $ClassTemplatesTable createAlias(String alias) {
    return $ClassTemplatesTable(attachedDatabase, alias);
  }
}

class ClassTemplate extends DataClass implements Insertable<ClassTemplate> {
  final String id;
  final String subjectId;
  final String userId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? location;
  final DateTime cachedAt;
  const ClassTemplate(
      {required this.id,
      required this.subjectId,
      required this.userId,
      required this.dayOfWeek,
      required this.startTime,
      required this.endTime,
      this.location,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['user_id'] = Variable<String>(userId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  ClassTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ClassTemplatesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      userId: Value(userId),
      dayOfWeek: Value(dayOfWeek),
      startTime: Value(startTime),
      endTime: Value(endTime),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      cachedAt: Value(cachedAt),
    );
  }

  factory ClassTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassTemplate(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      userId: serializer.fromJson<String>(json['userId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      location: serializer.fromJson<String?>(json['location']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'userId': serializer.toJson<String>(userId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'location': serializer.toJson<String?>(location),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  ClassTemplate copyWith(
          {String? id,
          String? subjectId,
          String? userId,
          int? dayOfWeek,
          String? startTime,
          String? endTime,
          Value<String?> location = const Value.absent(),
          DateTime? cachedAt}) =>
      ClassTemplate(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        userId: userId ?? this.userId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        location: location.present ? location.value : this.location,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  ClassTemplate copyWithCompanion(ClassTemplatesCompanion data) {
    return ClassTemplate(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      userId: data.userId.present ? data.userId.value : this.userId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      location: data.location.present ? data.location.value : this.location,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassTemplate(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, subjectId, userId, dayOfWeek, startTime, endTime, location, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassTemplate &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.userId == this.userId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.location == this.location &&
          other.cachedAt == this.cachedAt);
}

class ClassTemplatesCompanion extends UpdateCompanion<ClassTemplate> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> userId;
  final Value<int> dayOfWeek;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<String?> location;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const ClassTemplatesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.userId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassTemplatesCompanion.insert({
    required String id,
    required String subjectId,
    required String userId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    this.location = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        userId = Value(userId),
        dayOfWeek = Value(dayOfWeek),
        startTime = Value(startTime),
        endTime = Value(endTime);
  static Insertable<ClassTemplate> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? userId,
    Expression<int>? dayOfWeek,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? location,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (userId != null) 'user_id': userId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? userId,
      Value<int>? dayOfWeek,
      Value<String>? startTime,
      Value<String>? endTime,
      Value<String?>? location,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return ClassTemplatesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      cachedAt: cachedAt ?? this.cachedAt,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
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
          ..write('userId: $userId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, Assignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, false,
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
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
      'grade', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pending'));
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
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        termId,
        subjectId,
        title,
        description,
        dueDate,
        priority,
        weight,
        grade,
        status,
        isGraded,
        completedAt,
        createdAt,
        updatedAt,
        cachedAt,
        needsSync,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(Insertable<Assignment> instance,
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
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    } else if (isInserting) {
      context.missing(_termIdMeta);
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
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('is_graded')) {
      context.handle(_isGradedMeta,
          isGraded.isAcceptableOrUnknown(data['is_graded']!, _isGradedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grade'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      isGraded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_graded'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class Assignment extends DataClass implements Insertable<Assignment> {
  final String id;
  final String userId;
  final String termId;
  final String subjectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final int weight;
  final int grade;
  final String status;
  final bool isGraded;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final bool needsSync;
  final bool isDeleted;
  const Assignment(
      {required this.id,
      required this.userId,
      required this.termId,
      required this.subjectId,
      required this.title,
      required this.description,
      required this.dueDate,
      required this.priority,
      required this.weight,
      required this.grade,
      required this.status,
      required this.isGraded,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.cachedAt,
      required this.needsSync,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['term_id'] = Variable<String>(termId);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['priority'] = Variable<String>(priority);
    map['weight'] = Variable<int>(weight);
    map['grade'] = Variable<int>(grade);
    map['status'] = Variable<String>(status);
    map['is_graded'] = Variable<bool>(isGraded);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      termId: Value(termId),
      subjectId: Value(subjectId),
      title: Value(title),
      description: Value(description),
      dueDate: Value(dueDate),
      priority: Value(priority),
      weight: Value(weight),
      grade: Value(grade),
      status: Value(status),
      isGraded: Value(isGraded),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      needsSync: Value(needsSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assignment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      termId: serializer.fromJson<String>(json['termId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      priority: serializer.fromJson<String>(json['priority']),
      weight: serializer.fromJson<int>(json['weight']),
      grade: serializer.fromJson<int>(json['grade']),
      status: serializer.fromJson<String>(json['status']),
      isGraded: serializer.fromJson<bool>(json['isGraded']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'termId': serializer.toJson<String>(termId),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'priority': serializer.toJson<String>(priority),
      'weight': serializer.toJson<int>(weight),
      'grade': serializer.toJson<int>(grade),
      'status': serializer.toJson<String>(status),
      'isGraded': serializer.toJson<bool>(isGraded),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Assignment copyWith(
          {String? id,
          String? userId,
          String? termId,
          String? subjectId,
          String? title,
          String? description,
          DateTime? dueDate,
          String? priority,
          int? weight,
          int? grade,
          String? status,
          bool? isGraded,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? cachedAt,
          bool? needsSync,
          bool? isDeleted}) =>
      Assignment(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        termId: termId ?? this.termId,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        priority: priority ?? this.priority,
        weight: weight ?? this.weight,
        grade: grade ?? this.grade,
        status: status ?? this.status,
        isGraded: isGraded ?? this.isGraded,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
        needsSync: needsSync ?? this.needsSync,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Assignment copyWithCompanion(AssignmentsCompanion data) {
    return Assignment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      termId: data.termId.present ? data.termId.value : this.termId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priority: data.priority.present ? data.priority.value : this.priority,
      weight: data.weight.present ? data.weight.value : this.weight,
      grade: data.grade.present ? data.grade.value : this.grade,
      status: data.status.present ? data.status.value : this.status,
      isGraded: data.isGraded.present ? data.isGraded.value : this.isGraded,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assignment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('weight: $weight, ')
          ..write('grade: $grade, ')
          ..write('status: $status, ')
          ..write('isGraded: $isGraded, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      termId,
      subjectId,
      title,
      description,
      dueDate,
      priority,
      weight,
      grade,
      status,
      isGraded,
      completedAt,
      createdAt,
      updatedAt,
      cachedAt,
      needsSync,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assignment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.termId == this.termId &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.priority == this.priority &&
          other.weight == this.weight &&
          other.grade == this.grade &&
          other.status == this.status &&
          other.isGraded == this.isGraded &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.needsSync == this.needsSync &&
          other.isDeleted == this.isDeleted);
}

class AssignmentsCompanion extends UpdateCompanion<Assignment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> termId;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> dueDate;
  final Value<String> priority;
  final Value<int> weight;
  final Value<int> grade;
  final Value<String> status;
  final Value<bool> isGraded;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> needsSync;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.termId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priority = const Value.absent(),
    this.weight = const Value.absent(),
    this.grade = const Value.absent(),
    this.status = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    required String id,
    required String userId,
    required String termId,
    required String subjectId,
    required String title,
    this.description = const Value.absent(),
    required DateTime dueDate,
    this.priority = const Value.absent(),
    this.weight = const Value.absent(),
    this.grade = const Value.absent(),
    this.status = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        termId = Value(termId),
        subjectId = Value(subjectId),
        title = Value(title),
        dueDate = Value(dueDate);
  static Insertable<Assignment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? termId,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<String>? priority,
    Expression<int>? weight,
    Expression<int>? grade,
    Expression<String>? status,
    Expression<bool>? isGraded,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? needsSync,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (termId != null) 'term_id': termId,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (priority != null) 'priority': priority,
      if (weight != null) 'weight': weight,
      if (grade != null) 'grade': grade,
      if (status != null) 'status': status,
      if (isGraded != null) 'is_graded': isGraded,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssignmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? termId,
      Value<String>? subjectId,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? dueDate,
      Value<String>? priority,
      Value<int>? weight,
      Value<int>? grade,
      Value<String>? status,
      Value<bool>? isGraded,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? cachedAt,
      Value<bool>? needsSync,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      weight: weight ?? this.weight,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      isGraded: isGraded ?? this.isGraded,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
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
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isGraded.present) {
      map['is_graded'] = Variable<bool>(isGraded.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priority: $priority, ')
          ..write('weight: $weight, ')
          ..write('grade: $grade, ')
          ..write('status: $status, ')
          ..write('isGraded: $isGraded, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, Exam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<String> termId = GeneratedColumn<String>(
      'term_id', aliasedName, false,
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
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
      'start_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
      'end_time', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
      'teacher_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
      'weight', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<int> grade = GeneratedColumn<int>(
      'grade', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        termId,
        subjectId,
        title,
        description,
        date,
        startTime,
        endTime,
        location,
        teacherId,
        weight,
        grade,
        isCompleted,
        isGraded,
        completedAt,
        createdAt,
        updatedAt,
        cachedAt,
        needsSync,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(Insertable<Exam> instance,
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
    if (data.containsKey('term_id')) {
      context.handle(_termIdMeta,
          termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta));
    } else if (isInserting) {
      context.missing(_termIdMeta);
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
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_graded')) {
      context.handle(_isGradedMeta,
          isGraded.isAcceptableOrUnknown(data['is_graded']!, _isGradedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exam(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_time']),
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_time']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_id']),
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weight'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}grade'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isGraded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_graded'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class Exam extends DataClass implements Insertable<Exam> {
  final String id;
  final String userId;
  final String termId;
  final String subjectId;
  final String title;
  final String description;
  final DateTime date;
  final String? startTime;
  final String? endTime;
  final String? location;
  final String? teacherId;
  final int weight;
  final int grade;
  final bool isCompleted;
  final bool isGraded;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final bool needsSync;
  final bool isDeleted;
  const Exam(
      {required this.id,
      required this.userId,
      required this.termId,
      required this.subjectId,
      required this.title,
      required this.description,
      required this.date,
      this.startTime,
      this.endTime,
      this.location,
      this.teacherId,
      required this.weight,
      required this.grade,
      required this.isCompleted,
      required this.isGraded,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.cachedAt,
      required this.needsSync,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['term_id'] = Variable<String>(termId);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<String>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<String>(endTime);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    map['weight'] = Variable<int>(weight);
    map['grade'] = Variable<int>(grade);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_graded'] = Variable<bool>(isGraded);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      userId: Value(userId),
      termId: Value(termId),
      subjectId: Value(subjectId),
      title: Value(title),
      description: Value(description),
      date: Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      weight: Value(weight),
      grade: Value(grade),
      isCompleted: Value(isCompleted),
      isGraded: Value(isGraded),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      needsSync: Value(needsSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory Exam.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exam(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      termId: serializer.fromJson<String>(json['termId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      date: serializer.fromJson<DateTime>(json['date']),
      startTime: serializer.fromJson<String?>(json['startTime']),
      endTime: serializer.fromJson<String?>(json['endTime']),
      location: serializer.fromJson<String?>(json['location']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      weight: serializer.fromJson<int>(json['weight']),
      grade: serializer.fromJson<int>(json['grade']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isGraded: serializer.fromJson<bool>(json['isGraded']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'termId': serializer.toJson<String>(termId),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'date': serializer.toJson<DateTime>(date),
      'startTime': serializer.toJson<String?>(startTime),
      'endTime': serializer.toJson<String?>(endTime),
      'location': serializer.toJson<String?>(location),
      'teacherId': serializer.toJson<String?>(teacherId),
      'weight': serializer.toJson<int>(weight),
      'grade': serializer.toJson<int>(grade),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isGraded': serializer.toJson<bool>(isGraded),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Exam copyWith(
          {String? id,
          String? userId,
          String? termId,
          String? subjectId,
          String? title,
          String? description,
          DateTime? date,
          Value<String?> startTime = const Value.absent(),
          Value<String?> endTime = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> teacherId = const Value.absent(),
          int? weight,
          int? grade,
          bool? isCompleted,
          bool? isGraded,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? cachedAt,
          bool? needsSync,
          bool? isDeleted}) =>
      Exam(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        termId: termId ?? this.termId,
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        startTime: startTime.present ? startTime.value : this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        location: location.present ? location.value : this.location,
        teacherId: teacherId.present ? teacherId.value : this.teacherId,
        weight: weight ?? this.weight,
        grade: grade ?? this.grade,
        isCompleted: isCompleted ?? this.isCompleted,
        isGraded: isGraded ?? this.isGraded,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
        needsSync: needsSync ?? this.needsSync,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Exam copyWithCompanion(ExamsCompanion data) {
    return Exam(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      termId: data.termId.present ? data.termId.value : this.termId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      location: data.location.present ? data.location.value : this.location,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      weight: data.weight.present ? data.weight.value : this.weight,
      grade: data.grade.present ? data.grade.value : this.grade,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isGraded: data.isGraded.present ? data.isGraded.value : this.isGraded,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exam(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('teacherId: $teacherId, ')
          ..write('weight: $weight, ')
          ..write('grade: $grade, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isGraded: $isGraded, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        userId,
        termId,
        subjectId,
        title,
        description,
        date,
        startTime,
        endTime,
        location,
        teacherId,
        weight,
        grade,
        isCompleted,
        isGraded,
        completedAt,
        createdAt,
        updatedAt,
        cachedAt,
        needsSync,
        isDeleted
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exam &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.termId == this.termId &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.location == this.location &&
          other.teacherId == this.teacherId &&
          other.weight == this.weight &&
          other.grade == this.grade &&
          other.isCompleted == this.isCompleted &&
          other.isGraded == this.isGraded &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.needsSync == this.needsSync &&
          other.isDeleted == this.isDeleted);
}

class ExamsCompanion extends UpdateCompanion<Exam> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> termId;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> date;
  final Value<String?> startTime;
  final Value<String?> endTime;
  final Value<String?> location;
  final Value<String?> teacherId;
  final Value<int> weight;
  final Value<int> grade;
  final Value<bool> isCompleted;
  final Value<bool> isGraded;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> needsSync;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.termId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.weight = const Value.absent(),
    this.grade = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamsCompanion.insert({
    required String id,
    required String userId,
    required String termId,
    required String subjectId,
    required String title,
    this.description = const Value.absent(),
    required DateTime date,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.weight = const Value.absent(),
    this.grade = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isGraded = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        termId = Value(termId),
        subjectId = Value(subjectId),
        title = Value(title),
        date = Value(date);
  static Insertable<Exam> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? termId,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? date,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<String>? location,
    Expression<String>? teacherId,
    Expression<int>? weight,
    Expression<int>? grade,
    Expression<bool>? isCompleted,
    Expression<bool>? isGraded,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? needsSync,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (termId != null) 'term_id': termId,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      if (teacherId != null) 'teacher_id': teacherId,
      if (weight != null) 'weight': weight,
      if (grade != null) 'grade': grade,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isGraded != null) 'is_graded': isGraded,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? termId,
      Value<String>? subjectId,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? date,
      Value<String?>? startTime,
      Value<String?>? endTime,
      Value<String?>? location,
      Value<String?>? teacherId,
      Value<int>? weight,
      Value<int>? grade,
      Value<bool>? isCompleted,
      Value<bool>? isGraded,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? cachedAt,
      Value<bool>? needsSync,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return ExamsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      teacherId: teacherId ?? this.teacherId,
      weight: weight ?? this.weight,
      grade: grade ?? this.grade,
      isCompleted: isCompleted ?? this.isCompleted,
      isGraded: isGraded ?? this.isGraded,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (grade.present) {
      map['grade'] = Variable<int>(grade.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isGraded.present) {
      map['is_graded'] = Variable<bool>(isGraded.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('teacherId: $teacherId, ')
          ..write('weight: $weight, ')
          ..write('grade: $grade, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isGraded: $isGraded, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HolidaysTable extends Holidays with TableInfo<$HolidaysTable, Holiday> {
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
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _countryCodeMeta =
      const VerificationMeta('countryCode');
  @override
  late final GeneratedColumn<String> countryCode = GeneratedColumn<String>(
      'country_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        startDate,
        endDate,
        source,
        countryCode,
        createdAt,
        cachedAt,
        needsSync,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holidays';
  @override
  VerificationContext validateIntegrity(Insertable<Holiday> instance,
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
    }
    if (data.containsKey('country_code')) {
      context.handle(
          _countryCodeMeta,
          countryCode.isAcceptableOrUnknown(
              data['country_code']!, _countryCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Holiday map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Holiday(
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
      countryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}country_code']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $HolidaysTable createAlias(String alias) {
    return $HolidaysTable(attachedDatabase, alias);
  }
}

class Holiday extends DataClass implements Insertable<Holiday> {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String source;
  final String? countryCode;
  final DateTime createdAt;
  final DateTime cachedAt;
  final bool needsSync;
  final bool isDeleted;
  const Holiday(
      {required this.id,
      required this.userId,
      required this.name,
      required this.startDate,
      required this.endDate,
      required this.source,
      this.countryCode,
      required this.createdAt,
      required this.cachedAt,
      required this.needsSync,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || countryCode != null) {
      map['country_code'] = Variable<String>(countryCode);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      countryCode: countryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(countryCode),
      createdAt: Value(createdAt),
      cachedAt: Value(cachedAt),
      needsSync: Value(needsSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory Holiday.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Holiday(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      source: serializer.fromJson<String>(json['source']),
      countryCode: serializer.fromJson<String?>(json['countryCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'countryCode': serializer.toJson<String?>(countryCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Holiday copyWith(
          {String? id,
          String? userId,
          String? name,
          DateTime? startDate,
          DateTime? endDate,
          String? source,
          Value<String?> countryCode = const Value.absent(),
          DateTime? createdAt,
          DateTime? cachedAt,
          bool? needsSync,
          bool? isDeleted}) =>
      Holiday(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        source: source ?? this.source,
        countryCode: countryCode.present ? countryCode.value : this.countryCode,
        createdAt: createdAt ?? this.createdAt,
        cachedAt: cachedAt ?? this.cachedAt,
        needsSync: needsSync ?? this.needsSync,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Holiday copyWithCompanion(HolidaysCompanion data) {
    return Holiday(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      source: data.source.present ? data.source.value : this.source,
      countryCode:
          data.countryCode.present ? data.countryCode.value : this.countryCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Holiday(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('source: $source, ')
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, startDate, endDate, source,
      countryCode, createdAt, cachedAt, needsSync, isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Holiday &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.source == this.source &&
          other.countryCode == this.countryCode &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt &&
          other.needsSync == this.needsSync &&
          other.isDeleted == this.isDeleted);
}

class HolidaysCompanion extends UpdateCompanion<Holiday> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> source;
  final Value<String?> countryCode;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;
  final Value<bool> needsSync;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const HolidaysCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.source = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidaysCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    this.source = const Value.absent(),
    this.countryCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        startDate = Value(startDate),
        endDate = Value(endDate);
  static Insertable<Holiday> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? source,
    Expression<String>? countryCode,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? needsSync,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (source != null) 'source': source,
      if (countryCode != null) 'country_code': countryCode,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
      Value<String?>? countryCode,
      Value<DateTime>? createdAt,
      Value<DateTime>? cachedAt,
      Value<bool>? needsSync,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return HolidaysCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      source: source ?? this.source,
      countryCode: countryCode ?? this.countryCode,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (countryCode.present) {
      map['country_code'] = Variable<String>(countryCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('countryCode: $countryCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeachersTable extends Teachers with TableInfo<$TeachersTable, Teacher> {
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
  static const VerificationMeta _officeLocationMeta =
      const VerificationMeta('officeLocation');
  @override
  late final GeneratedColumn<String> officeLocation = GeneratedColumn<String>(
      'office_location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _officeHoursMeta =
      const VerificationMeta('officeHours');
  @override
  late final GeneratedColumn<String> officeHours = GeneratedColumn<String>(
      'office_hours', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
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
        officeLocation,
        officeHours,
        createdAt,
        updatedAt,
        cachedAt,
        needsSync,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teachers';
  @override
  VerificationContext validateIntegrity(Insertable<Teacher> instance,
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
    if (data.containsKey('office_location')) {
      context.handle(
          _officeLocationMeta,
          officeLocation.isAcceptableOrUnknown(
              data['office_location']!, _officeLocationMeta));
    }
    if (data.containsKey('office_hours')) {
      context.handle(
          _officeHoursMeta,
          officeHours.isAcceptableOrUnknown(
              data['office_hours']!, _officeHoursMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Teacher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Teacher(
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
      officeLocation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}office_location']),
      officeHours: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}office_hours']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $TeachersTable createAlias(String alias) {
    return $TeachersTable(attachedDatabase, alias);
  }
}

class Teacher extends DataClass implements Insertable<Teacher> {
  final String id;
  final String userId;
  final String name;
  final String? position;
  final String? department;
  final String? affiliation;
  final String? email;
  final String? phone;
  final String? officeLocation;
  final String? officeHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final bool needsSync;
  final bool isDeleted;
  const Teacher(
      {required this.id,
      required this.userId,
      required this.name,
      this.position,
      this.department,
      this.affiliation,
      this.email,
      this.phone,
      this.officeLocation,
      this.officeHours,
      required this.createdAt,
      required this.updatedAt,
      required this.cachedAt,
      required this.needsSync,
      required this.isDeleted});
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
    if (!nullToAbsent || officeLocation != null) {
      map['office_location'] = Variable<String>(officeLocation);
    }
    if (!nullToAbsent || officeHours != null) {
      map['office_hours'] = Variable<String>(officeHours);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      officeLocation: officeLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(officeLocation),
      officeHours: officeHours == null && nullToAbsent
          ? const Value.absent()
          : Value(officeHours),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      needsSync: Value(needsSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory Teacher.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Teacher(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<String?>(json['position']),
      department: serializer.fromJson<String?>(json['department']),
      affiliation: serializer.fromJson<String?>(json['affiliation']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      officeLocation: serializer.fromJson<String?>(json['officeLocation']),
      officeHours: serializer.fromJson<String?>(json['officeHours']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'officeLocation': serializer.toJson<String?>(officeLocation),
      'officeHours': serializer.toJson<String?>(officeHours),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  Teacher copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> position = const Value.absent(),
          Value<String?> department = const Value.absent(),
          Value<String?> affiliation = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> officeLocation = const Value.absent(),
          Value<String?> officeHours = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? cachedAt,
          bool? needsSync,
          bool? isDeleted}) =>
      Teacher(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        position: position.present ? position.value : this.position,
        department: department.present ? department.value : this.department,
        affiliation: affiliation.present ? affiliation.value : this.affiliation,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        officeLocation:
            officeLocation.present ? officeLocation.value : this.officeLocation,
        officeHours: officeHours.present ? officeHours.value : this.officeHours,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
        needsSync: needsSync ?? this.needsSync,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  Teacher copyWithCompanion(TeachersCompanion data) {
    return Teacher(
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
      officeLocation: data.officeLocation.present
          ? data.officeLocation.value
          : this.officeLocation,
      officeHours:
          data.officeHours.present ? data.officeHours.value : this.officeHours,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Teacher(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('department: $department, ')
          ..write('affiliation: $affiliation, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('officeLocation: $officeLocation, ')
          ..write('officeHours: $officeHours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted')
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
      officeLocation,
      officeHours,
      createdAt,
      updatedAt,
      cachedAt,
      needsSync,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Teacher &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.position == this.position &&
          other.department == this.department &&
          other.affiliation == this.affiliation &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.officeLocation == this.officeLocation &&
          other.officeHours == this.officeHours &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.needsSync == this.needsSync &&
          other.isDeleted == this.isDeleted);
}

class TeachersCompanion extends UpdateCompanion<Teacher> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> position;
  final Value<String?> department;
  final Value<String?> affiliation;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> officeLocation;
  final Value<String?> officeHours;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> needsSync;
  final Value<bool> isDeleted;
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
    this.officeLocation = const Value.absent(),
    this.officeHours = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    this.officeLocation = const Value.absent(),
    this.officeHours = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name);
  static Insertable<Teacher> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? position,
    Expression<String>? department,
    Expression<String>? affiliation,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? officeLocation,
    Expression<String>? officeHours,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? needsSync,
    Expression<bool>? isDeleted,
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
      if (officeLocation != null) 'office_location': officeLocation,
      if (officeHours != null) 'office_hours': officeHours,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
      Value<String?>? officeLocation,
      Value<String?>? officeHours,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? cachedAt,
      Value<bool>? needsSync,
      Value<bool>? isDeleted,
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
      officeLocation: officeLocation ?? this.officeLocation,
      officeHours: officeHours ?? this.officeHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (officeLocation.present) {
      map['office_location'] = Variable<String>(officeLocation.value);
    }
    if (officeHours.present) {
      map['office_hours'] = Variable<String>(officeHours.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('officeLocation: $officeLocation, ')
          ..write('officeHours: $officeHours, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectDetailsTable extends SubjectDetails
    with TableInfo<$SubjectDetailsTable, SubjectDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectDetailsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#4CAF50'));
  static const VerificationMeta _creditsMeta =
      const VerificationMeta('credits');
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
      'credits', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _teacherIdMeta =
      const VerificationMeta('teacherId');
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
      'teacher_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syllabusMeta =
      const VerificationMeta('syllabus');
  @override
  late final GeneratedColumn<String> syllabus = GeneratedColumn<String>(
      'syllabus', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _finalGradeMeta =
      const VerificationMeta('finalGrade');
  @override
  late final GeneratedColumn<double> finalGrade = GeneratedColumn<double>(
      'final_grade', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightCategoriesJsonMeta =
      const VerificationMeta('weightCategoriesJson');
  @override
  late final GeneratedColumn<String> weightCategoriesJson =
      GeneratedColumn<String>('weight_categories_json', aliasedName, true,
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _needsSyncMeta =
      const VerificationMeta('needsSync');
  @override
  late final GeneratedColumn<bool> needsSync = GeneratedColumn<bool>(
      'needs_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("needs_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        termId,
        name,
        code,
        color,
        credits,
        teacherId,
        location,
        syllabus,
        useFinalGradeOverride,
        finalGrade,
        weightCategoriesJson,
        isCompleted,
        completedAt,
        createdAt,
        updatedAt,
        cachedAt,
        needsSync,
        isDeleted
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subject_details';
  @override
  VerificationContext validateIntegrity(Insertable<SubjectDetail> instance,
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
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('credits')) {
      context.handle(_creditsMeta,
          credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta));
    }
    if (data.containsKey('teacher_id')) {
      context.handle(_teacherIdMeta,
          teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('syllabus')) {
      context.handle(_syllabusMeta,
          syllabus.isAcceptableOrUnknown(data['syllabus']!, _syllabusMeta));
    }
    if (data.containsKey('use_final_grade_override')) {
      context.handle(
          _useFinalGradeOverrideMeta,
          useFinalGradeOverride.isAcceptableOrUnknown(
              data['use_final_grade_override']!, _useFinalGradeOverrideMeta));
    }
    if (data.containsKey('final_grade')) {
      context.handle(
          _finalGradeMeta,
          finalGrade.isAcceptableOrUnknown(
              data['final_grade']!, _finalGradeMeta));
    }
    if (data.containsKey('weight_categories_json')) {
      context.handle(
          _weightCategoriesJsonMeta,
          weightCategoriesJson.isAcceptableOrUnknown(
              data['weight_categories_json']!, _weightCategoriesJsonMeta));
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
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    if (data.containsKey('needs_sync')) {
      context.handle(_needsSyncMeta,
          needsSync.isAcceptableOrUnknown(data['needs_sync']!, _needsSyncMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubjectDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectDetail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      termId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      credits: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credits'])!,
      teacherId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_id']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      syllabus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}syllabus']),
      useFinalGradeOverride: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}use_final_grade_override'])!,
      finalGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}final_grade']),
      weightCategoriesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_categories_json']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
      needsSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}needs_sync'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
    );
  }

  @override
  $SubjectDetailsTable createAlias(String alias) {
    return $SubjectDetailsTable(attachedDatabase, alias);
  }
}

class SubjectDetail extends DataClass implements Insertable<SubjectDetail> {
  final String id;
  final String userId;
  final String termId;
  final String name;
  final String? code;
  final String color;
  final int credits;
  final String? teacherId;
  final String? location;
  final String? syllabus;
  final bool useFinalGradeOverride;
  final double? finalGrade;
  final String? weightCategoriesJson;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime cachedAt;
  final bool needsSync;
  final bool isDeleted;
  const SubjectDetail(
      {required this.id,
      required this.userId,
      required this.termId,
      required this.name,
      this.code,
      required this.color,
      required this.credits,
      this.teacherId,
      this.location,
      this.syllabus,
      required this.useFinalGradeOverride,
      this.finalGrade,
      this.weightCategoriesJson,
      required this.isCompleted,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.cachedAt,
      required this.needsSync,
      required this.isDeleted});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['term_id'] = Variable<String>(termId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['color'] = Variable<String>(color);
    map['credits'] = Variable<int>(credits);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<String>(teacherId);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || syllabus != null) {
      map['syllabus'] = Variable<String>(syllabus);
    }
    map['use_final_grade_override'] = Variable<bool>(useFinalGradeOverride);
    if (!nullToAbsent || finalGrade != null) {
      map['final_grade'] = Variable<double>(finalGrade);
    }
    if (!nullToAbsent || weightCategoriesJson != null) {
      map['weight_categories_json'] = Variable<String>(weightCategoriesJson);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    map['needs_sync'] = Variable<bool>(needsSync);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  SubjectDetailsCompanion toCompanion(bool nullToAbsent) {
    return SubjectDetailsCompanion(
      id: Value(id),
      userId: Value(userId),
      termId: Value(termId),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      color: Value(color),
      credits: Value(credits),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      syllabus: syllabus == null && nullToAbsent
          ? const Value.absent()
          : Value(syllabus),
      useFinalGradeOverride: Value(useFinalGradeOverride),
      finalGrade: finalGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(finalGrade),
      weightCategoriesJson: weightCategoriesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(weightCategoriesJson),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cachedAt: Value(cachedAt),
      needsSync: Value(needsSync),
      isDeleted: Value(isDeleted),
    );
  }

  factory SubjectDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectDetail(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      termId: serializer.fromJson<String>(json['termId']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      color: serializer.fromJson<String>(json['color']),
      credits: serializer.fromJson<int>(json['credits']),
      teacherId: serializer.fromJson<String?>(json['teacherId']),
      location: serializer.fromJson<String?>(json['location']),
      syllabus: serializer.fromJson<String?>(json['syllabus']),
      useFinalGradeOverride:
          serializer.fromJson<bool>(json['useFinalGradeOverride']),
      finalGrade: serializer.fromJson<double?>(json['finalGrade']),
      weightCategoriesJson:
          serializer.fromJson<String?>(json['weightCategoriesJson']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
      needsSync: serializer.fromJson<bool>(json['needsSync']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'termId': serializer.toJson<String>(termId),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'color': serializer.toJson<String>(color),
      'credits': serializer.toJson<int>(credits),
      'teacherId': serializer.toJson<String?>(teacherId),
      'location': serializer.toJson<String?>(location),
      'syllabus': serializer.toJson<String?>(syllabus),
      'useFinalGradeOverride': serializer.toJson<bool>(useFinalGradeOverride),
      'finalGrade': serializer.toJson<double?>(finalGrade),
      'weightCategoriesJson': serializer.toJson<String?>(weightCategoriesJson),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
      'needsSync': serializer.toJson<bool>(needsSync),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  SubjectDetail copyWith(
          {String? id,
          String? userId,
          String? termId,
          String? name,
          Value<String?> code = const Value.absent(),
          String? color,
          int? credits,
          Value<String?> teacherId = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> syllabus = const Value.absent(),
          bool? useFinalGradeOverride,
          Value<double?> finalGrade = const Value.absent(),
          Value<String?> weightCategoriesJson = const Value.absent(),
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          DateTime? cachedAt,
          bool? needsSync,
          bool? isDeleted}) =>
      SubjectDetail(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        termId: termId ?? this.termId,
        name: name ?? this.name,
        code: code.present ? code.value : this.code,
        color: color ?? this.color,
        credits: credits ?? this.credits,
        teacherId: teacherId.present ? teacherId.value : this.teacherId,
        location: location.present ? location.value : this.location,
        syllabus: syllabus.present ? syllabus.value : this.syllabus,
        useFinalGradeOverride:
            useFinalGradeOverride ?? this.useFinalGradeOverride,
        finalGrade: finalGrade.present ? finalGrade.value : this.finalGrade,
        weightCategoriesJson: weightCategoriesJson.present
            ? weightCategoriesJson.value
            : this.weightCategoriesJson,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        cachedAt: cachedAt ?? this.cachedAt,
        needsSync: needsSync ?? this.needsSync,
        isDeleted: isDeleted ?? this.isDeleted,
      );
  SubjectDetail copyWithCompanion(SubjectDetailsCompanion data) {
    return SubjectDetail(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      termId: data.termId.present ? data.termId.value : this.termId,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      color: data.color.present ? data.color.value : this.color,
      credits: data.credits.present ? data.credits.value : this.credits,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      location: data.location.present ? data.location.value : this.location,
      syllabus: data.syllabus.present ? data.syllabus.value : this.syllabus,
      useFinalGradeOverride: data.useFinalGradeOverride.present
          ? data.useFinalGradeOverride.value
          : this.useFinalGradeOverride,
      finalGrade:
          data.finalGrade.present ? data.finalGrade.value : this.finalGrade,
      weightCategoriesJson: data.weightCategoriesJson.present
          ? data.weightCategoriesJson.value
          : this.weightCategoriesJson,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
      needsSync: data.needsSync.present ? data.needsSync.value : this.needsSync,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectDetail(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('color: $color, ')
          ..write('credits: $credits, ')
          ..write('teacherId: $teacherId, ')
          ..write('location: $location, ')
          ..write('syllabus: $syllabus, ')
          ..write('useFinalGradeOverride: $useFinalGradeOverride, ')
          ..write('finalGrade: $finalGrade, ')
          ..write('weightCategoriesJson: $weightCategoriesJson, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      termId,
      name,
      code,
      color,
      credits,
      teacherId,
      location,
      syllabus,
      useFinalGradeOverride,
      finalGrade,
      weightCategoriesJson,
      isCompleted,
      completedAt,
      createdAt,
      updatedAt,
      cachedAt,
      needsSync,
      isDeleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectDetail &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.termId == this.termId &&
          other.name == this.name &&
          other.code == this.code &&
          other.color == this.color &&
          other.credits == this.credits &&
          other.teacherId == this.teacherId &&
          other.location == this.location &&
          other.syllabus == this.syllabus &&
          other.useFinalGradeOverride == this.useFinalGradeOverride &&
          other.finalGrade == this.finalGrade &&
          other.weightCategoriesJson == this.weightCategoriesJson &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cachedAt == this.cachedAt &&
          other.needsSync == this.needsSync &&
          other.isDeleted == this.isDeleted);
}

class SubjectDetailsCompanion extends UpdateCompanion<SubjectDetail> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> termId;
  final Value<String> name;
  final Value<String?> code;
  final Value<String> color;
  final Value<int> credits;
  final Value<String?> teacherId;
  final Value<String?> location;
  final Value<String?> syllabus;
  final Value<bool> useFinalGradeOverride;
  final Value<double?> finalGrade;
  final Value<String?> weightCategoriesJson;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> cachedAt;
  final Value<bool> needsSync;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const SubjectDetailsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.termId = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.color = const Value.absent(),
    this.credits = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.location = const Value.absent(),
    this.syllabus = const Value.absent(),
    this.useFinalGradeOverride = const Value.absent(),
    this.finalGrade = const Value.absent(),
    this.weightCategoriesJson = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectDetailsCompanion.insert({
    required String id,
    required String userId,
    required String termId,
    required String name,
    this.code = const Value.absent(),
    this.color = const Value.absent(),
    this.credits = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.location = const Value.absent(),
    this.syllabus = const Value.absent(),
    this.useFinalGradeOverride = const Value.absent(),
    this.finalGrade = const Value.absent(),
    this.weightCategoriesJson = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.needsSync = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        termId = Value(termId),
        name = Value(name);
  static Insertable<SubjectDetail> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? termId,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? color,
    Expression<int>? credits,
    Expression<String>? teacherId,
    Expression<String>? location,
    Expression<String>? syllabus,
    Expression<bool>? useFinalGradeOverride,
    Expression<double>? finalGrade,
    Expression<String>? weightCategoriesJson,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? cachedAt,
    Expression<bool>? needsSync,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (termId != null) 'term_id': termId,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (color != null) 'color': color,
      if (credits != null) 'credits': credits,
      if (teacherId != null) 'teacher_id': teacherId,
      if (location != null) 'location': location,
      if (syllabus != null) 'syllabus': syllabus,
      if (useFinalGradeOverride != null)
        'use_final_grade_override': useFinalGradeOverride,
      if (finalGrade != null) 'final_grade': finalGrade,
      if (weightCategoriesJson != null)
        'weight_categories_json': weightCategoriesJson,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (needsSync != null) 'needs_sync': needsSync,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectDetailsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? termId,
      Value<String>? name,
      Value<String?>? code,
      Value<String>? color,
      Value<int>? credits,
      Value<String?>? teacherId,
      Value<String?>? location,
      Value<String?>? syllabus,
      Value<bool>? useFinalGradeOverride,
      Value<double?>? finalGrade,
      Value<String?>? weightCategoriesJson,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime>? cachedAt,
      Value<bool>? needsSync,
      Value<bool>? isDeleted,
      Value<int>? rowid}) {
    return SubjectDetailsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      termId: termId ?? this.termId,
      name: name ?? this.name,
      code: code ?? this.code,
      color: color ?? this.color,
      credits: credits ?? this.credits,
      teacherId: teacherId ?? this.teacherId,
      location: location ?? this.location,
      syllabus: syllabus ?? this.syllabus,
      useFinalGradeOverride:
          useFinalGradeOverride ?? this.useFinalGradeOverride,
      finalGrade: finalGrade ?? this.finalGrade,
      weightCategoriesJson: weightCategoriesJson ?? this.weightCategoriesJson,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (termId.present) {
      map['term_id'] = Variable<String>(termId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (syllabus.present) {
      map['syllabus'] = Variable<String>(syllabus.value);
    }
    if (useFinalGradeOverride.present) {
      map['use_final_grade_override'] =
          Variable<bool>(useFinalGradeOverride.value);
    }
    if (finalGrade.present) {
      map['final_grade'] = Variable<double>(finalGrade.value);
    }
    if (weightCategoriesJson.present) {
      map['weight_categories_json'] =
          Variable<String>(weightCategoriesJson.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (needsSync.present) {
      map['needs_sync'] = Variable<bool>(needsSync.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectDetailsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('termId: $termId, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('color: $color, ')
          ..write('credits: $credits, ')
          ..write('teacherId: $teacherId, ')
          ..write('location: $location, ')
          ..write('syllabus: $syllabus, ')
          ..write('useFinalGradeOverride: $useFinalGradeOverride, ')
          ..write('finalGrade: $finalGrade, ')
          ..write('weightCategoriesJson: $weightCategoriesJson, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('needsSync: $needsSync, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $GroupMembersTable groupMembers = $GroupMembersTable(this);
  late final $CalendarEventsTable calendarEvents = $CalendarEventsTable(this);
  late final $FreeBlocksTable freeBlocks = $FreeBlocksTable(this);
  late final $CachedUsersTable cachedUsers = $CachedUsersTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TermsTable terms = $TermsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ClassTemplatesTable classTemplates = $ClassTemplatesTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $HolidaysTable holidays = $HolidaysTable(this);
  late final $TeachersTable teachers = $TeachersTable(this);
  late final $SubjectDetailsTable subjectDetails = $SubjectDetailsTable(this);
  late final GroupDao groupDao = GroupDao(this as AppDatabase);
  late final EventDao eventDao = EventDao(this as AppDatabase);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final MemberScheduleDao memberScheduleDao =
      MemberScheduleDao(this as AppDatabase);
  late final AssignmentDao assignmentDao = AssignmentDao(this as AppDatabase);
  late final ExamDao examDao = ExamDao(this as AppDatabase);
  late final HolidayDao holidayDao = HolidayDao(this as AppDatabase);
  late final TeacherDao teacherDao = TeacherDao(this as AppDatabase);
  late final AcademicDao academicDao = AcademicDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        groups,
        groupMembers,
        calendarEvents,
        freeBlocks,
        cachedUsers,
        syncQueue,
        appSettings,
        terms,
        subjects,
        classTemplates,
        assignments,
        exams,
        holidays,
        teachers,
        subjectDetails
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('group_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('groups',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('free_blocks', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('terms',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subjects', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('subjects',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('class_templates', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$GroupsTableCreateCompanionBuilder = GroupsCompanion Function({
  required String id,
  required String name,
  required String memberUids,
  Value<String?> imageUrl,
  required String createdBy,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$GroupsTableUpdateCompanionBuilder = GroupsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> memberUids,
  Value<String?> imageUrl,
  Value<String> createdBy,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

final class $$GroupsTableReferences
    extends BaseReferences<_$AppDatabase, $GroupsTable, Group> {
  $$GroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GroupMembersTable, List<GroupMember>>
      _groupMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.groupMembers,
              aliasName:
                  $_aliasNameGenerator(db.groups.id, db.groupMembers.groupId));

  $$GroupMembersTableProcessedTableManager get groupMembersRefs {
    final manager = $$GroupMembersTableTableManager($_db, $_db.groupMembers)
        .filter((f) => f.groupId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_groupMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FreeBlocksTable, List<FreeBlock>>
      _freeBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.freeBlocks,
          aliasName: $_aliasNameGenerator(db.groups.id, db.freeBlocks.groupId));

  $$FreeBlocksTableProcessedTableManager get freeBlocksRefs {
    final manager = $$FreeBlocksTableTableManager($_db, $_db.freeBlocks)
        .filter((f) => f.groupId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_freeBlocksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<String> get memberUids => $composableBuilder(
      column: $table.memberUids, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> groupMembersRefs(
      Expression<bool> Function($$GroupMembersTableFilterComposer f) f) {
    final $$GroupMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableFilterComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> freeBlocksRefs(
      Expression<bool> Function($$FreeBlocksTableFilterComposer f) f) {
    final $$FreeBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.freeBlocks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FreeBlocksTableFilterComposer(
              $db: $db,
              $table: $db.freeBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<String> get memberUids => $composableBuilder(
      column: $table.memberUids, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get memberUids => $composableBuilder(
      column: $table.memberUids, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> groupMembersRefs<T extends Object>(
      Expression<T> Function($$GroupMembersTableAnnotationComposer a) f) {
    final $$GroupMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.groupMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.groupMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> freeBlocksRefs<T extends Object>(
      Expression<T> Function($$FreeBlocksTableAnnotationComposer a) f) {
    final $$FreeBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.freeBlocks,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FreeBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.freeBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$GroupsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool groupMembersRefs, bool freeBlocksRefs})> {
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
            Value<String> memberUids = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion(
            id: id,
            name: name,
            memberUids: memberUids,
            imageUrl: imageUrl,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String memberUids,
            Value<String?> imageUrl = const Value.absent(),
            required String createdBy,
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupsCompanion.insert(
            id: id,
            name: name,
            memberUids: memberUids,
            imageUrl: imageUrl,
            createdBy: createdBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$GroupsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {groupMembersRefs = false, freeBlocksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (groupMembersRefs) db.groupMembers,
                if (freeBlocksRefs) db.freeBlocks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (groupMembersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._groupMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .groupMembersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items),
                  if (freeBlocksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$GroupsTableReferences._freeBlocksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$GroupsTableReferences(db, table, p0)
                                .freeBlocksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.groupId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$GroupsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupsTable,
    Group,
    $$GroupsTableFilterComposer,
    $$GroupsTableOrderingComposer,
    $$GroupsTableAnnotationComposer,
    $$GroupsTableCreateCompanionBuilder,
    $$GroupsTableUpdateCompanionBuilder,
    (Group, $$GroupsTableReferences),
    Group,
    PrefetchHooks Function({bool groupMembersRefs, bool freeBlocksRefs})>;
typedef $$GroupMembersTableCreateCompanionBuilder = GroupMembersCompanion
    Function({
  required String id,
  required String groupId,
  required String userId,
  required String userNick,
  required String userEmail,
  required DateTime joinedAt,
  Value<int> rowid,
});
typedef $$GroupMembersTableUpdateCompanionBuilder = GroupMembersCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> userId,
  Value<String> userNick,
  Value<String> userEmail,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

final class $$GroupMembersTableReferences
    extends BaseReferences<_$AppDatabase, $GroupMembersTable, GroupMember> {
  $$GroupMembersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.groupMembers.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager? get groupId {
    if ($_item.groupId == null) return null;
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id($_item.groupId!));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GroupMembersTableFilterComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableFilterComposer({
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

  ColumnFilters<String> get userNick => $composableBuilder(
      column: $table.userNick, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableOrderingComposer({
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

  ColumnOrderings<String> get userNick => $composableBuilder(
      column: $table.userNick, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userEmail => $composableBuilder(
      column: $table.userEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupMembersTable> {
  $$GroupMembersTableAnnotationComposer({
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

  GeneratedColumn<String> get userNick =>
      $composableBuilder(column: $table.userNick, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GroupMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId})> {
  $$GroupMembersTableTableManager(_$AppDatabase db, $GroupMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> userNick = const Value.absent(),
            Value<String> userEmail = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion(
            id: id,
            groupId: groupId,
            userId: userId,
            userNick: userNick,
            userEmail: userEmail,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String userId,
            required String userNick,
            required String userEmail,
            required DateTime joinedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              GroupMembersCompanion.insert(
            id: id,
            groupId: groupId,
            userId: userId,
            userNick: userNick,
            userEmail: userEmail,
            joinedAt: joinedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GroupMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$GroupMembersTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$GroupMembersTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GroupMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GroupMembersTable,
    GroupMember,
    $$GroupMembersTableFilterComposer,
    $$GroupMembersTableOrderingComposer,
    $$GroupMembersTableAnnotationComposer,
    $$GroupMembersTableCreateCompanionBuilder,
    $$GroupMembersTableUpdateCompanionBuilder,
    (GroupMember, $$GroupMembersTableReferences),
    GroupMember,
    PrefetchHooks Function({bool groupId})>;
typedef $$CalendarEventsTableCreateCompanionBuilder = CalendarEventsCompanion
    Function({
  required String id,
  required String title,
  required DateTime startTime,
  required DateTime endTime,
  required String eventType,
  required String ownerId,
  required String ownerName,
  required int colorValue,
  Value<String?> groupId,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CalendarEventsTableUpdateCompanionBuilder = CalendarEventsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> startTime,
  Value<DateTime> endTime,
  Value<String> eventType,
  Value<String> ownerId,
  Value<String> ownerName,
  Value<int> colorValue,
  Value<String?> groupId,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CalendarEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerName => $composableBuilder(
      column: $table.ownerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CalendarEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerName => $composableBuilder(
      column: $table.ownerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CalendarEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CalendarEventsTable> {
  $$CalendarEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CalendarEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEvent,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEvent,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>
    ),
    CalendarEvent,
    PrefetchHooks Function()> {
  $$CalendarEventsTableTableManager(
      _$AppDatabase db, $CalendarEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalendarEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalendarEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalendarEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime> endTime = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> ownerName = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<String?> groupId = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEventsCompanion(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            eventType: eventType,
            ownerId: ownerId,
            ownerName: ownerName,
            colorValue: colorValue,
            groupId: groupId,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime startTime,
            required DateTime endTime,
            required String eventType,
            required String ownerId,
            required String ownerName,
            required int colorValue,
            Value<String?> groupId = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CalendarEventsCompanion.insert(
            id: id,
            title: title,
            startTime: startTime,
            endTime: endTime,
            eventType: eventType,
            ownerId: ownerId,
            ownerName: ownerName,
            colorValue: colorValue,
            groupId: groupId,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CalendarEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CalendarEventsTable,
    CalendarEvent,
    $$CalendarEventsTableFilterComposer,
    $$CalendarEventsTableOrderingComposer,
    $$CalendarEventsTableAnnotationComposer,
    $$CalendarEventsTableCreateCompanionBuilder,
    $$CalendarEventsTableUpdateCompanionBuilder,
    (
      CalendarEvent,
      BaseReferences<_$AppDatabase, $CalendarEventsTable, CalendarEvent>
    ),
    CalendarEvent,
    PrefetchHooks Function()>;
typedef $$FreeBlocksTableCreateCompanionBuilder = FreeBlocksCompanion Function({
  required String id,
  required String groupId,
  required int weekday,
  required int startHour,
  required int startMinute,
  required int endHour,
  required int endMinute,
  required String freeMembers,
  required DateTime calculatedAt,
  Value<int> rowid,
});
typedef $$FreeBlocksTableUpdateCompanionBuilder = FreeBlocksCompanion Function({
  Value<String> id,
  Value<String> groupId,
  Value<int> weekday,
  Value<int> startHour,
  Value<int> startMinute,
  Value<int> endHour,
  Value<int> endMinute,
  Value<String> freeMembers,
  Value<DateTime> calculatedAt,
  Value<int> rowid,
});

final class $$FreeBlocksTableReferences
    extends BaseReferences<_$AppDatabase, $FreeBlocksTable, FreeBlock> {
  $$FreeBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GroupsTable _groupIdTable(_$AppDatabase db) => db.groups
      .createAlias($_aliasNameGenerator(db.freeBlocks.groupId, db.groups.id));

  $$GroupsTableProcessedTableManager? get groupId {
    if ($_item.groupId == null) return null;
    final manager = $$GroupsTableTableManager($_db, $_db.groups)
        .filter((f) => f.id($_item.groupId!));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FreeBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $FreeBlocksTable> {
  $$FreeBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get freeMembers => $composableBuilder(
      column: $table.freeMembers, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => ColumnFilters(column));

  $$GroupsTableFilterComposer get groupId {
    final $$GroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableFilterComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FreeBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $FreeBlocksTable> {
  $$FreeBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startHour => $composableBuilder(
      column: $table.startHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endHour => $composableBuilder(
      column: $table.endHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMinute => $composableBuilder(
      column: $table.endMinute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get freeMembers => $composableBuilder(
      column: $table.freeMembers, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt,
      builder: (column) => ColumnOrderings(column));

  $$GroupsTableOrderingComposer get groupId {
    final $$GroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableOrderingComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FreeBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FreeBlocksTable> {
  $$FreeBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
      column: $table.startMinute, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get freeMembers => $composableBuilder(
      column: $table.freeMembers, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => column);

  $$GroupsTableAnnotationComposer get groupId {
    final $$GroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.groups,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.groups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FreeBlocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FreeBlocksTable,
    FreeBlock,
    $$FreeBlocksTableFilterComposer,
    $$FreeBlocksTableOrderingComposer,
    $$FreeBlocksTableAnnotationComposer,
    $$FreeBlocksTableCreateCompanionBuilder,
    $$FreeBlocksTableUpdateCompanionBuilder,
    (FreeBlock, $$FreeBlocksTableReferences),
    FreeBlock,
    PrefetchHooks Function({bool groupId})> {
  $$FreeBlocksTableTableManager(_$AppDatabase db, $FreeBlocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FreeBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FreeBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FreeBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<int> weekday = const Value.absent(),
            Value<int> startHour = const Value.absent(),
            Value<int> startMinute = const Value.absent(),
            Value<int> endHour = const Value.absent(),
            Value<int> endMinute = const Value.absent(),
            Value<String> freeMembers = const Value.absent(),
            Value<DateTime> calculatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FreeBlocksCompanion(
            id: id,
            groupId: groupId,
            weekday: weekday,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            freeMembers: freeMembers,
            calculatedAt: calculatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required int weekday,
            required int startHour,
            required int startMinute,
            required int endHour,
            required int endMinute,
            required String freeMembers,
            required DateTime calculatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FreeBlocksCompanion.insert(
            id: id,
            groupId: groupId,
            weekday: weekday,
            startHour: startHour,
            startMinute: startMinute,
            endHour: endHour,
            endMinute: endMinute,
            freeMembers: freeMembers,
            calculatedAt: calculatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FreeBlocksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$FreeBlocksTableReferences._groupIdTable(db),
                    referencedColumn:
                        $$FreeBlocksTableReferences._groupIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FreeBlocksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FreeBlocksTable,
    FreeBlock,
    $$FreeBlocksTableFilterComposer,
    $$FreeBlocksTableOrderingComposer,
    $$FreeBlocksTableAnnotationComposer,
    $$FreeBlocksTableCreateCompanionBuilder,
    $$FreeBlocksTableUpdateCompanionBuilder,
    (FreeBlock, $$FreeBlocksTableReferences),
    FreeBlock,
    PrefetchHooks Function({bool groupId})>;
typedef $$CachedUsersTableCreateCompanionBuilder = CachedUsersCompanion
    Function({
  required String uid,
  required String nick,
  required String email,
  Value<String?> photoUrl,
  Value<String?> avatarPath,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CachedUsersTableUpdateCompanionBuilder = CachedUsersCompanion
    Function({
  Value<String> uid,
  Value<String> nick,
  Value<String> email,
  Value<String?> photoUrl,
  Value<String?> avatarPath,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedUsersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nick => $composableBuilder(
      column: $table.nick, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uid => $composableBuilder(
      column: $table.uid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nick => $composableBuilder(
      column: $table.nick, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumn<String> get nick =>
      $composableBuilder(column: $table.nick, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get avatarPath => $composableBuilder(
      column: $table.avatarPath, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedUsersTable,
    CachedUser,
    $$CachedUsersTableFilterComposer,
    $$CachedUsersTableOrderingComposer,
    $$CachedUsersTableAnnotationComposer,
    $$CachedUsersTableCreateCompanionBuilder,
    $$CachedUsersTableUpdateCompanionBuilder,
    (CachedUser, BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>),
    CachedUser,
    PrefetchHooks Function()> {
  $$CachedUsersTableTableManager(_$AppDatabase db, $CachedUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> uid = const Value.absent(),
            Value<String> nick = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUsersCompanion(
            uid: uid,
            nick: nick,
            email: email,
            photoUrl: photoUrl,
            avatarPath: avatarPath,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String uid,
            required String nick,
            required String email,
            Value<String?> photoUrl = const Value.absent(),
            Value<String?> avatarPath = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedUsersCompanion.insert(
            uid: uid,
            nick: nick,
            email: email,
            photoUrl: photoUrl,
            avatarPath: avatarPath,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedUsersTable,
    CachedUser,
    $$CachedUsersTableFilterComposer,
    $$CachedUsersTableOrderingComposer,
    $$CachedUsersTableAnnotationComposer,
    $$CachedUsersTableCreateCompanionBuilder,
    $$CachedUsersTableUpdateCompanionBuilder,
    (CachedUser, BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>),
    CachedUser,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String?> dataJson,
  required DateTime createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String?> dataJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
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
            Value<String?> dataJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            dataJson: dataJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String operation,
            Value<String?> dataJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            dataJson: dataJson,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
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
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;
typedef $$TermsTableCreateCompanionBuilder = TermsCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$TermsTableUpdateCompanionBuilder = TermsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<DateTime?> startDate,
  Value<DateTime?> endDate,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

final class $$TermsTableReferences
    extends BaseReferences<_$AppDatabase, $TermsTable, Term> {
  $$TermsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubjectsTable, List<Subject>> _subjectsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.subjects,
          aliasName: $_aliasNameGenerator(db.terms.id, db.subjects.termId));

  $$SubjectsTableProcessedTableManager get subjectsRefs {
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.termId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_subjectsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> subjectsRefs(
      Expression<bool> Function($$SubjectsTableFilterComposer f) f) {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.termId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  Expression<T> subjectsRefs<T extends Object>(
      Expression<T> Function($$SubjectsTableAnnotationComposer a) f) {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.termId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TermsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TermsTable,
    Term,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (Term, $$TermsTableReferences),
    Term,
    PrefetchHooks Function({bool subjectsRefs})> {
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
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<DateTime?> startDate = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TermsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TermsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({subjectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subjectsRefs) db.subjects],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subjectsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TermsTableReferences._subjectsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TermsTableReferences(db, table, p0).subjectsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.termId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TermsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TermsTable,
    Term,
    $$TermsTableFilterComposer,
    $$TermsTableOrderingComposer,
    $$TermsTableAnnotationComposer,
    $$TermsTableCreateCompanionBuilder,
    $$TermsTableUpdateCompanionBuilder,
    (Term, $$TermsTableReferences),
    Term,
    PrefetchHooks Function({bool subjectsRefs})>;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  required String id,
  required String termId,
  required String userId,
  required String name,
  Value<String?> code,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<String> id,
  Value<String> termId,
  Value<String> userId,
  Value<String> name,
  Value<String?> code,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TermsTable _termIdTable(_$AppDatabase db) => db.terms
      .createAlias($_aliasNameGenerator(db.subjects.termId, db.terms.id));

  $$TermsTableProcessedTableManager? get termId {
    if ($_item.termId == null) return null;
    final manager = $$TermsTableTableManager($_db, $_db.terms)
        .filter((f) => f.id($_item.termId!));
    final item = $_typedResult.readTableOrNull(_termIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClassTemplatesTable, List<ClassTemplate>>
      _classTemplatesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.classTemplates,
              aliasName: $_aliasNameGenerator(
                  db.subjects.id, db.classTemplates.subjectId));

  $$ClassTemplatesTableProcessedTableManager get classTemplatesRefs {
    final manager = $$ClassTemplatesTableTableManager($_db, $_db.classTemplates)
        .filter((f) => f.subjectId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_classTemplatesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  $$TermsTableFilterComposer get termId {
    final $$TermsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableFilterComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> classTemplatesRefs(
      Expression<bool> Function($$ClassTemplatesTableFilterComposer f) f) {
    final $$ClassTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classTemplates,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.classTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  $$TermsTableOrderingComposer get termId {
    final $$TermsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableOrderingComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$TermsTableAnnotationComposer get termId {
    final $$TermsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.termId,
        referencedTable: $db.terms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TermsTableAnnotationComposer(
              $db: $db,
              $table: $db.terms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> classTemplatesRefs<T extends Object>(
      Expression<T> Function($$ClassTemplatesTableAnnotationComposer a) f) {
    final $$ClassTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.classTemplates,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClassTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.classTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool termId, bool classTemplatesRefs})> {
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
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            termId: termId,
            userId: userId,
            name: name,
            code: code,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String termId,
            required String userId,
            required String name,
            Value<String?> code = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            termId: termId,
            userId: userId,
            name: name,
            code: code,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {termId = false, classTemplatesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (classTemplatesRefs) db.classTemplates
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (termId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.termId,
                    referencedTable: $$SubjectsTableReferences._termIdTable(db),
                    referencedColumn:
                        $$SubjectsTableReferences._termIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (classTemplatesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$SubjectsTableReferences
                            ._classTemplatesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubjectsTableReferences(db, table, p0)
                                .classTemplatesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subjectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool termId, bool classTemplatesRefs})>;
typedef $$ClassTemplatesTableCreateCompanionBuilder = ClassTemplatesCompanion
    Function({
  required String id,
  required String subjectId,
  required String userId,
  required int dayOfWeek,
  required String startTime,
  required String endTime,
  Value<String?> location,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$ClassTemplatesTableUpdateCompanionBuilder = ClassTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> userId,
  Value<int> dayOfWeek,
  Value<String> startTime,
  Value<String> endTime,
  Value<String?> location,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

final class $$ClassTemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $ClassTemplatesTable, ClassTemplate> {
  $$ClassTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
          $_aliasNameGenerator(db.classTemplates.subjectId, db.subjects.id));

  $$SubjectsTableProcessedTableManager? get subjectId {
    if ($_item.subjectId == null) return null;
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.id($_item.subjectId!));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableOrderingComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClassTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassTemplatesTable,
    ClassTemplate,
    $$ClassTemplatesTableFilterComposer,
    $$ClassTemplatesTableOrderingComposer,
    $$ClassTemplatesTableAnnotationComposer,
    $$ClassTemplatesTableCreateCompanionBuilder,
    $$ClassTemplatesTableUpdateCompanionBuilder,
    (ClassTemplate, $$ClassTemplatesTableReferences),
    ClassTemplate,
    PrefetchHooks Function({bool subjectId})> {
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
            Value<String> userId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<String> startTime = const Value.absent(),
            Value<String> endTime = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassTemplatesCompanion(
            id: id,
            subjectId: subjectId,
            userId: userId,
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
            location: location,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String userId,
            required int dayOfWeek,
            required String startTime,
            required String endTime,
            Value<String?> location = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClassTemplatesCompanion.insert(
            id: id,
            subjectId: subjectId,
            userId: userId,
            dayOfWeek: dayOfWeek,
            startTime: startTime,
            endTime: endTime,
            location: location,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClassTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (subjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subjectId,
                    referencedTable:
                        $$ClassTemplatesTableReferences._subjectIdTable(db),
                    referencedColumn:
                        $$ClassTemplatesTableReferences._subjectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ClassTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassTemplatesTable,
    ClassTemplate,
    $$ClassTemplatesTableFilterComposer,
    $$ClassTemplatesTableOrderingComposer,
    $$ClassTemplatesTableAnnotationComposer,
    $$ClassTemplatesTableCreateCompanionBuilder,
    $$ClassTemplatesTableUpdateCompanionBuilder,
    (ClassTemplate, $$ClassTemplatesTableReferences),
    ClassTemplate,
    PrefetchHooks Function({bool subjectId})>;
typedef $$AssignmentsTableCreateCompanionBuilder = AssignmentsCompanion
    Function({
  required String id,
  required String userId,
  required String termId,
  required String subjectId,
  required String title,
  Value<String> description,
  required DateTime dueDate,
  Value<String> priority,
  Value<int> weight,
  Value<int> grade,
  Value<String> status,
  Value<bool> isGraded,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$AssignmentsTableUpdateCompanionBuilder = AssignmentsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> termId,
  Value<String> subjectId,
  Value<String> title,
  Value<String> description,
  Value<DateTime> dueDate,
  Value<String> priority,
  Value<int> weight,
  Value<int> grade,
  Value<String> status,
  Value<bool> isGraded,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isGraded =>
      $composableBuilder(column: $table.isGraded, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$AssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssignmentsTable,
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment>),
    Assignment,
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
            Value<String> userId = const Value.absent(),
            Value<String> termId = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion(
            id: id,
            userId: userId,
            termId: termId,
            subjectId: subjectId,
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            weight: weight,
            grade: grade,
            status: status,
            isGraded: isGraded,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String termId,
            required String subjectId,
            required String title,
            Value<String> description = const Value.absent(),
            required DateTime dueDate,
            Value<String> priority = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssignmentsCompanion.insert(
            id: id,
            userId: userId,
            termId: termId,
            subjectId: subjectId,
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            weight: weight,
            grade: grade,
            status: status,
            isGraded: isGraded,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
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
    Assignment,
    $$AssignmentsTableFilterComposer,
    $$AssignmentsTableOrderingComposer,
    $$AssignmentsTableAnnotationComposer,
    $$AssignmentsTableCreateCompanionBuilder,
    $$AssignmentsTableUpdateCompanionBuilder,
    (Assignment, BaseReferences<_$AppDatabase, $AssignmentsTable, Assignment>),
    Assignment,
    PrefetchHooks Function()>;
typedef $$ExamsTableCreateCompanionBuilder = ExamsCompanion Function({
  required String id,
  required String userId,
  required String termId,
  required String subjectId,
  required String title,
  Value<String> description,
  required DateTime date,
  Value<String?> startTime,
  Value<String?> endTime,
  Value<String?> location,
  Value<String?> teacherId,
  Value<int> weight,
  Value<int> grade,
  Value<bool> isCompleted,
  Value<bool> isGraded,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$ExamsTableUpdateCompanionBuilder = ExamsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> termId,
  Value<String> subjectId,
  Value<String> title,
  Value<String> description,
  Value<DateTime> date,
  Value<String?> startTime,
  Value<String?> endTime,
  Value<String?> location,
  Value<String?> teacherId,
  Value<int> weight,
  Value<int> grade,
  Value<bool> isCompleted,
  Value<bool> isGraded,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGraded => $composableBuilder(
      column: $table.isGraded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isGraded =>
      $composableBuilder(column: $table.isGraded, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$ExamsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExamsTable,
    Exam,
    $$ExamsTableFilterComposer,
    $$ExamsTableOrderingComposer,
    $$ExamsTableAnnotationComposer,
    $$ExamsTableCreateCompanionBuilder,
    $$ExamsTableUpdateCompanionBuilder,
    (Exam, BaseReferences<_$AppDatabase, $ExamsTable, Exam>),
    Exam,
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
            Value<String> userId = const Value.absent(),
            Value<String> termId = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> startTime = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamsCompanion(
            id: id,
            userId: userId,
            termId: termId,
            subjectId: subjectId,
            title: title,
            description: description,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            teacherId: teacherId,
            weight: weight,
            grade: grade,
            isCompleted: isCompleted,
            isGraded: isGraded,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String termId,
            required String subjectId,
            required String title,
            Value<String> description = const Value.absent(),
            required DateTime date,
            Value<String?> startTime = const Value.absent(),
            Value<String?> endTime = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<int> weight = const Value.absent(),
            Value<int> grade = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isGraded = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExamsCompanion.insert(
            id: id,
            userId: userId,
            termId: termId,
            subjectId: subjectId,
            title: title,
            description: description,
            date: date,
            startTime: startTime,
            endTime: endTime,
            location: location,
            teacherId: teacherId,
            weight: weight,
            grade: grade,
            isCompleted: isCompleted,
            isGraded: isGraded,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
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
    Exam,
    $$ExamsTableFilterComposer,
    $$ExamsTableOrderingComposer,
    $$ExamsTableAnnotationComposer,
    $$ExamsTableCreateCompanionBuilder,
    $$ExamsTableUpdateCompanionBuilder,
    (Exam, BaseReferences<_$AppDatabase, $ExamsTable, Exam>),
    Exam,
    PrefetchHooks Function()>;
typedef $$HolidaysTableCreateCompanionBuilder = HolidaysCompanion Function({
  required String id,
  required String userId,
  required String name,
  required DateTime startDate,
  required DateTime endDate,
  Value<String> source,
  Value<String?> countryCode,
  Value<DateTime> createdAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$HolidaysTableUpdateCompanionBuilder = HolidaysCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> source,
  Value<String?> countryCode,
  Value<DateTime> createdAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get countryCode => $composableBuilder(
      column: $table.countryCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$HolidaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HolidaysTable,
    Holiday,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
    Holiday,
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
            Value<String?> countryCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HolidaysCompanion(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            source: source,
            countryCode: countryCode,
            createdAt: createdAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            required DateTime startDate,
            required DateTime endDate,
            Value<String> source = const Value.absent(),
            Value<String?> countryCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HolidaysCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            startDate: startDate,
            endDate: endDate,
            source: source,
            countryCode: countryCode,
            createdAt: createdAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
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
    Holiday,
    $$HolidaysTableFilterComposer,
    $$HolidaysTableOrderingComposer,
    $$HolidaysTableAnnotationComposer,
    $$HolidaysTableCreateCompanionBuilder,
    $$HolidaysTableUpdateCompanionBuilder,
    (Holiday, BaseReferences<_$AppDatabase, $HolidaysTable, Holiday>),
    Holiday,
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
  Value<String?> officeLocation,
  Value<String?> officeHours,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
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
  Value<String?> officeLocation,
  Value<String?> officeHours,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get officeLocation => $composableBuilder(
      column: $table.officeLocation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get officeHours => $composableBuilder(
      column: $table.officeHours, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get officeLocation => $composableBuilder(
      column: $table.officeLocation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get officeHours => $composableBuilder(
      column: $table.officeHours, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get officeLocation => $composableBuilder(
      column: $table.officeLocation, builder: (column) => column);

  GeneratedColumn<String> get officeHours => $composableBuilder(
      column: $table.officeHours, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$TeachersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TeachersTable,
    Teacher,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (Teacher, BaseReferences<_$AppDatabase, $TeachersTable, Teacher>),
    Teacher,
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
            Value<String?> officeLocation = const Value.absent(),
            Value<String?> officeHours = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
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
            officeLocation: officeLocation,
            officeHours: officeHours,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
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
            Value<String?> officeLocation = const Value.absent(),
            Value<String?> officeHours = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
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
            officeLocation: officeLocation,
            officeHours: officeHours,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
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
    Teacher,
    $$TeachersTableFilterComposer,
    $$TeachersTableOrderingComposer,
    $$TeachersTableAnnotationComposer,
    $$TeachersTableCreateCompanionBuilder,
    $$TeachersTableUpdateCompanionBuilder,
    (Teacher, BaseReferences<_$AppDatabase, $TeachersTable, Teacher>),
    Teacher,
    PrefetchHooks Function()>;
typedef $$SubjectDetailsTableCreateCompanionBuilder = SubjectDetailsCompanion
    Function({
  required String id,
  required String userId,
  required String termId,
  required String name,
  Value<String?> code,
  Value<String> color,
  Value<int> credits,
  Value<String?> teacherId,
  Value<String?> location,
  Value<String?> syllabus,
  Value<bool> useFinalGradeOverride,
  Value<double?> finalGrade,
  Value<String?> weightCategoriesJson,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
  Value<int> rowid,
});
typedef $$SubjectDetailsTableUpdateCompanionBuilder = SubjectDetailsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> termId,
  Value<String> name,
  Value<String?> code,
  Value<String> color,
  Value<int> credits,
  Value<String?> teacherId,
  Value<String?> location,
  Value<String?> syllabus,
  Value<bool> useFinalGradeOverride,
  Value<double?> finalGrade,
  Value<String?> weightCategoriesJson,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime> cachedAt,
  Value<bool> needsSync,
  Value<bool> isDeleted,
  Value<int> rowid,
});

class $$SubjectDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectDetailsTable> {
  $$SubjectDetailsTableFilterComposer({
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

  ColumnFilters<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syllabus => $composableBuilder(
      column: $table.syllabus, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightCategoriesJson => $composableBuilder(
      column: $table.weightCategoriesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));
}

class $$SubjectDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectDetailsTable> {
  $$SubjectDetailsTableOrderingComposer({
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

  ColumnOrderings<String> get termId => $composableBuilder(
      column: $table.termId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get credits => $composableBuilder(
      column: $table.credits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherId => $composableBuilder(
      column: $table.teacherId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syllabus => $composableBuilder(
      column: $table.syllabus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightCategoriesJson => $composableBuilder(
      column: $table.weightCategoriesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get needsSync => $composableBuilder(
      column: $table.needsSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));
}

class $$SubjectDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectDetailsTable> {
  $$SubjectDetailsTableAnnotationComposer({
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

  GeneratedColumn<String> get termId =>
      $composableBuilder(column: $table.termId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get syllabus =>
      $composableBuilder(column: $table.syllabus, builder: (column) => column);

  GeneratedColumn<bool> get useFinalGradeOverride => $composableBuilder(
      column: $table.useFinalGradeOverride, builder: (column) => column);

  GeneratedColumn<double> get finalGrade => $composableBuilder(
      column: $table.finalGrade, builder: (column) => column);

  GeneratedColumn<String> get weightCategoriesJson => $composableBuilder(
      column: $table.weightCategoriesJson, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);

  GeneratedColumn<bool> get needsSync =>
      $composableBuilder(column: $table.needsSync, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$SubjectDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectDetailsTable,
    SubjectDetail,
    $$SubjectDetailsTableFilterComposer,
    $$SubjectDetailsTableOrderingComposer,
    $$SubjectDetailsTableAnnotationComposer,
    $$SubjectDetailsTableCreateCompanionBuilder,
    $$SubjectDetailsTableUpdateCompanionBuilder,
    (
      SubjectDetail,
      BaseReferences<_$AppDatabase, $SubjectDetailsTable, SubjectDetail>
    ),
    SubjectDetail,
    PrefetchHooks Function()> {
  $$SubjectDetailsTableTableManager(
      _$AppDatabase db, $SubjectDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> termId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> syllabus = const Value.absent(),
            Value<bool> useFinalGradeOverride = const Value.absent(),
            Value<double?> finalGrade = const Value.absent(),
            Value<String?> weightCategoriesJson = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectDetailsCompanion(
            id: id,
            userId: userId,
            termId: termId,
            name: name,
            code: code,
            color: color,
            credits: credits,
            teacherId: teacherId,
            location: location,
            syllabus: syllabus,
            useFinalGradeOverride: useFinalGradeOverride,
            finalGrade: finalGrade,
            weightCategoriesJson: weightCategoriesJson,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String termId,
            required String name,
            Value<String?> code = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<int> credits = const Value.absent(),
            Value<String?> teacherId = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> syllabus = const Value.absent(),
            Value<bool> useFinalGradeOverride = const Value.absent(),
            Value<double?> finalGrade = const Value.absent(),
            Value<String?> weightCategoriesJson = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<bool> needsSync = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectDetailsCompanion.insert(
            id: id,
            userId: userId,
            termId: termId,
            name: name,
            code: code,
            color: color,
            credits: credits,
            teacherId: teacherId,
            location: location,
            syllabus: syllabus,
            useFinalGradeOverride: useFinalGradeOverride,
            finalGrade: finalGrade,
            weightCategoriesJson: weightCategoriesJson,
            isCompleted: isCompleted,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            cachedAt: cachedAt,
            needsSync: needsSync,
            isDeleted: isDeleted,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SubjectDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectDetailsTable,
    SubjectDetail,
    $$SubjectDetailsTableFilterComposer,
    $$SubjectDetailsTableOrderingComposer,
    $$SubjectDetailsTableAnnotationComposer,
    $$SubjectDetailsTableCreateCompanionBuilder,
    $$SubjectDetailsTableUpdateCompanionBuilder,
    (
      SubjectDetail,
      BaseReferences<_$AppDatabase, $SubjectDetailsTable, SubjectDetail>
    ),
    SubjectDetail,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$GroupMembersTableTableManager get groupMembers =>
      $$GroupMembersTableTableManager(_db, _db.groupMembers);
  $$CalendarEventsTableTableManager get calendarEvents =>
      $$CalendarEventsTableTableManager(_db, _db.calendarEvents);
  $$FreeBlocksTableTableManager get freeBlocks =>
      $$FreeBlocksTableTableManager(_db, _db.freeBlocks);
  $$CachedUsersTableTableManager get cachedUsers =>
      $$CachedUsersTableTableManager(_db, _db.cachedUsers);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TermsTableTableManager get terms =>
      $$TermsTableTableManager(_db, _db.terms);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ClassTemplatesTableTableManager get classTemplates =>
      $$ClassTemplatesTableTableManager(_db, _db.classTemplates);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$HolidaysTableTableManager get holidays =>
      $$HolidaysTableTableManager(_db, _db.holidays);
  $$TeachersTableTableManager get teachers =>
      $$TeachersTableTableManager(_db, _db.teachers);
  $$SubjectDetailsTableTableManager get subjectDetails =>
      $$SubjectDetailsTableTableManager(_db, _db.subjectDetails);
}
