import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart'; // ignore: uri_does_not_exist
import '../../models/uni_events/university_event_model.dart';
import '../local/database/app_database.dart';

/// Repository for university events with offline-first pattern
/// Manages both user-added events and cached events for offline viewing
class EventRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  EventRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== USER EVENTS (Added to Calendar) ====================

  /// Get all user events from local database
  Future<List<UniversityEvent>> getUserEvents(String userId) async {
    final entities = await _db.userEventDao.getUserEvents(userId);
    return entities.map(_userEventEntityToModel).toList();
  }

  /// Watch user events (stream)
  Stream<List<UniversityEvent>> watchUserEvents(String userId) {
    return _db.userEventDao.watchUserEvents(userId).map(
          (entities) => entities.map(_userEventEntityToModel).toList(),
        );
  }

  /// Check if event is in user's calendar
  Future<bool> isEventInCalendar(String eventId, String userId) {
    return _db.userEventDao.isEventInCalendar(eventId, userId);
  }

  /// Add event to user's calendar
  Future<void> addEventToCalendar(
    UniversityEvent event,
    String userId, {
    String? userNotes,
    String? userLocation,
  }) async {
    final companion = UserEventsCompanion(
      id: Value(event.id), //ignore: undefined_method
      userId: Value(userId), //ignore: undefined_method
      title: Value(event.title), //ignore: undefined_method
      description: Value(event.description), //ignore: undefined_method
      startDateTime: Value(event.startDateTime), //ignore: undefined_method
      endDateTime: Value(event.endDateTime), //ignore: undefined_method
      location: Value(event.location), //ignore: undefined_method
      imageUrl: Value(event.imageUrl), //ignore: undefined_method
      eventUrl: Value(event.eventUrl), //ignore: undefined_method
      category: Value(event.category), //ignore: undefined_method
      userNotes: Value(userNotes), //ignore: undefined_method
      userLocation: Value(userLocation), //ignore: undefined_method
      addedAt: Value(DateTime.now()), //ignore: undefined_method
      createdAt: Value(DateTime.now()), //ignore: undefined_method
      updatedAt: Value(DateTime.now()), //ignore: undefined_method
      syncStatus: const Value('pending'),  //ignore: creation_with_non_type
      lastSyncedAt: Value(DateTime.now()), //ignore: undefined_method
    );

    await _db.userEventDao.upsertUserEvent(companion);

    // Queue Firebase sync
    await _queueSync(
      entityType: 'user_event',
      entityId: event.id,
      operation: 'create',
      data: _userEventToFirebaseData(event, userId, 
        userNotes: userNotes,
        userLocation: userLocation,
      ),
      documentPath: 'users/$userId/calendar_events/${event.id}',
    );
  }

  /// Remove event from user's calendar
  Future<void> removeEventFromCalendar(String eventId, String userId) async {
    await _db.userEventDao.deleteUserEvent(eventId, userId);

    // Queue Firebase deletion
    await _queueSync(
      entityType: 'user_event',
      entityId: eventId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/calendar_events/$eventId',
    );
  }

  /// Update user event customizations
  Future<void> updateUserEvent(
    String eventId,
    String userId, {
    String? userNotes,
    String? userLocation,
  }) async {
    final companion = UserEventsCompanion(
      id: Value(eventId), //ignore: undefined_method
      userId: Value(userId), //ignore: undefined_method
      userNotes: Value(userNotes), //ignore: undefined_method
      userLocation: Value(userLocation), //ignore: undefined_method
      updatedAt: Value(DateTime.now()), //ignore: undefined_method
      syncStatus: const Value('pending'), //ignore: creation_with_non_type
    );

    await _db.userEventDao.upsertUserEvent(companion);

    // Queue Firebase update
    final event = await _db.userEventDao.getUserEventById(eventId, userId);
    if (event != null) {
      await _queueSync(
        entityType: 'user_event',
        entityId: eventId,
        operation: 'update',
        data: {
          'userNotes': userNotes,
          'userLocation': userLocation,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        documentPath: 'users/$userId/calendar_events/$eventId',
      );
    }
  }

  // ==================== CACHED EVENTS (For Offline Viewing) ====================

  /// Get all valid cached events
  Future<List<UniversityEvent>> getCachedEvents() async {
    final entities = await _db.cachedEventDao.getValidCachedEvents();
    return entities.map(_cachedEventEntityToModel).toList();
  }

  /// Cache events for offline viewing
  /// Typically called after fetching from network
  Future<void> cacheEvents(List<UniversityEvent> events) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));

    final companions = events.map((event) => CachedEventsCompanion(
      id: Value(event.id), //ignore: undefined_method
      title: Value(event.title), //ignore: undefined_method
      description: Value(event.description), //ignore: undefined_method
      startDateTime: Value(event.startDateTime), //ignore: undefined_method
      endDateTime: Value(event.endDateTime), //ignore: undefined_method
      location: Value(event.location), //ignore: undefined_method
      imageUrl: Value(event.imageUrl), //ignore: undefined_method
      eventUrl: Value(event.eventUrl), //ignore: undefined_method
      category: Value(event.category), //ignore: undefined_method
      cachedAt: Value(now), //ignore: undefined_method
      expiresAt: Value(expiresAt), //ignore: undefined_method
    )).toList();

    await _db.cachedEventDao.cacheEvents(companions);
  }

  /// Clean up expired cached events
  Future<void> cleanupExpiredCache() async {
    await _db.cachedEventDao.deleteExpiredEvents();
  }

  /// Clear all cached events
  Future<void> clearCache() async {
    await _db.cachedEventDao.clearCache();
  }

  // ==================== MERGE OPERATIONS ====================

  /// Merge fetched events with user events
  /// Returns combined list with user customizations applied
  Future<List<UniversityEvent>> mergeEventsWithUserData(
    List<UniversityEvent> fetchedEvents,
    String userId,
  ) async {
    final userEvents = await getUserEvents(userId);
    final userEventMap = {for (var e in userEvents) e.id: e};

    return fetchedEvents.map((fetchedEvent) {
      final userEvent = userEventMap[fetchedEvent.id];
      if (userEvent != null) {
        // User has this event in calendar - merge data
        return fetchedEvent.copyWith(
          isAddedToCalendar: true,
          userNotes: userEvent.userNotes,
          userLocation: userEvent.userLocation,
          addedAt: userEvent.addedAt,
        );
      }
      return fetchedEvent;
    }).toList();
  }

  /// Get events for offline use (cached + user events)
  Future<List<UniversityEvent>> getOfflineEvents(String userId) async {
    final cached = await getCachedEvents();
    final merged = await mergeEventsWithUserData(cached, userId);
    return merged;
  }

  // ==================== FIREBASE SYNC ====================

  /// Sync user events from Firebase (initial load)
  Future<void> syncFromFirebase(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users/$userId/calendar_events')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final companion = _firebaseDataToUserEventCompanion(data, userId);
        await _db.userEventDao.upsertUserEvent(companion);
      }
    } catch (e) {
      print('Error syncing user events from Firebase: $e');
    }
  }

  /// Sync pending changes to Firebase
  Future<void> syncPendingToFirebase(String userId) async {
    final pending = await _db.userEventDao.getPendingSync();

    for (var event in pending) {
      try {
        final docPath = 'users/$userId/calendar_events/${event.id}';
        final data = _userEventEntityToFirebaseData(event);

        await _firestore.doc(docPath).set(data, SetOptions(merge: true));
        
        await _db.userEventDao.updateSyncStatus(event.id, userId, 'synced');
      } catch (e) {
        print('Error syncing event ${event.id}: $e');
      }
    }
  }

  // ==================== CONVERTERS ====================

  /// Convert user event entity to model
  UniversityEvent _userEventEntityToModel(UserEventEntity entity) {
    return UniversityEvent(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      location: entity.location,
      imageUrl: entity.imageUrl,
      eventUrl: entity.eventUrl,
      category: entity.category,
      isAddedToCalendar: true,
      userNotes: entity.userNotes,
      userLocation: entity.userLocation,
      addedAt: entity.addedAt,
    );
  }

  /// Convert cached event entity to model
  UniversityEvent _cachedEventEntityToModel(CachedEventEntity entity) {
    return UniversityEvent(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      location: entity.location,
      imageUrl: entity.imageUrl,
      eventUrl: entity.eventUrl,
      category: entity.category,
      cachedAt: entity.cachedAt,
    );
  }

  /// Convert user event to Firebase data
  Map<String, dynamic> _userEventToFirebaseData(
    UniversityEvent event,
    String userId, {
    String? userNotes,
    String? userLocation,
  }) {
    return {
      'id': event.id,
      'userId': userId,
      'title': event.title,
      'description': event.description,
      'startDateTime': event.startDateTime.toIso8601String(),
      'endDateTime': event.endDateTime?.toIso8601String(),
      'location': event.location,
      'imageUrl': event.imageUrl,
      'eventUrl': event.eventUrl,
      'category': event.category,
      'userNotes': userNotes,
      'userLocation': userLocation,
      'addedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Convert user event entity to Firebase data
  Map<String, dynamic> _userEventEntityToFirebaseData(UserEventEntity entity) {
    return {
      'id': entity.id,
      'userId': entity.userId,
      'title': entity.title,
      'description': entity.description,
      'startDateTime': entity.startDateTime.toIso8601String(),
      'endDateTime': entity.endDateTime?.toIso8601String(),
      'location': entity.location,
      'imageUrl': entity.imageUrl,
      'eventUrl': entity.eventUrl,
      'category': entity.category,
      'userNotes': entity.userNotes,
      'userLocation': entity.userLocation,
      'addedAt': entity.addedAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

  /// Convert Firebase data to user event companion
  UserEventsCompanion _firebaseDataToUserEventCompanion(
    Map<String, dynamic> data,
    String userId,
  ) {
    return UserEventsCompanion(
      id: Value(data['id'] as String), //ignore: undefined_method
      userId: Value(userId), //ignore: undefined_method
      title: Value(data['title'] as String), //ignore: undefined_method
      description: Value(data['description'] as String), //ignore: undefined_method
      startDateTime: Value(DateTime.parse(data['startDateTime'] as String)), //ignore: undefined_method
      endDateTime: data['endDateTime'] != null
          ? Value(DateTime.parse(data['endDateTime'] as String)) //ignore: undefined_method
          : const Value(null), //ignore: creation_with_non_type
      location: Value(data['location'] as String?), //ignore: undefined_method
      imageUrl: Value(data['imageUrl'] as String?), //ignore: undefined_method
      eventUrl: Value(data['eventUrl'] as String?), //ignore: undefined_method
      category: Value(data['category'] as String?), //ignore: undefined_method
      userNotes: Value(data['userNotes'] as String?), //ignore: undefined_method
      userLocation: Value(data['userLocation'] as String?), //ignore: undefined_method
      addedAt: Value(DateTime.parse(data['addedAt'] as String)), //ignore: undefined_method
      createdAt: Value(DateTime.parse(data['updatedAt'] as String)), //ignore: undefined_method
      updatedAt: Value(DateTime.parse(data['updatedAt'] as String)), //ignore: undefined_method
      syncStatus: const Value('synced'), //ignore: creation_with_non_type
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