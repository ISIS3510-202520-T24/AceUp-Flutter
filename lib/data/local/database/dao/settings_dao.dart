import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get settings for user
  Future<SettingsEntity?> getSettingsForUser(String userId) {
    return (select(settings)..where((t) => t.userId.equals(userId))).getSingleOrNull();
  }

  /// Watch settings for user
  Stream<SettingsEntity?> watchSettingsForUser(String userId) {
    return (select(settings)..where((t) => t.userId.equals(userId))).watchSingleOrNull();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update settings
  Future<void> upsertSettings(SettingsCompanion userSettings) {
    return into(settings).insertOnConflictUpdate(userSettings);
  }

  /// Insert settings
  Future<void> insertSettings(SettingsCompanion userSettings) {
    return into(settings).insert(userSettings, mode: InsertMode.insertOrReplace);
  }

  /// Update settings
  Future<bool> updateSettings(SettingsCompanion userSettings) {
    return (update(settings)..where((t) => t.userId.equals(userSettings.userId.value)))
        .write(userSettings)
        .then((rows) => rows > 0);
  }

  /// Update default class duration
  Future<void> updateDefaultClassDuration(String userId, int duration) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        defaultClassDuration: Value(duration),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update weekdays
  Future<void> updateWeekdays(String userId, String weekdaysJson) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        weekdaysJson: Value(weekdaysJson),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update grading scale
  Future<void> updateGradingScale(String userId, String gradingScaleJson) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        gradingScaleJson: Value(gradingScaleJson),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update holiday country
  Future<void> updateHolidayCountry(String userId, String countryCode) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        holidayCountry: Value(countryCode),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String userId, String status) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Create default settings for new user
  Future<void> createDefaultSettings(String userId) {
    return insertSettings(SettingsCompanion(
      userId: Value(userId),
      defaultClassDuration: const Value(60),
      weekdaysJson: const Value('[1,2,3,4,5]'),
      gradingScaleJson: const Value('{"type":"percentage"}'),
      holidayCountry: const Value('CO'),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));
  }

  // ==================== DELETE ====================

  /// Delete settings for user
  Future<int> deleteSettingsForUser(String userId) {
    return (delete(settings)..where((t) => t.userId.equals(userId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get settings that need sync
  Future<List<SettingsEntity>> getSettingsNeedingSync() {
    return (select(settings)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark settings as synced
  Future<void> markAsSynced(String userId) {
    return (update(settings)..where((t) => t.userId.equals(userId))).write(
      SettingsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }
}