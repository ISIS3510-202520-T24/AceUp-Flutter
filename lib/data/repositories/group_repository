import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../local/database/app_database.dart' as db;
import '../remote/firestore_paths.dart';
import '../../models/shared/group_model.dart';
import '../../models/shared/group_member_model.dart';
import '../../models/shared/weekly_availability_model.dart';

class GroupRepository {
  final db.AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  GroupRepository({
    required db.AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== GROUPS ====================

  /// Get all groups for a user (offline-first)
  Future<List<Group>> getGroupsForUser(String userId, {bool skipFirestore = false}) async {
    // 1. Load from local cache first
    final localGroups = await _db.groupDao.getGroupsForUser(userId);
    
    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localGroups.length} groups from cache');
      return localGroups.map(_groupRowToModel).toList();
    }

    // 2. Fetch from Firestore in background
    try {
      final groups = await _fetchGroupsFromFirestore(userId);
      
      // 3. Update local cache with fresh data
      for (final group in groups) {
        await _db.groupDao.upsertGroup(
          id: group.id,
          name: group.name,
          description: group.description,
          color: group.color,
          ownerId: group.ownerId,
          inviteCode: group.inviteCode,
          createdAt: group.createdAt,
          updatedAt: group.updatedAt,
        );
        
        // Cache members
        for (final member in group.members) {
          await _db.groupDao.upsertGroupMember(
            groupId: group.id,
            userId: member.userId,
            nickname: member.nickname,
            joinedAt: member.joinedAt,
          );
        }
      }
      
      print('✅ Synced ${groups.length} groups from Firestore');
      return groups;
    } catch (e) {
      print('⚠️ Failed to fetch groups from Firestore: $e');
      // Return cached data on error
      return localGroups.map(_groupRowToModel).toList();
    }
  }

  /// Create a new group
  Future<Group> createGroup({
    required String name,
    String? description,
    required String color,
    required String ownerId,
    required String ownerNickname,
  }) async {
    final id = _uuid.v4();
    final inviteCode = _generateInviteCode();
    final now = DateTime.now();
    
    final group = Group(
      id: id,
      name: name,
      description: description,
      color: color,
      ownerId: ownerId,
      inviteCode: inviteCode,
      members: [
        GroupMember(
          userId: ownerId,
          nickname: ownerNickname,
          joinedAt: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    
    // 1. Save to local database
    await _db.groupDao.upsertGroup(
      id: group.id,
      name: group.name,
      description: group.description,
      color: group.color,
      ownerId: group.ownerId,
      inviteCode: group.inviteCode,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
    
    // Save owner as member
    await _db.groupDao.upsertGroupMember(
      groupId: group.id,
      userId: ownerId,
      nickname: ownerNickname,
      joinedAt: now,
    );
    
    // 2. Queue for sync if online, or queue operation
    if (_connectivity.isOnline) {
      try {
        await _saveGroupToFirestore(group);
        print('✅ Group created and synced to Firestore');
      } catch (e) {
        print('⚠️ Failed to sync new group, queueing for later: $e');
        await _queueSyncOperation('create', 'group', group.id, group.toJson());
      }
    } else {
      await _queueSyncOperation('create', 'group', group.id, group.toJson());
    }
    
    return group;
  }

  /// Update an existing group
  Future<void> updateGroup(Group group) async {
    final updatedGroup = group.copyWith(updatedAt: DateTime.now());
    
    // 1. Update local database
    await _db.groupDao.upsertGroup(
      id: updatedGroup.id,
      name: updatedGroup.name,
      description: updatedGroup.description,
      color: updatedGroup.color,
      ownerId: updatedGroup.ownerId,
      inviteCode: updatedGroup.inviteCode,
      createdAt: updatedGroup.createdAt,
      updatedAt: updatedGroup.updatedAt,
    );
    
    // 2. Sync or queue
    if (_connectivity.isOnline) {
      try {
        await _saveGroupToFirestore(updatedGroup);
      } catch (e) {
        await _queueSyncOperation('update', 'group', updatedGroup.id, updatedGroup.toJson());
      }
    } else {
      await _queueSyncOperation('update', 'group', updatedGroup.id, updatedGroup.toJson());
    }
  }

  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    // 1. Delete from local database
    await _db.groupDao.deleteGroup(groupId);
    
    // 2. Sync or queue
    if (_connectivity.isOnline) {
      try {
        await _firestore.doc(FirestorePaths.group(groupId)).delete();
      } catch (e) {
        await _queueSyncOperation('delete', 'group', groupId, null);
      }
    } else {
      await _queueSyncOperation('delete', 'group', groupId, null);
    }
  }

  /// Join a group by invite code
  Future<Group?> joinGroupByCode({
    required String inviteCode,
    required String userId,
    required String userNickname,
  }) async {
    if (!_connectivity.isOnline) {
      throw Exception('Internet connection required to join a group');
    }
    
    // 1. Find group by invite code
    final querySnapshot = await _firestore
        .collection(FirestorePaths.groups)
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    
    final groupDoc = querySnapshot.docs.first;
    final group = Group.fromFirestore(groupDoc);
    
    // 2. Check if already a member
    if (group.members.any((m) => m.userId == userId)) {
      return group; // Already a member
    }
    
    // 3. Add user as member
    final newMember = GroupMember(
      userId: userId,
      nickname: userNickname,
      joinedAt: DateTime.now(),
    );
    
    await _firestore.doc(FirestorePaths.group(group.id)).update({
      'members': FieldValue.arrayUnion([newMember.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // 4. Update local cache
    final updatedMembers = [...group.members, newMember];
    final updatedGroup = group.copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
    
    await _db.groupDao.upsertGroup(
      id: updatedGroup.id,
      name: updatedGroup.name,
      description: updatedGroup.description,
      color: updatedGroup.color,
      ownerId: updatedGroup.ownerId,
      inviteCode: updatedGroup.inviteCode,
      createdAt: updatedGroup.createdAt,
      updatedAt: updatedGroup.updatedAt,
    );
    
    await _db.groupDao.upsertGroupMember(
      groupId: group.id,
      userId: userId,
      nickname: userNickname,
      joinedAt: newMember.joinedAt,
    );
    
    return updatedGroup;
  }

  /// Leave a group
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    // 1. Remove from local cache
    await _db.groupDao.removeGroupMember(groupId, userId);
    
    // 2. Sync to Firestore
    if (_connectivity.isOnline) {
      try {
        final groupDoc = await _firestore.doc(FirestorePaths.group(groupId)).get();
        if (groupDoc.exists) {
          final group = Group.fromFirestore(groupDoc);
          final memberToRemove = group.members.firstWhere(
            (m) => m.userId == userId,
            orElse: () => GroupMember(userId: '', nickname: '', joinedAt: DateTime.now()),
          );
          
          if (memberToRemove.userId.isNotEmpty) {
            await _firestore.doc(FirestorePaths.group(groupId)).update({
              'members': FieldValue.arrayRemove([memberToRemove.toJson()]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (e) {
        print('⚠️ Failed to sync leave group: $e');
        await _queueSyncOperation('leave', 'group_member', '$groupId:$userId', null);
      }
    } else {
      await _queueSyncOperation('leave', 'group_member', '$groupId:$userId', null);
    }
  }

  /// Get group members
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    // Load from local cache
    final localMembers = await _db.groupDao.getGroupMembers(groupId);
    return localMembers.map((row) => GroupMember(
      userId: row.userId,
      nickname: row.nickname,
      joinedAt: row.joinedAt,
    )).toList();
  }

  // ==================== WEEKLY AVAILABILITY ====================

  /// Get weekly availability for a group
  Future<WeeklyAvailability?> getWeeklyAvailability(
    String groupId,
    String weekIdentifier,
  ) async {
    // 1. Try local cache first
    final localData = await _db.groupDao.getWeeklyAvailability(groupId, weekIdentifier);
    
    if (localData != null) {
      return WeeklyAvailability.fromJsonLocal(localData);
    }
    
    // 2. Fetch from Firestore if online
    if (_connectivity.isOnline) {
      try {
        final doc = await _firestore
            .doc(FirestorePaths.weekAvailability(groupId, weekIdentifier))
            .get();
        
        if (doc.exists) {
          final availability = WeeklyAvailability.fromFirestore(doc);
          
          // Cache locally
          await _db.groupDao.saveWeeklyAvailability(
            groupId: groupId,
            weekIdentifier: weekIdentifier,
            data: availability.toJsonLocal(),
          );
          
          return availability;
        }
      } catch (e) {
        print('⚠️ Failed to fetch weekly availability: $e');
      }
    }
    
    return null;
  }

  /// Save weekly availability (typically called by Cloud Functions)
  Future<void> saveWeeklyAvailability(
    String groupId,
    WeeklyAvailability availability,
  ) async {
    // Save to local cache
    await _db.groupDao.saveWeeklyAvailability(
      groupId: groupId,
      weekIdentifier: availability.weekIdentifier,
      data: availability.toJsonLocal(),
    );
    
    // Sync to Firestore if online
    if (_connectivity.isOnline) {
      try {
        await _firestore
            .doc(FirestorePaths.weekAvailability(groupId, availability.weekIdentifier))
            .set(availability.toJson());
      } catch (e) {
        print('⚠️ Failed to sync weekly availability: $e');
      }
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<List<Group>> _fetchGroupsFromFirestore(String userId) async {
    final querySnapshot = await _firestore
        .collection(FirestorePaths.groups)
        .where('members', arrayContainsAny: [
          {'userId': userId}
        ])
        .get();
    
    // Fallback: query by ownerId or iterate
    // The array-contains query might not work perfectly with nested objects
    // So we need to handle this case
    if (querySnapshot.docs.isEmpty) {
      // Try getting groups where user is owner
      final ownerQuery = await _firestore
          .collection(FirestorePaths.groups)
          .where('ownerId', isEqualTo: userId)
          .get();
      
      return ownerQuery.docs.map((doc) => Group.fromFirestore(doc)).toList();
    }
    
    return querySnapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
  }

  Future<void> _saveGroupToFirestore(Group group) async {
    await _firestore.doc(FirestorePaths.group(group.id)).set(group.toJson());
  }

  Future<void> _queueSyncOperation(
    String operation,
    String entityType,
    String entityId,
    Map<String, dynamic>? data,
  ) async {
    await _db.syncDao.addSyncOperation(
      id: _uuid.v4(),
      operation: operation,
      entityType: entityType,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    var code = '';
    var seed = random;
    for (var i = 0; i < 6; i++) {
      code += chars[seed % chars.length];
      seed = (seed ~/ chars.length) + random + i;
    }
    return code;
  }

  Group _groupRowToModel(db.GroupsTableData row) {
    return Group(
      id: row.id,
      name: row.name,
      description: row.description,
      color: row.color,
      ownerId: row.ownerId,
      inviteCode: row.inviteCode,
      members: [], // Members loaded separately
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}