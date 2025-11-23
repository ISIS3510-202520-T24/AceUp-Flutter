import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../core/constants/enums.dart';
import '../../models/holidays/holiday_model.dart';
import '../local/database/app_database.dart';
import '../local/database/tables/tables.dart';

class HolidayRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  HolidayRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== READ ====================

  /// Get all holidays for user
  Future<List<Holiday>> getHolidaysForUser(String userId) async {
    final entities = await _db.holidayDao.getHolidaysForUser(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Watch holidays for user
  Stream<List<Holiday>> watchHolidaysForUser(String userId) {
    return _db.holidayDao.watchHolidaysForUser(userId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  /// Get user-created holidays only
  Future<List<Holiday>> getUserCreatedHolidays(String userId) async {
    final entities = await _db.holidayDao.getUserCreatedHolidays(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Get API holidays only
  Future<List<Holiday>> getApiHolidays(String userId) async {
    final entities = await _db.holidayDao.getApiHolidays(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Get holidays for date range
  Future<List<Holiday>> getHolidaysForDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    final entities =
        await _db.holidayDao.getHolidaysForDateRange(userId, startDate, endDate);
    return entities.map(_entityToModel).toList();
  }

  /// Check if date is a holiday
  Future<bool> isHoliday(String userId, DateTime date) async {
    return await _db.holidayDao.isHoliday(userId, date);
  }

  /// Get upcoming holidays
  Future<List<Holiday>> getUpcomingHolidays(String userId, {int limit = 5}) async {
    final entities = await _db.holidayDao.getUpcomingHolidays(userId, limit: limit);
    return entities.map(_entityToModel).toList();
  }

  // ==================== CREATE/UPDATE ====================

  /// Create user holiday
  Future<Holiday> createHoliday({
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final now = DateTime.now();
    final holiday = Holiday(
      id: _uuid.v4(),
      name: name,
      startDate: startDate,
      endDate: endDate,
      source: HolidaySource.user,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save locally
    await _db.holidayDao.insertHoliday(_modelToCompanion(holiday, userId));

    // 2. Queue for sync
    await _queueSync(holiday, userId, 'create');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, holiday);
    }

    return holiday;
  }

  /// Update holiday (only user-created holidays can be updated)
  Future<void> updateHoliday(String userId, Holiday holiday) async {
    if (holiday.source != HolidaySource.user) {
      throw Exception('Cannot update API-fetched holidays');
    }

    final updated = holiday.copyWith(updatedAt: DateTime.now());

    await _db.holidayDao.updateHoliday(_modelToCompanion(updated, userId));
    await _queueSync(updated, userId, 'update');

    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, updated);
    }
  }

  /// Delete holiday (only user-created holidays can be deleted)
  Future<void> deleteHoliday(String userId, String holidayId) async {
    final holiday = await _db.holidayDao.getHolidayById(holidayId);
    if (holiday != null && holiday.source != 'user') {
      throw Exception('Cannot delete API-fetched holidays');
    }

    await _db.holidayDao.deleteHoliday(holidayId);

    await _db.syncDao.queueSync(
      entityType: 'holiday',
      entityId: holidayId,
      operation: 'delete',
      dataJson: '{}',
      documentPath: 'users/$userId/holidays/$holidayId',
    );

    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('holidays')
          .doc(holidayId)
          .delete();
    }
  }

  // ==================== API HOLIDAYS ====================

  /// Save holidays from API (replaces all API holidays)
  Future<void> saveApiHolidays(String userId, List<Holiday> holidays) async {
    final companions = holidays.map((h) => _modelToCompanion(h, userId, synced: true)).toList();

    // Replace all API holidays
    await _db.holidayDao.replaceApiHolidays(userId, companions);

    // Also sync to Firestore if online
    if (_connectivity.isOnline) {
      try {
        // Delete existing API holidays in Firestore
        final existingSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('holidays')
            .where('source', isEqualTo: 'api')
            .get();

        final batch = _firestore.batch();
        for (final doc in existingSnapshot.docs) {
          batch.delete(doc.reference);
        }

        // Add new API holidays
        for (final holiday in holidays) {
          final ref = _firestore
              .collection('users')
              .doc(userId)
              .collection('holidays')
              .doc(holiday.id);
          batch.set(ref, holiday.toFirestore());
        }

        await batch.commit();
      } catch (e) {
        print('Error syncing API holidays to Firestore: $e');
      }
    }
  }

  // ==================== SYNC ====================

  /// Sync all holidays from Firestore
  Future<void> syncFromFirestore(String userId) async {
    if (!_connectivity.isOnline) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('holidays')
          .get();

      final companions = snapshot.docs.map((doc) {
        final holiday = Holiday.fromFirestore(doc);
        return _modelToCompanion(holiday, userId, synced: true);
      }).toList();

      await _db.holidayDao.insertHolidaysBatch(companions);
    } catch (e) {
      print('Error syncing holidays from Firestore: $e');
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Holiday _entityToModel(HolidayEntity entity) {
    return Holiday(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      source: HolidaySource.fromString(entity.source),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  HolidaysCompanion _modelToCompanion(Holiday holiday, String userId, {bool synced = false}) {
    return HolidaysCompanion(
      id: Value(holiday.id),
      userId: Value(userId),
      name: Value(holiday.name),
      startDate: Value(holiday.startDate),
      endDate: Value(holiday.endDate),
      source: Value(holiday.source.value),
      createdAt: Value(holiday.createdAt),
      updatedAt: Value(holiday.updatedAt),
      syncStatus: Value(synced ? 'synced' : 'pending'),
      lastSyncedAt: synced ? Value(DateTime.now()) : const Value.absent(),
    );
  }

  Future<void> _queueSync(Holiday holiday, String userId, String operation) async {
    await _db.syncDao.queueSync(
      entityType: 'holiday',
      entityId: holiday.id,
      operation: operation,
      dataJson: jsonEncode(holiday.toJson()),
      documentPath: 'users/$userId/holidays/${holiday.id}',
    );
  }

  Future<void> _syncToFirestore(String userId, Holiday holiday) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('holidays')
          .doc(holiday.id)
          .set(holiday.toFirestore(), SetOptions(merge: true));
      await _db.holidayDao.markAsSynced(holiday.id);
    } catch (e) {
      print('Error syncing holiday to Firestore: $e');
    }
  }
}