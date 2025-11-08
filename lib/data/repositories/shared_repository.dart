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

  /// Get groups for user (network-first with cache fallback)
  Future<List<models.Group>> getGroupsForUser(String userId) async {
    // 1. If online, fetch from Firestore (ALWAYS get fresh data)
    if (_connectivity.isOnline) {
      print('☁️  Fetching fresh groups from Firestore...');
      try {
        final groups = await _fetchGroupsFromFirestore(userId);
        
        // Cache locally for offline access
        for (final group in groups) {
          await _cacheGroup(group);
        }
        
        print('✅ Loaded ${groups.length} groups from Firestore (cached for offline)');
        return groups;
      } catch (e) {
        print('⚠️  Failed to fetch from Firestore: $e');
        print('📦 Falling back to cache...');
        // Fall through to cache
      }
    } else {
      print('📵 Offline - using cache');
    }

    // 2. Fallback to local cache (offline or network error)
    final localGroups = await _db.groupDao.getGroupsForUser(userId);
    
    if (localGroups.isNotEmpty) {
      print('� Loaded ${localGroups.length} groups from cache');
      return localGroups.map(_groupFromDb).toList();
    }

    // 3. No cache and no network
    print('❌ No cached groups and offline');
    return [];
  }

  /// Get single group by ID (network-first with cache fallback)
  Future<models.Group?> getGroupById(String groupId) async {
    // If online, fetch from Firestore first (ALWAYS get fresh data)
    if (_connectivity.isOnline) {
      try {
        print('☁️  Fetching group $groupId from Firestore...');
        final doc = await _firestore.collection('groups').doc(groupId).get();
        if (doc.exists) {
          final group = models.Group.fromFirestore(doc);
          await _cacheGroup(group);
          print('✅ Loaded group from Firestore (cached for offline)');
          return group;
        }
      } catch (e) {
        print('⚠️  Failed to fetch from Firestore: $e');
        print('📦 Falling back to cache...');
        // Fall through to cache
      }
    } else {
      print('📵 Offline - using cache for group $groupId');
    }

    // Fallback to local cache (offline or network error)
    final localGroup = await _db.groupDao.getGroupById(groupId);
    if (localGroup != null) {
      print('📦 Loaded group from cache');
      return _groupFromDb(localGroup);
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

    // 2. Insert group members into GroupMembers table
    for (final uid in group.memberUids) {
      try {
        String nick = 'User';
        String email = '';
        
        // First, try to get from cache
        final cachedUser = await _db.userDao.getCachedUser(uid);
        if (cachedUser != null) {
          nick = cachedUser.nick;
          email = cachedUser.email;
        } else if (_connectivity.isOnline) {
          // If not cached and online, fetch from Firestore
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            nick = userData?['nick'] ?? 'User';
            email = userData?['email'] ?? '';
            
            // Cache the user for future use
            await _db.userDao.cacheUser(db.CachedUsersCompanion.insert(
              uid: uid,
              nick: nick,
              email: email,
              cachedAt: DateTime.now(),
            ));
          }
        }

        await _db.groupDao.addMember(db.GroupMembersCompanion.insert(
          id: '${group.id}_$uid',
          groupId: group.id,
          userId: uid,
          userNick: nick,
          userEmail: email,
          joinedAt: DateTime.now(),
        ));
      } catch (e) {
        print('⚠️  Failed to add member $uid: $e');
      }
    }

    // 3. Queue for sync
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

    // Update group members: remove old ones and add new ones
    await _db.groupDao.removeAllMembers(group.id);
    
    for (final uid in group.memberUids) {
      try {
        String nick = 'User';
        String email = '';
        
        // First, try to get from cache
        final cachedUser = await _db.userDao.getCachedUser(uid);
        if (cachedUser != null) {
          nick = cachedUser.nick;
          email = cachedUser.email;
        } else if (_connectivity.isOnline) {
          // If not cached and online, fetch from Firestore
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            nick = userData?['nick'] ?? 'User';
            email = userData?['email'] ?? '';
            
            // Cache the user for future use
            await _db.userDao.cacheUser(db.CachedUsersCompanion.insert(
              uid: uid,
              nick: nick,
              email: email,
              cachedAt: DateTime.now(),
            ));
          }
        }

        await _db.groupDao.addMember(db.GroupMembersCompanion.insert(
          id: '${group.id}_$uid',
          groupId: group.id,
          userId: uid,
          userNick: nick,
          userEmail: email,
          joinedAt: DateTime.now(),
        ));
      } catch (e) {
        print('⚠️  Failed to update member $uid: $e');
      }
    }

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
  /// Users are cached for offline access
  Future<List<models.AppUser>> getAllUsers() async {
    if (!_connectivity.isOnline) {
      print('⚠️  Offline - cannot fetch all users');
      return [];
    }

    try {
      print('☁️  Fetching all users from Firestore...');
      final snapshot = await _firestore.collection('users').get();
      
      final users = snapshot.docs.map((doc) {
        return models.AppUser.fromFirestore(doc);
      }).toList();
      
      // Cache all users for offline access
      final userCompanions = users.map((user) => db.CachedUsersCompanion.insert(
        uid: user.uid,
        nick: user.nick,
        email: user.email,
        cachedAt: DateTime.now(),
      )).toList();
      
      await _db.userDao.cacheUsersBatch(userCompanions);
      print('📦 Cached ${users.length} users for offline access');
      
      return users;
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
  /// Generates recurring events from class schedules
  Future<List<models.CalendarEvent>> getEventsForGroup(String groupId) async {
    // Get all members of the group
    final members = await getGroupMembers(groupId);
    
    // 1. Try to load classes from local cache
    final allClasses = <db.ClassTemplate>[];
    bool hasCachedData = false;
    
    for (final member in members) {
      final userClasses = await _db.memberScheduleDao.getUserClasses(member.uid);
      if (userClasses.isNotEmpty) {
        allClasses.addAll(userClasses);
        hasCachedData = true;
      }
    }

    // 2. If no cached data and online, fetch from Firestore
    if (!hasCachedData && _connectivity.isOnline) {
      print('☁️  Fetching class schedules for group $groupId from Firestore...');
      await _fetchAndCacheGroupSchedules(members);
      
      // Reload from cache after fetching
      allClasses.clear();
      for (final member in members) {
        final userClasses = await _db.memberScheduleDao.getUserClasses(member.uid);
        allClasses.addAll(userClasses);
      }
    }

    // 3. Convert class templates to recurring events for current week
    final events = _generateEventsFromClasses(allClasses, members);
    
    print('📦 Generated ${events.length} recurring events from ${allClasses.length} class templates');
    return events;
  }

  /// Fetch class schedules from Firestore and cache them
  Future<void> _fetchAndCacheGroupSchedules(List<models.AppUser> members) async {
    for (final member in members) {
      try {
        // Fetch terms
        final termsSnapshot = await _firestore
            .collection('users')
            .doc(member.uid)
            .collection('terms')
            .get();

        for (final termDoc in termsSnapshot.docs) {
          final termData = termDoc.data();
          
          // Cache term
          await _db.memberScheduleDao.cacheUserTerms(member.uid, [
            db.TermsCompanion.insert(
              id: termDoc.id,
              userId: member.uid,
              name: termData['name'] ?? 'Term',
              startDate: Value(termData['startDate'] != null 
                  ? (termData['startDate'] as Timestamp).toDate() 
                  : null),
              endDate: Value(termData['endDate'] != null 
                  ? (termData['endDate'] as Timestamp).toDate() 
                  : null),
            ),
          ]);

          // Fetch subjects for this term
          final subjectsSnapshot = await _firestore
              .collection('users')
              .doc(member.uid)
              .collection('terms')
              .doc(termDoc.id)
              .collection('subjects')
              .get();

          for (final subjectDoc in subjectsSnapshot.docs) {
            final subjectData = subjectDoc.data();
            
            // Cache subject
            await _db.memberScheduleDao.cacheTermSubjects(termDoc.id, [
              db.SubjectsCompanion.insert(
                id: subjectDoc.id,
                termId: termDoc.id,
                userId: member.uid,
                name: subjectData['name'] ?? 'Subject',
                code: Value(subjectData['code']),
              ),
            ]);

            // Fetch classes for this subject
            final classesSnapshot = await _firestore
                .collection('users')
                .doc(member.uid)
                .collection('terms')
                .doc(termDoc.id)
                .collection('subjects')
                .doc(subjectDoc.id)
                .collection('classes')
                .get();

            final classesList = <db.ClassTemplatesCompanion>[];
            for (final classDoc in classesSnapshot.docs) {
              final classData = classDoc.data();
              classesList.add(db.ClassTemplatesCompanion.insert(
                id: classDoc.id,
                subjectId: subjectDoc.id,
                userId: member.uid,
                dayOfWeek: classData['dayOfWeek'] ?? 1,
                startTime: classData['startTime'] ?? '08:00',
                endTime: classData['endTime'] ?? '09:00',
                location: Value(classData['location']),
              ));
            }

            if (classesList.isNotEmpty) {
              await _db.memberScheduleDao.cacheSubjectClasses(subjectDoc.id, classesList);
            }
          }
        }
        
        print('✅ Cached schedule for ${member.nick}');
      } catch (e) {
        print('⚠️  Failed to fetch schedule for ${member.nick}: $e');
      }
    }
  }

  /// Generate recurring events from class templates for the current/next week
  List<models.CalendarEvent> _generateEventsFromClasses(
    List<db.ClassTemplate> classes,
    List<models.AppUser> members,
  ) {
    final events = <models.CalendarEvent>[];
    final now = DateTime.now();
    
    // Get the start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    for (final classTemplate in classes) {
      // Find the owner
      final owner = members.firstWhere(
        (m) => m.uid == classTemplate.userId,
        orElse: () => models.AppUser(uid: classTemplate.userId, nick: 'User', email: ''),
      );

      // dayOfWeek: 1=Monday, 7=Sunday
      final classDay = weekDates[classTemplate.dayOfWeek - 1];
      
      // Parse start and end times
      final startTimeParts = classTemplate.startTime.split(':');
      final endTimeParts = classTemplate.endTime.split(':');
      
      final startTime = DateTime(
        classDay.year,
        classDay.month,
        classDay.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
      );
      
      final endTime = DateTime(
        classDay.year,
        classDay.month,
        classDay.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
      );

      events.add(models.CalendarEvent(
        id: '${classTemplate.id}_${classDay.millisecondsSinceEpoch}',
        title: 'Class', // Could fetch subject name if needed
        startTime: startTime,
        endTime: endTime,
        type: models.EventType.classSession,
        ownerId: owner.uid,
        ownerName: owner.nick,
        color: Colors.blue, // Could vary by subject
      ));
    }

    return events;
  }

  models.EventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
        return models.EventType.assignment;
      case 'exam':
        return models.EventType.exam;
      case 'class':
      case 'classsession':
        return models.EventType.classSession;
      case 'group':
        return models.EventType.group;
      default:
        return models.EventType.personal;
    }
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
      // freeMembers is already a String in DB (comma-separated), split it to List
      'freeMembers': block.freeMembers.split(',').where((s) => s.isNotEmpty).toList(),
      'calculatedAt': block.calculatedAt,
    }).toList();
  }

  /// Cache free blocks for group
  Future<void> cacheFreeBlocks(String groupId, List<Map<String, dynamic>> blocks) async {
    int index = 0;
    final companions = blocks.map((block) {
      // Handle both List and String formats for freeMembers
      final freeMembersData = block['freeMembers'];
      final String freeMembersStr = freeMembersData is List
          ? freeMembersData.map((e) => e.toString()).join(',')
          : freeMembersData.toString();
      
      // Generate unique ID for each block using index to avoid duplicates
      final uniqueId = block['id'] ?? '${groupId}_${block['weekday']}_${block['startHour']}_${block['startMinute']}_${index++}';
      
      return db.FreeBlocksCompanion.insert(
        id: uniqueId,
        groupId: groupId,
        weekday: block['weekday'],
        startHour: block['startHour'],
        startMinute: block['startMinute'],
        endHour: block['endHour'],
        endMinute: block['endMinute'],
        freeMembers: freeMembersStr,
        calculatedAt: DateTime.now(),
      );
    }).toList();

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
    // 1. Insert/update the group itself
    await _db.groupDao.insertGroup(db.GroupsCompanion.insert(
      id: group.id,
      name: group.name,
      memberUids: group.memberUids.join(','),
      createdBy: '', // Placeholder
      createdAt: DateTime.now(),
    ));

    // 2. Cache group members in GroupMembers table
    // First, get user details for each member UID
    for (final uid in group.memberUids) {
      try {
        String nick = 'User';
        String email = '';
        
        // First, try to get from cache
        final cachedUser = await _db.userDao.getCachedUser(uid);
        if (cachedUser != null) {
          nick = cachedUser.nick;
          email = cachedUser.email;
        } else if (_connectivity.isOnline) {
          // If not cached and online, fetch from Firestore
          final userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            nick = userData?['nick'] ?? 'User';
            email = userData?['email'] ?? '';
            
            // Cache the user for future use
            await _db.userDao.cacheUser(db.CachedUsersCompanion.insert(
              uid: uid,
              nick: nick,
              email: email,
              cachedAt: DateTime.now(),
            ));
          }
        }

        // Insert member into GroupMembers table
        await _db.groupDao.addMember(db.GroupMembersCompanion.insert(
          id: '${group.id}_$uid',
          groupId: group.id,
          userId: uid,
          userNick: nick,
          userEmail: email,
          joinedAt: DateTime.now(),
        ));
      } catch (e) {
        print('⚠️  Failed to cache member $uid: $e');
      }
    }
  }

  models.Group _groupFromDb(db.Group dbGroup) {
    // Handle empty or malformed member_uids field
    final memberUids = dbGroup.memberUids.isEmpty 
        ? <String>[]
        : dbGroup.memberUids.split(',').where((s) => s.isNotEmpty).toList();
    
    return models.Group(
      id: dbGroup.id,
      name: dbGroup.name,
      memberUids: memberUids,
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
