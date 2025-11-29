import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'cached_event_dao.g.dart';

@DriftAccessor(tables: [CachedEvents])
class CachedEventDao extends DatabaseAccessor<AppDatabase> with _$CachedEventDaoMixin {
  CachedEventDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get cached event by ID
  Future<CachedEventEntity?> getCachedEventById(String eventId) {
    return (select(cachedEvents)..where((t) => t.id.equals(eventId)))
        .getSingleOrNull();
  }

  /// Get all valid (non-expired) cached events
  Future<List<CachedEventEntity>> getValidCachedEvents() {
    final now = DateTime.now();
    return (select(cachedEvents)
          ..where((t) => t.expiresAt.isBiggerThanValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)]))
        .get();
  }

  /// Get all cached events (including expired)
  Future<List<CachedEventEntity>> getAllCachedEvents() {
    return (select(cachedEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)]))
        .get();
  }

  /// Get cached events for date range
  Future<List<CachedEventEntity>> getCachedEventsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final now = DateTime.now();
    return (select(cachedEvents)
          ..where((t) =>
              t.expiresAt.isBiggerThanValue(now) &
              t.startDateTime.isSmallerOrEqualValue(endDate) &
              (t.endDateTime.isBiggerOrEqualValue(startDate) |
                  t.endDateTime.isNull())))
        .get();
  }

  /// Get upcoming cached events
  Future<List<CachedEventEntity>> getUpcomingCachedEvents({int limit = 10}) {
    final now = DateTime.now();
    return (select(cachedEvents)
          ..where((t) =>
              t.expiresAt.isBiggerThanValue(now) &
              t.startDateTime.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.startDateTime)])
          ..limit(limit))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Cache a single event
  Future<void> cacheEvent(CachedEventsCompanion event) {
    return into(cachedEvents).insertOnConflictUpdate(event);
  }

  /// Cache multiple events (batch)
  Future<void> cacheEvents(List<CachedEventsCompanion> events) {
    return batch((b) {
      b.insertAllOnConflictUpdate(cachedEvents, events);
    });
  }

  /// Update cache expiry time for an event
  Future<bool> updateCacheExpiry(String eventId, DateTime newExpiryTime) {
    return (update(cachedEvents)..where((t) => t.id.equals(eventId)))
        .write(CachedEventsCompanion(
      expiresAt: Value(newExpiryTime),
    )).then((rows) => rows > 0);
  }

  // ==================== DELETE ====================

  /// Delete a specific cached event
  Future<int> deleteCachedEvent(String eventId) {
    return (delete(cachedEvents)..where((t) => t.id.equals(eventId))).go();
  }

  /// Delete expired cached events
  Future<int> deleteExpiredEvents() {
    final now = DateTime.now();
    return (delete(cachedEvents)..where((t) => t.expiresAt.isSmallerThanValue(now)))
        .go();
  }

  /// Clear all cached events
  Future<int> clearCache() {
    return delete(cachedEvents).go();
  }

  /// Delete cached events older than specified date
  Future<int> deleteCachedEventsOlderThan(DateTime date) {
    return (delete(cachedEvents)..where((t) => t.cachedAt.isSmallerThanValue(date)))
        .go();
  }

  // ==================== UTILITY ====================

  /// Count total cached events
  Future<int> countCachedEvents() async {
    final result = await (selectOnly(cachedEvents)
          ..addColumns([cachedEvents.id.count()]))
        .getSingle();
    return result.read(cachedEvents.id.count()) ?? 0;
  }

  /// Count valid (non-expired) cached events
  Future<int> countValidCachedEvents() async {
    final now = DateTime.now();
    final result = await (selectOnly(cachedEvents)
          ..where(cachedEvents.expiresAt.isBiggerThanValue(now))
          ..addColumns([cachedEvents.id.count()]))
        .getSingle();
    return result.read(cachedEvents.id.count()) ?? 0;
  }
}
