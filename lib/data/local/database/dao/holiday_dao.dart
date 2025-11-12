import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/academic_tables.dart';

part 'holiday_dao.g.dart';

@DriftAccessor(tables: [Holidays])
class HolidayDao extends DatabaseAccessor<AppDatabase> with _$HolidayDaoMixin {
  HolidayDao(AppDatabase db) : super(db);

  // ==================== CREATE ====================

  /// Crear o actualizar holiday
  Future<void> upsertHoliday(HolidaysCompanion holiday) async {
    await into(holidays).insert(
      holiday,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update holidays
  Future<void> upsertHolidaysBatch(List<HolidaysCompanion> holidaysList) async {
    await batch((batch) {
      batch.insertAll(
        holidays,
        holidaysList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== READ ====================

  /// Obtener holiday por ID
  Future<Holiday?> getHolidayById(String id) async {
    return await (select(holidays)
      ..where((h) => h.id.equals(id) & h.isDeleted.equals(false))
    ).getSingleOrNull();
  }

  /// Obtener todos los holidays de un usuario
  Future<List<Holiday>> getAllHolidaysForUser(String userId) async {
    return await (select(holidays)
      ..where((h) => h.userId.equals(userId) & h.isDeleted.equals(false))
      ..orderBy([(h) => OrderingTerm.asc(h.startDate)])
    ).get();
  }

  /// Obtener holidays por fuente (user o api)
  Future<List<Holiday>> getHolidaysBySource(String userId, String source) async {
    return await (select(holidays)
      ..where((h) =>
      h.userId.equals(userId) &
      h.source.equals(source) &
      h.isDeleted.equals(false))
      ..orderBy([(h) => OrderingTerm.asc(h.startDate)])
    ).get();
  }

  /// Obtener holidays por país (para holidays de API)
  Future<List<Holiday>> getHolidaysByCountry(String userId, String countryCode) async {
    return await (select(holidays)
      ..where((h) =>
      h.userId.equals(userId) &
      h.countryCode.equals(countryCode) &
      h.isDeleted.equals(false))
      ..orderBy([(h) => OrderingTerm.asc(h.startDate)])
    ).get();
  }

  /// Obtener holidays en un rango de fechas
  Future<List<Holiday>> getHolidaysInRange(
      String userId,
      DateTime startDate,
      DateTime endDate,
      ) async {
    return await (select(holidays)
      ..where((h) =>
      h.userId.equals(userId) &
      h.startDate.isBetweenValues(startDate, endDate) &
      h.isDeleted.equals(false))
      ..orderBy([(h) => OrderingTerm.asc(h.startDate)])
    ).get();
  }

  /// Obtener holidays actuales y futuros
  Future<List<Holiday>> getUpcomingHolidays(String userId) async {
    final now = DateTime.now();
    return await (select(holidays)
      ..where((h) =>
      h.userId.equals(userId) &
      h.endDate.isBiggerOrEqualValue(now) &
      h.isDeleted.equals(false))
      ..orderBy([(h) => OrderingTerm.asc(h.startDate)])
    ).get();
  }

  /// Verificar si una fecha es holiday
  Future<bool> isHoliday(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await (select(holidays)
      ..where((h) =>
      h.userId.equals(userId) &
      h.startDate.isSmallerOrEqualValue(endOfDay) &
      h.endDate.isBiggerOrEqualValue(startOfDay) &
      h.isDeleted.equals(false))
      ..limit(1)
    ).getSingleOrNull();

    return result != null;
  }

  /// Obtener holidays que necesitan sincronización
  Future<List<Holiday>> getHolidaysNeedingSync() async {
    return await (select(holidays)
      ..where((h) => h.needsSync.equals(true))
    ).get();
  }

  // ==================== UPDATE ====================

  /// Marcar holiday como necesitando sincronización
  Future<void> markForSync(String id) async {
    await (update(holidays)..where((h) => h.id.equals(id))).write(
      const HolidaysCompanion(needsSync: Value(true)),
    );
  }

  /// Marcar holiday como sincronizado
  Future<void> markAsSynced(String id) async {
    await (update(holidays)..where((h) => h.id.equals(id))).write(
      const HolidaysCompanion(needsSync: Value(false)),
    );
  }

  // ==================== DELETE ====================

  /// Soft delete - marcar como eliminado
  Future<void> softDeleteHoliday(String id) async {
    await (update(holidays)..where((h) => h.id.equals(id))).write(
      const HolidaysCompanion(
        isDeleted: Value(true),
        needsSync: Value(true),
      ),
    );
  }

  /// Hard delete - eliminar permanentemente
  Future<void> hardDeleteHoliday(String id) async {
    await (delete(holidays)..where((h) => h.id.equals(id))).go();
  }

  /// Eliminar todos los holidays de un usuario
  Future<void> deleteAllHolidaysForUser(String userId) async {
    await (delete(holidays)..where((h) => h.userId.equals(userId))).go();
  }

  /// Eliminar holidays de una fuente específica (útil para refrescar holidays de API)
  Future<void> deleteHolidaysBySource(String userId, String source) async {
    await (delete(holidays)
      ..where((h) => h.userId.equals(userId) & h.source.equals(source))
    ).go();
  }

  /// Eliminar holidays antiguos (cache cleanup)
  Future<void> deleteOldCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(holidays)..where((h) => h.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }
}