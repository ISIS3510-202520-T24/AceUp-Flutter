import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/settings_model.dart';
import '../../models/helpers/grading_scale_model.dart';
import '../local/database/app_database.dart';
import '../local/database/tables/tables.dart';

class SettingsRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;

  SettingsRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== READ ====================

  /// Get settings for user
  Future<Settings> getSettingsForUser(String userId) async {
    final entity = await _db.settingsDao.getSettingsForUser(userId);
    if (entity != null) {
      return _entityToModel(entity);
    }

    // If no settings exist, create default settings
    await _db.settingsDao.createDefaultSettings(userId);
    return Settings.defaults();
  }

  /// Watch settings for user
  Stream<Settings?> watchSettingsForUser(String userId) {
    return _db.settingsDao.watchSettingsForUser(userId).map((entity) {
      return entity != null ? _entityToModel(entity) : null;
    });
  }

  // ==================== UPDATE ====================

  /// Update settings
  Future<void> updateSettings(String userId, Settings settings) async {
    final updated = settings.copyWith(updatedAt: DateTime.now());

    await _db.settingsDao.upsertSettings(_modelToCompanion(updated, userId));
    await _queueSync(updated, userId);

    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, updated);
    }
  }

  /// Update default class duration
  Future<void> updateDefaultClassDuration(String userId, int duration) async {
    await _db.settingsDao.updateDefaultClassDuration(userId, duration);

    if (_connectivity.isOnline) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set({
          'defaultClassDuration': duration,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
        await _db.settingsDao.markAsSynced(userId);
      } catch (e) {
        print('Error syncing default class duration: $e');
      }
    }
  }

  /// Update weekdays
  Future<void> updateWeekdays(String userId, List<int> weekdays) async {
    final weekdaysJson = jsonEncode(weekdays);
    await _db.settingsDao.updateWeekdays(userId, weekdaysJson);

    if (_connectivity.isOnline) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set({
          'weekdays': weekdays,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
        await _db.settingsDao.markAsSynced(userId);
      } catch (e) {
        print('Error syncing weekdays: $e');
      }
    }
  }

  /// Update grading scale
  Future<void> updateGradingScale(String userId, GradingScale gradingScale) async {
    final gradingScaleJson = gradingScale.toJsonString();
    await _db.settingsDao.updateGradingScale(userId, gradingScaleJson);

    if (_connectivity.isOnline) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set({
          'gradingScale': gradingScale.toJson(),
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
        await _db.settingsDao.markAsSynced(userId);
      } catch (e) {
        print('Error syncing grading scale: $e');
      }
    }
  }

  /// Update holiday country (triggers holiday refresh)
  Future<void> updateHolidayCountry(String userId, String countryCode) async {
    await _db.settingsDao.updateHolidayCountry(userId, countryCode);

    if (_connectivity.isOnline) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('preferences')
            .set({
          'holidayCountry': countryCode,
          'updatedAt': Timestamp.now(),
        }, SetOptions(merge: true));
        await _db.settingsDao.markAsSynced(userId);
      } catch (e) {
        print('Error syncing holiday country: $e');
      }
    }
  }

  // ==================== SYNC ====================

  /// Sync settings from Firestore
  Future<void> syncFromFirestore(String userId) async {
    if (!_connectivity.isOnline) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists) {
        final settings = Settings.fromFirestore(doc);
        await _db.settingsDao.upsertSettings(_modelToCompanion(settings, userId, synced: true));
      } else {
        // Create default settings if none exist
        await _db.settingsDao.createDefaultSettings(userId);
      }
    } catch (e) {
      print('Error syncing settings from Firestore: $e');
    }
  }

  /// Create default settings for new user
  Future<Settings> createDefaultSettings(String userId) async {
    final settings = Settings.defaults();
    
    await _db.settingsDao.upsertSettings(_modelToCompanion(settings, userId));

    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, settings);
    }

    return settings;
  }

  // ==================== PRIVATE HELPERS ====================

  Settings _entityToModel(SettingsEntity entity) {
    final weekdays = (jsonDecode(entity.weekdaysJson) as List<dynamic>)
        .map((e) => e as int)
        .toList();

    return Settings(
      defaultClassDuration: entity.defaultClassDuration,
      weekdays: weekdays,
      gradingScale: GradingScale.fromJsonString(entity.gradingScaleJson),
      holidayCountry: entity.holidayCountry,
      updatedAt: entity.updatedAt,
    );
  }

  SettingsCompanion _modelToCompanion(Settings settings, String userId, {bool synced = false}) {
    return SettingsCompanion(
      userId: Value(userId),
      defaultClassDuration: Value(settings.defaultClassDuration),
      weekdaysJson: Value(jsonEncode(settings.weekdays)),
      gradingScaleJson: Value(settings.gradingScale.toJsonString()),
      holidayCountry: Value(settings.holidayCountry),
      updatedAt: Value(settings.updatedAt),
      syncStatus: Value(synced ? 'synced' : 'pending'),
      lastSyncedAt: synced ? Value(DateTime.now()) : const Value.absent(),
    );
  }

  Future<void> _queueSync(Settings settings, String userId) async {
    await _db.syncDao.queueSync(
      entityType: 'settings',
      entityId: userId,
      operation: 'update',
      dataJson: jsonEncode(settings.toJson()),
      documentPath: 'users/$userId/settings/preferences',
    );
  }

  Future<void> _syncToFirestore(String userId, Settings settings) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set(settings.toFirestore(), SetOptions(merge: true));
      await _db.settingsDao.markAsSynced(userId);
    } catch (e) {
      print('Error syncing settings to Firestore: $e');
    }
  }
}