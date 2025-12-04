import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart'; // ignore: uri_does_not_exist
import '../../models/holidays/holiday_model.dart' as model;
import '../../services/holidays/holiday_service.dart';
import '../local/database/app_database.dart';

/// Repository for holiday data management with offline-first pattern
/// Note: Holidays are typically fetched from an API and stored locally,
/// user-created holidays are synced to Firebase
class HolidayRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  HolidayRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== OFFLINE-FIRST READ ====================

  /// Get all holidays for user from local database
  Future<List<model.Holiday>> getHolidaysForUser(String userId) async {
    final entities = await _db.holidayDao.getHolidaysForUser(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Get holiday by ID from local database
  Future<model.Holiday?> getHolidayById(String holidayId) async {
    final entity = await _db.holidayDao.getHolidayById(holidayId);
    return entity != null ? _entityToModel(entity) : null;
  }

  /// Watch holidays for user (stream)
  Stream<List<model.Holiday>> watchHolidaysForUser(String userId) {
    return _db.holidayDao.watchHolidaysForUser(userId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  /// Get holidays for specific year
  Future<List<model.Holiday>> getHolidaysForYear(String userId, int year) async {
    final entities = await _db.holidayDao.getHolidaysForYear(userId, year);
    return entities.map(_entityToModel).toList();
  }

  /// Get user-created holidays only (not from API)
  Future<List<model.Holiday>> getUserCreatedHolidays(String userId) async {
    final entities = await _db.holidayDao.getUserCreatedHolidays(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Get API holidays only
  Future<List<model.Holiday>> getApiHolidays(String userId) async {
    final entities = await _db.holidayDao.getApiHolidays(userId);
    return entities.map(_entityToModel).toList();
  }

  // ==================== OFFLINE-FIRST WRITE ====================

  /// Save holiday locally (user-created holidays are queued for sync)
  Future<void> saveHoliday(model.Holiday holiday, String userId) async {
    final companion = _modelToCompanion(holiday, userId);

    await _db.holidayDao.upsertHoliday(companion);

    // Only sync user-created holidays to Firebase
    if (holiday.source == 'user') {
      await _queueSync(
        entityId: holiday.id,
        operation: 'update',
        data: holiday.toJson(),
        documentPath: 'users/$userId/holidays/${holiday.id}',
      );
    }
  }

  /// Save multiple holidays (typically from API)
  Future<void> saveHolidaysBatch(List<model.Holiday> holidays, String userId) async {
    final companions = holidays
        .map((holiday) => _modelToCompanion(holiday, userId))
        .toList();

    await _db.holidayDao.insertHolidaysBatch(companions);
  }

  /// Delete holiday
  Future<void> deleteHoliday(String holidayId, String userId) async {
    await _db.holidayDao.deleteHoliday(holidayId);

    await _queueSync(
      entityId: holidayId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/holidays/$holidayId',
    );
  }

  /// Clear all API holidays for a year
  Future<void> clearApiHolidaysForYear(String userId, int year) async {
    await _db.holidayDao.deleteApiHolidaysForYear(userId, year);
  }

  // ==================== API INTEGRATION ====================

  /// Fetch API holidays from Nager.Date API and save to local database
  /// This method fetches holidays for current and next year, replaces old API holidays
  Future<List<model.Holiday>> fetchAndSaveApiHolidays(
    String userId,
    String countryCode,
  ) async {
    try {
      final holidayService = HolidayService();
      final currentYear = DateTime.now().year;
      final nextYear = currentYear + 1;

      print('🌍 Fetching API holidays for country: $countryCode');

      // Clear old API holidays for these years
      await clearApiHolidaysForYear(userId, currentYear);
      await clearApiHolidaysForYear(userId, nextYear);

      // Fetch from API
      final apiHolidays = await holidayService.getHolidaysForCurrentAndNextYear(countryCode);

      // Save to local database
      await saveHolidaysBatch(apiHolidays, userId);

      print('✅ Saved ${apiHolidays.length} API holidays to local database');
      return apiHolidays;
    } catch (e) {
      print('❌ Error fetching API holidays: $e');
      rethrow;
    }
  }

  // ==================== FIREBASE SYNC ====================

  /// Fetch user-created holidays from Firebase
  Future<List<model.Holiday>> fetchHolidaysFromFirebase(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('holidays')
          .get();

      final holidays = snapshot.docs
          .map((doc) => model.Holiday.fromFirestore(doc))
          .toList();

      // Store locally
      for (final holiday in holidays) {
        final companion = _modelToCompanion(holiday, userId);
        await _db.holidayDao.upsertHoliday(companion);
        await _db.holidayDao.markAsSynced(holiday.id);
      }

      return holidays;
    } catch (e) {
      print('Error fetching holidays from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert entity to model
  model.Holiday _entityToModel(HolidayEntity entity) {
    return model.Holiday(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      source: entity.source,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to companion
  HolidaysCompanion _modelToCompanion(model.Holiday holiday, String userId) {
    return HolidaysCompanion(
      id: Value(holiday.id), //ignore: undefined_method
      userId: Value(userId), //ignore: undefined_method
      name: Value(holiday.name), //ignore: undefined_method
      startDate: Value(holiday.startDate), //ignore: undefined_method
      endDate: Value(holiday.endDate), //ignore: undefined_method
      source: Value(holiday.source), //ignore: undefined_method
      createdAt: Value(holiday.createdAt), //ignore: undefined_method
      updatedAt: Value(holiday.updatedAt), //ignore: undefined_method
      syncStatus: Value(holiday.source == 'user' ? 'pending' : 'synced'), //ignore: undefined_method
      lastSyncedAt: Value(DateTime.now()), //ignore: undefined_method
    );
  }


  // ==================== SYNC QUEUE HELPERS ====================

  /// Queue sync operation
  Future<void> _queueSync({
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    required String documentPath,
  }) async {
    await _db.syncDao.queueSync(
      entityType: 'holiday',
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
