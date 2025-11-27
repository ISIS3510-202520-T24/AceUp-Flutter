import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart'; // ignore: uri_does_not_exist
import '../../models/shared/group_model.dart' as model;
import '../../models/shared/group_member_model.dart';
import '../../models/shared/weekly_availability_model.dart' as model;
import '../../models/helpers/time_slot_model.dart';
import '../local/database/app_database.dart';

/// Repository for group and shared data management with offline-first pattern
class GroupRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  GroupRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== GROUPS - OFFLINE-FIRST READ ====================

  /// Get groups owned by user from local database
  Future<List<model.Group>> getGroupsOwnedByUser(String userId) async {
    final entities = await _db.groupDao.getGroupsOwnedByUser(userId);
    return entities.map(_groupEntityToModel).toList();
  }

  /// Watch groups owned by user (stream)
  Stream<List<model.Group>> watchGroupsOwnedByUser(String userId) {
    return _db.groupDao.watchGroupsOwnedByUser(userId).map(
          (entities) => entities.map(_groupEntityToModel).toList(),
        );
  }

  /// Get all groups where user is a member
  Future<List<model.Group>> getGroupsForMember(String userId) async {
    final allEntities = await _db.groupDao.getAllGroups();
    return allEntities
        .map(_groupEntityToModel)
        .where((group) => group.isMember(userId))
        .toList();
  }

  /// Get group by ID
  Future<model.Group?> getGroupById(String groupId) async {
    final entity = await _db.groupDao.getGroupById(groupId);
    if (entity == null) return null;
    return _groupEntityToModel(entity);
  }

  /// Watch group by ID (stream)
  Stream<model.Group?> watchGroupById(String groupId) {
    return _db.groupDao.watchGroupById(groupId).map((entity) {
      if (entity == null) return null;
      return _groupEntityToModel(entity);
    });
  }

  /// Get group by invite code
  Future<model.Group?> getGroupByInviteCode(String inviteCode) async {
    final entity = await _db.groupDao.getGroupByInviteCode(inviteCode);
    if (entity == null) return null;
    return _groupEntityToModel(entity);
  }

  // ==================== GROUPS - OFFLINE-FIRST WRITE ====================

  /// Save group locally and queue for sync
  Future<void> saveGroup(model.Group group) async {
    final companion = _groupModelToCompanion(group);

    await _db.groupDao.upsertGroup(companion);

    await _queueSync(
      entityType: 'group',
      entityId: group.id,
      operation: 'update',
      data: group.toJson(),
      documentPath: 'groups/${group.id}',
    );
  }

  /// Add member to group
  Future<void> addMemberToGroup(String groupId, GroupMember member) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final updatedMembers = [...group.members, member];
    final updatedGroup = group.copyWith(members: updatedMembers);

    await saveGroup(updatedGroup);
  }

  /// Remove member from group
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final updatedMembers = group.members.where((m) => m.userId != userId).toList();
    final updatedGroup = group.copyWith(members: updatedMembers);

    await saveGroup(updatedGroup);
  }

  /// Delete group
  Future<void> deleteGroup(String groupId) async {
    await _db.groupDao.deleteGroup(groupId);

    await _queueSync(
      entityType: 'group',
      entityId: groupId,
      operation: 'delete',
      data: {},
      documentPath: 'groups/$groupId',
    );
  }

  // ==================== GROUPS - FIREBASE SYNC ====================

  /// Fetch groups from Firebase where user is owner
  Future<List<model.Group>> fetchGroupsOwnedByUserFromFirebase(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .where('ownerId', isEqualTo: userId)
          .get();

      final groups = snapshot.docs.map((doc) => model.Group.fromFirestore(doc)).toList();

      // Store locally
      for (final group in groups) {
        final companion = _groupModelToCompanion(group);
        await _db.groupDao.upsertGroup(companion);
        await _db.groupDao.markGroupAsSynced(group.id);
      }

      return groups;
    } catch (e) {
      print('Error fetching groups from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch group by ID from Firebase
  Future<model.Group?> fetchGroupFromFirebase(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();

      if (!doc.exists) return null;

      final group = model.Group.fromFirestore(doc);

      // Store locally
      final companion = _groupModelToCompanion(group);
      await _db.groupDao.upsertGroup(companion);
      await _db.groupDao.markGroupAsSynced(group.id);

      return group;
    } catch (e) {
      print('Error fetching group from Firebase: $e');
      rethrow;
    }
  }

  /// Join group by invite code
  Future<model.Group?> joinGroupByInviteCode(String inviteCode, String userId, String nickname) async {
    try {
      // Fetch group from Firebase
      final snapshot = await _firestore
          .collection('groups')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final group = model.Group.fromFirestore(snapshot.docs.first);

      // Add member to group
      final newMember = GroupMember(
        userId: userId,
        nickname: nickname,
        joinedAt: DateTime.now(),
      );

      final updatedGroup = group.copyWith(
        members: [...group.members, newMember],
        updatedAt: DateTime.now(),
      );

      // Save to Firebase
      await _firestore
          .collection('groups')
          .doc(group.id)
          .update(updatedGroup.toFirestore());

      // Save locally
      await saveGroup(updatedGroup);

      return updatedGroup;
    } catch (e) {
      print('Error joining group: $e');
      rethrow;
    }
  }

  // ==================== WEEKLY AVAILABILITY ====================

  /// Get weekly availability for group
  Future<model.WeeklyAvailability?> getWeeklyAvailability(String groupId, String weekIdentifier) async {
    final entity = await _db.groupDao.getWeeklyAvailability(groupId, weekIdentifier);
    if (entity == null) return null;
    return _weeklyAvailabilityEntityToModel(entity);
  }

  /// Watch weekly availability for group (stream)
  Stream<model.WeeklyAvailability?> watchWeeklyAvailability(String groupId, String weekIdentifier) {
    return _db.groupDao.watchWeeklyAvailability(groupId, weekIdentifier).map((entity) {
      if (entity == null) return null;
      return _weeklyAvailabilityEntityToModel(entity);
    });
  }

  /// Get all weekly availabilities for group
  Future<List<model.WeeklyAvailability>> getWeeklyAvailabilitiesForGroup(String groupId) async {
    final entities = await _db.groupDao.getWeeklyAvailabilitiesForGroup(groupId);
    return entities.map(_weeklyAvailabilityEntityToModel).toList();
  }

  /// Save weekly availability locally and queue for sync
  Future<void> saveWeeklyAvailability(model.WeeklyAvailability availability, String groupId) async {
    final companion = _weeklyAvailabilityModelToCompanion(availability, groupId);

    await _db.groupDao.upsertWeeklyAvailability(companion);

    await _queueSync(
      entityType: 'weekly_availability',
      entityId: availability.id,
      operation: 'update',
      data: availability.toJson(),
      documentPath: 'groups/$groupId/weeklyAvailability/${availability.id}',
    );
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert group entity to model
  model.Group _groupEntityToModel(GroupEntity entity) {
    final members = _parseMembersJson(entity.membersJson);

    return model.Group(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      color: entity.color,
      imageUrl: entity.imageUrl,
      ownerId: entity.ownerId,
      members: members,
      inviteCode: entity.inviteCode,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert group model to companion
  GroupsCompanion _groupModelToCompanion(model.Group group) {
    return GroupsCompanion(
      id: Value(group.id), //ignore: undefined_method
      name: Value(group.name), //ignore: undefined_method
      description: Value(group.description), //ignore: undefined_method
      color: Value(group.color), //ignore: undefined_method
      imageUrl: Value(group.imageUrl), //ignore: undefined_method
      ownerId: Value(group.ownerId), //ignore: undefined_method
      membersJson: Value(jsonEncode(group.members.map((m) => m.toJsonLocal()).toList())), //ignore: undefined_method
      inviteCode: Value(group.inviteCode), //ignore: undefined_method
      createdAt: Value(group.createdAt), //ignore: undefined_method
      updatedAt: Value(group.updatedAt), //ignore: undefined_method
      syncStatus: const Value('pending'), //ignore: creation_with_non_type
      lastSyncedAt: Value(DateTime.now()), //ignore: undefined_method
    );
  }

  /// Parse members JSON string
  List<GroupMember> _parseMembersJson(String jsonStr) {
    try {
      if (jsonStr.isEmpty || jsonStr == '[]') return [];
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => GroupMember.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing members JSON: $e');
      return [];
    }
  }

  /// Convert weekly availability entity to model
  model.WeeklyAvailability _weeklyAvailabilityEntityToModel(WeeklyAvailabilityEntity entity) {
    final dailySlots = DailySlots.fromJsonString(entity.dailySlotsJson);

    return model.WeeklyAvailability(
      id: entity.id,
      weekIdentifier: entity.weekIdentifier,
      weekStartDate: entity.weekStartDate,
      weekEndDate: entity.weekEndDate,
      dailySlots: dailySlots,
      calculatedAt: entity.calculatedAt,
    );
  }

  /// Convert weekly availability model to companion
  WeeklyAvailabilitiesCompanion _weeklyAvailabilityModelToCompanion(
      model.WeeklyAvailability availability, String groupId) {
    return WeeklyAvailabilitiesCompanion(
      id: Value(availability.id), //ignore: undefined_method
      groupId: Value(groupId), //ignore: undefined_method
      weekIdentifier: Value(availability.weekIdentifier), //ignore: undefined_method
      weekStartDate: Value(availability.weekStartDate), //ignore: undefined_method
      weekEndDate: Value(availability.weekEndDate), //ignore: undefined_method
      dailySlotsJson: Value(availability.dailySlots.toJsonString()), //ignore: undefined_method
      calculatedAt: Value(availability.calculatedAt), //ignore: undefined_method
      syncStatus: const Value('pending'), //ignore: creation_with_non_type
      lastSyncedAt: Value(DateTime.now()), //ignore: undefined_method
    );
  }

  // ==================== SYNC QUEUE HELPERS ====================

  /// Queue sync operation
  Future<void> _queueSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    required String documentPath,
  }) async {
    await _db.syncDao.queueSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
