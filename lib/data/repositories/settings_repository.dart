import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../models/settings_model.dart' as model;
import '../../models/helpers/grading_scale_model.dart';
import '../local/database/app_database.dart';

/// Repository for user settings management with offline-first pattern
class SettingsRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  SettingsRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== OFFLINE-FIRST READ ====================

  /// Get settings for user from local database
  Future<model.Settings?> getSettingsForUser(String userId) async {
    final entity = await _db.settingsDao.getSettingsForUser(userId);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  /// Watch settings for user (stream)
  Stream<model.Settings?> watchSettingsForUser(String userId) {
    return _db.settingsDao.watchSettingsForUser(userId).map((entity) {
      if (entity == null) return null;
      return _entityToModel(entity);
    });
  }

  /// Get settings or create defaults
  Future<model.Settings> getOrCreateSettings(String userId) async {
    final settings = await getSettingsForUser(userId);
    if (settings != null) return settings;

    // Create default settings
    final defaultSettings = model.Settings.defaults();
    await saveSettings(defaultSettings, userId);
    return defaultSettings;
  }

  // ==================== OFFLINE-FIRST WRITE ====================

  /// Save settings locally and queue for sync
  Future<void> saveSettings(model.Settings settings, String userId) async {
    final companion = _modelToCompanion(settings, userId);

    await _db.settingsDao.upsertSettings(companion);

    await _queueSync(
      entityId: userId,
      operation: 'update',
      data: settings.toJson(),
      documentPath: 'users/$userId/settings/preferences',
    );
  }

  /// Update specific setting fields
  Future<void> updateSettings({
    required String userId,
    int? defaultClassDuration,
    List<int>? weekdays,
    GradingScale? gradingScale,
    String? holidayCountry,
  }) async {
    final currentSettings = await getOrCreateSettings(userId);

    final updatedSettings = currentSettings.copyWith(
      defaultClassDuration: defaultClassDuration,
      weekdays: weekdays,
      gradingScale: gradingScale,
      holidayCountry: holidayCountry,
      updatedAt: DateTime.now(),
    );

    await saveSettings(updatedSettings, userId);
  }

  // ==================== FIREBASE SYNC ====================

  /// Fetch settings from Firebase
  Future<model.Settings?> fetchSettingsFromFirebase(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (!doc.exists) return null;

      final settings = model.Settings.fromFirestore(doc);

      // Store locally
      final companion = _modelToCompanion(settings, userId);
      await _db.settingsDao.upsertSettings(companion);
      await _db.settingsDao.markAsSynced(userId);

      return settings;
    } catch (e) {
      print('Error fetching settings from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert entity to model
  model.Settings _entityToModel(SettingsEntity entity) {
    final weekdays = _parseWeekdaysJson(entity.weekdaysJson);
    final gradingScale = GradingScale.fromJsonString(entity.gradingScaleJson);

    return model.Settings(
      defaultClassDuration: entity.defaultClassDuration,
      weekdays: weekdays,
      gradingScale: gradingScale,
      holidayCountry: entity.holidayCountry,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to companion
  SettingsCompanion _modelToCompanion(model.Settings settings, String userId) {
    return SettingsCompanion(
      userId: Value(userId),
      defaultClassDuration: Value(settings.defaultClassDuration),
      weekdaysJson: Value(jsonEncode(settings.weekdays)),
      gradingScaleJson: Value(settings.gradingScale.toJsonString()),
      holidayCountry: Value(settings.holidayCountry),
      updatedAt: Value(settings.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Parse weekdays JSON string
  List<int> _parseWeekdaysJson(String jsonStr) {
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => e as int).toList();
    } catch (e) {
      return [1, 2, 3, 4, 5]; // Default Mon-Fri
    }
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
      entityType: 'settings',
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
