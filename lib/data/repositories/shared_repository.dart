// lib/data/repositories/shared_repository.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../local/database/app_database.dart' as db;
import '../../models/group_model.dart' as models;
import '../../models/calendar_event_model.dart' as models;
import '../../models/user_model.dart' as models;

/// Repository that implements offline-first pattern for Shared functionality
/// 
/// Reads from local SQLite first, falls back to Firestore when needed,
/// queues write operations for background sync
class SharedRepository {
  final db.AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;

  SharedRepository({
    required db.AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== GROUPS ====================

  /// Get groups for user (offline-first)
  Future<List<models.Group>> getGroupsForUser(String userId) async {
    // 1. Try local cache first
    final localGroups = await _db.groupDao.getGroupsForUser(userId);
    
    if (localGroups.isNotEmpty) {
      print('📦 Loaded ${localGroups.length} groups from cache');
      return localGroups.map(_groupFromDb).toList();
    }

    // 2. If empty and online, fetch from Firestore
    if (_connectivity.isOnline) {
      print('☁️  Fetching groups from Firestore...');
      try {
        final groups = await _fetchGroupsFromFirestore(userId);
        
        // Cache locally
        for (final group in groups) {
          await _cacheGroup(group);
        }
        
        return groups;
      } catch (e) {
        print('❌ Failed to fetch groups: $e');
        return [];
      }
    }

    // 3. Offline and no cache
    print('📵 Offline - no cached groups');
    return [];
  }

  /// Get single group by ID (offline-first)
  Future<models.Group?> getGroupById(String groupId) async {
    // Try local first
    final localGroup = await _db.groupDao.getGroupById(groupId);
    if (localGroup != null) {
      return _groupFromDb(localGroup);
    }

    // Fetch from Firestore if online
    if (_connectivity.isOnline) {
      try {
        final doc = await _firestore.collection('groups').doc(groupId).get();
        if (doc.exists) {
          final group = models.Group.fromFirestore(doc);
          await _cacheGroup(group);
          return group;
        }
      } catch (e) {
        print('❌ Failed to fetch group: $e');
      }
    }

    return null;
  }

  /// Create new group (queues for sync)
  Future<void> createGroup(models.Group group) async {
    // 1. Save locally immediately
    await _db.groupDao.insertGroup(db.GroupsCompanion.insert(
      id: group.id,
      name: group.name,
      memberUids: group.memberUids.join(','),
      createdBy: '', // Placeholder
      createdAt: DateTime.now(),
    ));

    // 2. Queue for sync
    await _db.syncDao.addToSyncQueue(db.SyncQueueCompanion.insert(
      entityType: 'group',
      entityId: group.id,
      operation: 'create',
      createdAt: DateTime.now(),
      dataJson: Value(jsonEncode({
        'name': group.name,
        'members': group.memberUids,
      })),
    ));

    print('✅ Group created locally, queued for sync');
  }

  /// Update group (queues for sync)
  Future<void> updateGroup(models.Group group) async {
    final dbGroup = await _db.groupDao.getGroupById(group.id);
    if (dbGroup == null) return;

    await _db.groupDao.updateGroup(db.Group(
      id: group.id,
      name: group.name,
      memberUids: group.memberUids.join(','),
      createdBy: dbGroup.createdBy,
      createdAt: dbGroup.createdAt,
      updatedAt: DateTime.now(),
    ));

    await _db.syncDao.addToSyncQueue(db.SyncQueueCompanion.insert(
      entityType: 'group',
      entityId: group.id,
      operation: 'update',
      createdAt: DateTime.now(),
      dataJson: Value(jsonEncode({
        'name': group.name,
        'members': group.memberUids,
      })),
    ));

    print('✅ Group updated locally, queued for sync');
  }

  /// Delete group (queues for sync)
  Future<void> deleteGroup(String groupId) async {
    await _db.groupDao.deleteGroup(groupId);

    await _db.syncDao.addToSyncQueue(db.SyncQueueCompanion.insert(
      entityType: 'group',
      entityId: groupId,
      operation: 'delete',
      createdAt: DateTime.now(),
    ));

    print('✅ Group deleted locally, queued for sync');
  }

  // ==================== GROUP MEMBERS ====================

  /// Get members of a group (offline-first)
  Future<List<models.AppUser>> getGroupMembers(String groupId) async {
    final members = await _db.groupDao.getGroupMembers(groupId);
    
    return members.map((m) => models.AppUser(
      uid: m.userId,
      nick: m.userNick,
      email: m.userEmail,
    )).toList();
  }

  /// Get all users from Firestore (for member selection)
  /// This is not cached as user list needs to be fresh
  Future<List<models.AppUser>> getAllUsers() async {
    if (!_connectivity.isOnline) {
      print('⚠️  Offline - cannot fetch all users');
      return [];
    }

    try {
      print('☁️  Fetching all users from Firestore...');
      final snapshot = await _firestore.collection('users').get();
      
      return snapshot.docs.map((doc) {
        return models.AppUser.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  /// Add member to group (queues for sync)
  Future<void> addMemberToGroup(String groupId, String userId) async {
    await _db.groupDao.addMember(db.GroupMembersCompanion.insert(
      id: '${groupId}_$userId',
      groupId: groupId,
      userId: userId,
      userNick: '', // Will be updated later
      userEmail: '',
      joinedAt: DateTime.now(),
    ));

    await _db.syncDao.addToSyncQueue(db.SyncQueueCompanion.insert(
      entityType: 'group_member',
      entityId: '${groupId}_$userId',
      operation: 'create',
      createdAt: DateTime.now(),
      dataJson: Value(jsonEncode({
        'groupId': groupId,
        'userId': userId,
        'joinedAt': DateTime.now().toIso8601String(),
      })),
    ));

    print('✅ Member added locally, queued for sync');
  }

  // ==================== CALENDAR EVENTS ====================

  /// Get events for user (offline-first)
  Future<List<models.CalendarEvent>> getEventsForUser(String userId) async {
    final events = await _db.eventDao.getEventsForUser(userId);
    return events.map(_eventFromDb).toList();
  }

  /// Get events for group (offline-first)
  Future<List<models.CalendarEvent>> getEventsForGroup(String groupId) async {
    final events = await _db.eventDao.getEventsForGroup(groupId);
    return events.map(_eventFromDb).toList();
  }

  /// Cache group events (from Firestore)
  Future<void> cacheGroupEvents(String groupId, List<models.CalendarEvent> events) async {
    for (final event in events) {
      await _db.eventDao.insertEvent(db.CalendarEventsCompanion.insert(
        id: event.id,
        title: event.title,
        startTime: event.startTime,
        endTime: event.endTime,
        eventType: event.type.toString().split('.').last,
        ownerId: event.ownerId,
        ownerName: event.ownerName,
        colorValue: event.color.value,
        groupId: Value(groupId),
        cachedAt: DateTime.now(),
      ));
    }
  }

  // ==================== FREE BLOCKS ====================

  /// Get cached free blocks for group
  Future<List<Map<String, dynamic>>?> getCachedFreeBlocks(String groupId) async {
    final blocks = await _db.groupDao.getCachedFreeBlocks(groupId);
    
    if (blocks == null) return null;

    return blocks.map((block) => {
      'id': block.id,
      'groupId': block.groupId,
      'weekday': block.weekday,
      'startHour': block.startHour,
      'startMinute': block.startMinute,
      'endHour': block.endHour,
      'endMinute': block.endMinute,
      'freeMembers': block.freeMembers.split(','),
      'calculatedAt': block.calculatedAt,
    }).toList();
  }

  /// Cache free blocks for group
  Future<void> cacheFreeBlocks(String groupId, List<Map<String, dynamic>> blocks) async {
    final companions = blocks.map((block) => db.FreeBlocksCompanion.insert(
      id: block['id'] ?? '${groupId}_${DateTime.now().millisecondsSinceEpoch}',
      groupId: groupId,
      weekday: block['weekday'],
      startHour: block['startHour'],
      startMinute: block['startMinute'],
      endHour: block['endHour'],
      endMinute: block['endMinute'],
      freeMembers: (block['freeMembers'] as List).join(','),
      calculatedAt: DateTime.now(),
    )).toList();

    await _db.groupDao.cacheFreeBlocks(groupId, companions);
  }

  // ==================== HELPERS ====================

  Future<List<models.Group>> _fetchGroupsFromFirestore(String userId) async {
    // Query groups where user is a member
    final snapshot = await _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => models.Group.fromFirestore(doc)).toList();
  }

  Future<void> _cacheGroup(models.Group group) async {
    await _db.groupDao.insertGroup(db.GroupsCompanion.insert(
      id: group.id,
      name: group.name,
      memberUids: group.memberUids.join(','),
      createdBy: '', // Placeholder
      createdAt: DateTime.now(),
    ));
  }

  models.Group _groupFromDb(db.Group dbGroup) {
    return models.Group(
      id: dbGroup.id,
      name: dbGroup.name,
      memberUids: dbGroup.memberUids.split(','),
    );
  }

  models.CalendarEvent _eventFromDb(db.CalendarEvent dbEvent) {
    return models.CalendarEvent(
      id: dbEvent.id,
      title: dbEvent.title,
      startTime: dbEvent.startTime,
      endTime: dbEvent.endTime,
      type: _parseEventType(dbEvent.eventType),
      ownerId: dbEvent.ownerId,
      ownerName: dbEvent.ownerName,
      color: Color(dbEvent.colorValue),
    );
  }

  models.EventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return models.EventType.assignment;
      case 'exam':
        return models.EventType.exam;
      case 'classsession':
        return models.EventType.classSession;
      case 'group':
        return models.EventType.group;
      case 'personal':
        return models.EventType.personal;
      default:
        return models.EventType.personal;
    }
  }

  // ==================== FREE BLOCKS CALCULATION ====================

  /// Calculate free blocks for group (static utility method)
  /// Returns time slots where ALL members are free
  static List<Map<String, dynamic>> calculateGroupFreeBlocks({
    required Map<String, List<models.CalendarEvent>> memberEvents,
    int intervalMinutes = 30,
    List<int> weekdays = const [1, 2, 3, 4, 5], // Mon-Fri
    int startHour = 6,
    int endHour = 21,
  }) {
    List<Map<String, dynamic>> result = [];
    
    for (int weekday in weekdays) {
      for (int hour = startHour; hour < endHour; hour++) {
        for (int min = 0; min < 60; min += intervalMinutes) {
          final blockStart = TimeOfDay(hour: hour, minute: min);
          int endMin = min + intervalMinutes;
          int endHourAdjusted = hour;
          if (endMin >= 60) {
            endMin = 0;
            endHourAdjusted++;
          }
          final blockEnd = TimeOfDay(hour: endHourAdjusted, minute: endMin);
          
          List<String> freeMembers = [];
          
          memberEvents.forEach((member, events) {
            // Check if member has any event that overlaps with this block
            final isBusy = events.any((e) {
              if (e.startTime.weekday != weekday) return false;
              final eventStart = TimeOfDay(hour: e.startTime.hour, minute: e.startTime.minute);
              final eventEnd = TimeOfDay(hour: e.endTime.hour, minute: e.endTime.minute);
              return _overlaps(blockStart, blockEnd, eventStart, eventEnd);
            });
            
            if (!isBusy) freeMembers.add(member);
          });
          
          result.add({
            'weekday': weekday,
            'startHour': blockStart.hour,
            'startMinute': blockStart.minute,
            'endHour': blockEnd.hour,
            'endMinute': blockEnd.minute,
            'freeMembers': freeMembers.join(','),
          });
        }
      }
    }
    
    return result;
  }

  /// Check if two time ranges overlap
  static bool _overlaps(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final s1 = start1.hour * 60 + start1.minute;
    final e1 = end1.hour * 60 + end1.minute;
    final s2 = start2.hour * 60 + start2.minute;
    final e2 = end2.hour * 60 + end2.minute;
    return s1 < e2 && s2 < e1;
  }
}
