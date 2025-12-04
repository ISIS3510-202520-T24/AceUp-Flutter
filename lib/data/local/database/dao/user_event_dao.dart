import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'user_event_dao.g.dart';

@DriftAccessor(tables: [UserEvents])
class UserEventDao extends DatabaseAccessor<AppDatabase> with _$UserEventDaoMixin {
  UserEventDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get user event by ID
  Future<UserEventEntity?> getUserEventById(String eventId, String userId) {
    return (select(userEvents)
          ..where((t) => t.id.equals(eventId) & t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Get all user events
  Future<List<UserEventEntity>> getUserEvents(String userId) {
    return (select(userEvents)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)]))
        .get();
  }

  /// Watch user events (stream)
  Stream<List<UserEventEntity>> watchUserEvents(String userId) {
    return (select(userEvents)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)]))
        .watch();
  }

  /// Check if event is in user's calendar
  Future<bool> isEventInCalendar(String eventId, String userId) async {
    final event = await getUserEventById(eventId, userId);
    return event != null;
  }

  /// Get events for date range
  Future<List<UserEventEntity>> getUserEventsForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(userEvents)
          ..where((t) =>
              t.userId.equals(userId) &
              t.startDateTime.isSmallerOrEqualValue(endDate) &
              (t.endDateTime.isBiggerOrEqualValue(startDate) |
                  t.endDateTime.isNull())))
        .get();
  }

  /// Get upcoming user events
  Future<List<UserEventEntity>> getUpcomingUserEvents(
    String userId, {
    int limit = 10,
  }) {
    final now = DateTime.now();
    return (select(userEvents)
          ..where((t) => t.userId.equals(userId) & t.startDateTime.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)])
          ..limit(limit))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update user event
  Future<void> upsertUserEvent(UserEventsCompanion event) {
    return into(userEvents).insertOnConflictUpdate(event);
  }

  /// Update user event customizations
  Future<bool> updateUserEventCustomizations(
    String eventId,
    String userId, {
    String? userNotes,
    String? userLocation,
  }) {
    return (update(userEvents)
          ..where((t) => t.id.equals(eventId) & t.userId.equals(userId)))
        .write(UserEventsCompanion(
      userNotes: Value(userNotes),
      userLocation: Value(userLocation),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    )).then((rows) => rows > 0);
  }

  /// Update sync status
  Future<void> updateSyncStatus(String eventId, String userId, String status) {
    return (update(userEvents)
          ..where((t) => t.id.equals(eventId) & t.userId.equals(userId)))
        .write(UserEventsCompanion(
      syncStatus: Value(status),
      lastSyncedAt: Value(DateTime.now()),
    ));
  }

  // ==================== DELETE ====================

  /// Delete user event
  Future<int> deleteUserEvent(String eventId, String userId) {
    return (delete(userEvents)
          ..where((t) => t.id.equals(eventId) & t.userId.equals(userId)))
        .go();
  }

  /// Delete all user events
  Future<int> deleteAllUserEvents(String userId) {
    return (delete(userEvents)..where((t) => t.userId.equals(userId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get events that need sync
  Future<List<UserEventEntity>> getPendingSync() {
    return (select(userEvents)..where((t) => t.syncStatus.equals('pending')))
        .get();
  }

  /// Get events that need sync for specific user
  Future<List<UserEventEntity>> getUserEventsPendingSync(String userId) {
    return (select(userEvents)
          ..where((t) =>
              t.userId.equals(userId) & t.syncStatus.equals('pending')))
        .get();
  }

  /// Mark event as synced
  Future<void> markAsSynced(String eventId, String userId) {
    return updateSyncStatus(eventId, userId, 'synced');
  }
}
