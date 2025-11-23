import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../local/database/app_database.dart' as db;
import '../remote/firestore_paths.dart';
import '../../models/shared/group_model.dart';
import '../../models/shared/group_member_model.dart';
import '../../models/user_model.dart';

class SharedRepository {
  final db.AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  SharedRepository({
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
      print('📦 [SharedRepo] Loaded ${localGroups.length} groups from cache');
      return localGroups.map(_groupRowToModel).toList();
    }

    // 2. Fetch from Firestore
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
      
      print('✅ [SharedRepo] Synced ${groups.length} groups from Firestore');
      return groups;
    } catch (e) {
      print('⚠️ [SharedRepo] Failed to fetch groups from Firestore: $e');
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
    
    await _db.groupDao.upsertGroupMember(
      groupId: group.id,
      userId: ownerId,
      nickname: ownerNickname,
      joinedAt: now,
    );
    
    // 2. Sync to Firestore
    if (_connectivity.isOnline) {
      try {
        await _saveGroupToFirestore(group);
        print('✅ [SharedRepo] Group created and synced');
      } catch (e) {
        print('⚠️ [SharedRepo] Failed to sync new group: $e');
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
    await _db.groupDao.deleteGroup(groupId);
    
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

  /// Get group members
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final localMembers = await _db.groupDao.getGroupMembers(groupId);
    return localMembers.map((row) => GroupMember(
      userId: row.userId,
      nickname: row.nickname,
      joinedAt: row.joinedAt,
    )).toList();
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
    
    if (group.members.any((m) => m.userId == userId)) {
      return group;
    }
    
    final newMember = GroupMember(
      userId: userId,
      nickname: userNickname,
      joinedAt: DateTime.now(),
    );
    
    await _firestore.doc(FirestorePaths.group(group.id)).update({
      'members': FieldValue.arrayUnion([newMember.toJson()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    final updatedGroup = group.copyWith(
      members: [...group.members, newMember],
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
    await _db.groupDao.removeGroupMember(groupId, userId);
    
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
        await _queueSyncOperation('leave', 'group_member', '$groupId:$userId', null);
      }
    } else {
      await _queueSyncOperation('leave', 'group_member', '$groupId:$userId', null);
    }
  }

  // ==================== USERS (for member selection) ====================

  /// Get all users (for adding members to groups)
  Future<List<AppUser>> getAllUsers() async {
    if (!_connectivity.isOnline) {
      // Return cached users if offline
      final localUsers = await _db.userDao.getAllUsers();
      return localUsers.map((row) => AppUser(
        uid: row.uid,
        email: row.email,
        nickname: row.nickname,
        avatar: row.avatar,
        createdAt: row.createdAt,
        lastLogin: row.lastLogin,
      )).toList();
    }
    
    try {
      final querySnapshot = await _firestore.collection(FirestorePaths.users).get();
      final users = querySnapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
      
      // Cache users locally
      for (final user in users) {
        await _db.userDao.upsertUser(
          uid: user.uid,
          email: user.email,
          nickname: user.nickname,
          avatar: user.avatar,
          createdAt: user.createdAt,
          lastLogin: user.lastLogin,
        );
      }
      
      return users;
    } catch (e) {
      print('⚠️ [SharedRepo] Failed to fetch users: $e');
      final localUsers = await _db.userDao.getAllUsers();
      return localUsers.map((row) => AppUser(
        uid: row.uid,
        email: row.email,
        nickname: row.nickname,
        avatar: row.avatar,
        createdAt: row.createdAt,
        lastLogin: row.lastLogin,
      )).toList();
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Future<List<Group>> _fetchGroupsFromFirestore(String userId) async {
    // First try to get groups where user is a member
    // Since Firestore array-contains doesn't work well with nested objects,
    // we'll get groups by ownerId and also query groups we're members of
    
    final List<Group> allGroups = [];
    
    // Get groups user owns
    final ownerQuery = await _firestore
        .collection(FirestorePaths.groups)
        .where('ownerId', isEqualTo: userId)
        .get();
    
    allGroups.addAll(ownerQuery.docs.map((doc) => Group.fromFirestore(doc)));
    
    // Get all groups and filter by membership
    // This is less efficient but more reliable
    final allGroupsQuery = await _firestore.collection(FirestorePaths.groups).get();
    
    for (final doc in allGroupsQuery.docs) {
      final group = Group.fromFirestore(doc);
      
      // Skip if already added (owner)
      if (allGroups.any((g) => g.id == group.id)) continue;
      
      // Check if user is a member
      if (group.members.any((m) => m.userId == userId)) {
        allGroups.add(group);
      }
    }
    
    return allGroups;
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
      members: [],
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}