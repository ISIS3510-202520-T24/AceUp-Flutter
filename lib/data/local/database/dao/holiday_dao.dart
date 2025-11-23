import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'holiday_dao.g.dart';

@DriftAccessor(tables: [Holidays])
class HolidayDao extends DatabaseAccessor<AppDatabase> with _$HolidayDaoMixin {
  HolidayDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get holiday by ID
  Future<HolidayEntity?> getHolidayById(String id) {
    return (select(holidays)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch holiday by ID
  Stream<HolidayEntity?> watchHolidayById(String id) {
    return (select(holidays)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all holidays for user
  Future<List<HolidayEntity>> getHolidaysForUser(String userId) {
    return (select(holidays)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// Watch all holidays for user
  Stream<List<HolidayEntity>> watchHolidaysForUser(String userId) {
    return (select(holidays)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .watch();
  }

  /// Get user-created holidays
  Future<List<HolidayEntity>> getUserCreatedHolidays(String userId) {
    return (select(holidays)
          ..where((t) => t.userId.equals(userId) & t.source.equals('user'))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// Get API-fetched holidays
  Future<List<HolidayEntity>> getApiHolidays(String userId) {
    return (select(holidays)
          ..where((t) => t.userId.equals(userId) & t.source.equals('api'))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// Get holidays for date range
  Future<List<HolidayEntity>> getHolidaysForDateRange(
      String userId, DateTime startDate, DateTime endDate) {
    return (select(holidays)
          ..where((t) =>
              t.userId.equals(userId) &
              t.startDate.isSmallerOrEqualValue(endDate) &
              t.endDate.isBiggerOrEqualValue(startDate))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// Get holidays for specific date
  Future<List<HolidayEntity>> getHolidaysForDate(String userId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (select(holidays)
          ..where((t) =>
              t.userId.equals(userId) &
              t.startDate.isSmallerOrEqualValue(dateOnly) &
              t.endDate.isBiggerOrEqualValue(dateOnly)))
        .get();
  }

  /// Check if date is a holiday
  Future<bool> isHoliday(String userId, DateTime date) async {
    final holidaysOnDate = await getHolidaysForDate(userId, date);
    return holidaysOnDate.isNotEmpty;
  }

  /// Get upcoming holidays
  Future<List<HolidayEntity>> getUpcomingHolidays(String userId, {int limit = 5}) {
    final now = DateTime.now();
    return (select(holidays)
          ..where((t) => t.userId.equals(userId) & t.startDate.isBiggerOrEqualValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)])
          ..limit(limit))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update holiday
  Future<void> upsertHoliday(HolidaysCompanion holiday) {
    return into(holidays).insertOnConflictUpdate(holiday);
  }

  /// Insert holiday
  Future<void> insertHoliday(HolidaysCompanion holiday) {
    return into(holidays).insert(holiday, mode: InsertMode.insertOrReplace);
  }

  /// Update holiday
  Future<bool> updateHoliday(HolidaysCompanion holiday) {
    return (update(holidays)..where((t) => t.id.equals(holiday.id.value)))
        .write(holiday)
        .then((rows) => rows > 0);
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(holidays)..where((t) => t.id.equals(id))).write(
      HolidaysCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete holiday by ID
  Future<int> deleteHoliday(String id) {
    return (delete(holidays)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all holidays for user
  Future<int> deleteHolidaysForUser(String userId) {
    return (delete(holidays)..where((t) => t.userId.equals(userId))).go();
  }

  /// Delete API holidays for user (for refresh)
  Future<int> deleteApiHolidaysForUser(String userId) {
    return (delete(holidays)
          ..where((t) => t.userId.equals(userId) & t.source.equals('api')))
        .go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get holidays that need sync (only user-created)
  Future<List<HolidayEntity>> getHolidaysNeedingSync() {
    return (select(holidays)
          ..where((t) => t.syncStatus.equals('pending') & t.source.equals('user')))
        .get();
  }

  /// Mark holiday as synced
  Future<void> markAsSynced(String id) {
    return (update(holidays)..where((t) => t.id.equals(id))).write(
      HolidaysCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple holidays (batch) - used for API holidays
  Future<void> insertHolidaysBatch(List<HolidaysCompanion> holidaysList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(holidays, holidaysList);
    });
  }

  /// Replace API holidays (delete old, insert new)
  Future<void> replaceApiHolidays(String userId, List<HolidaysCompanion> newHolidays) async {
    await transaction(() async {
      await deleteApiHolidaysForUser(userId);
      await insertHolidaysBatch(newHolidays);
    });
  }
}