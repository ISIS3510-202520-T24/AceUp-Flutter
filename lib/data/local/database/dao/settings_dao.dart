// lib/data/local/database/dao/settings_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(AppDatabase db) : super(db);

  // ==================== CRUD DE SETTINGS ====================
  
  /// Guardar setting
  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insert(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
  
  /// Obtener setting
  Future<String?> getSetting(String key) async {
    final setting = await (select(appSettings)
      ..where((s) => s.key.equals(key)))
      .getSingleOrNull();
    
    return setting?.value;
  }
  
  /// Obtener setting con default
  Future<String> getSettingWithDefault(String key, String defaultValue) async {
    final value = await getSetting(key);
    return value ?? defaultValue;
  }
  
  /// Eliminar setting
  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((s) => s.key.equals(key))).go();
  }

  /// Obtener todos los settings
  Future<Map<String, String>> getAllSettings() async {
    final settings = await select(appSettings).get();
    return {for (final s in settings) s.key: s.value};
  }

  /// Batch guardar settings
  Future<void> setSettingsBatch(Map<String, String> settings) async {
    await batch((batch) {
      batch.insertAll(
        appSettings,
        settings.entries.map((e) => AppSettingsCompanion(
          key: Value(e.key),
          value: Value(e.value),
          updatedAt: Value(DateTime.now()),
        )).toList(),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== SETTINGS ESPECÍFICOS ====================
  
  /// Settings de última sincronización
  Future<DateTime?> getLastSyncTime() async {
    final value = await getSetting('last_sync_time');
    return value != null ? DateTime.parse(value) : null;
  }
  
  Future<void> setLastSyncTime(DateTime time) async {
    await setSetting('last_sync_time', time.toIso8601String());
  }

  /// Settings de vista de calendario
  Future<String> getCalendarViewMode() async {
    return await getSettingWithDefault('calendar_view_mode', 'week');
  }
  
  Future<void> setCalendarViewMode(String mode) async {
    await setSetting('calendar_view_mode', mode);
  }

  /// Settings de tutorial visto
  Future<bool> getGroupTutorialShown() async {
    final value = await getSetting('group_tutorial_shown');
    return value == 'true';
  }
  
  Future<void> setGroupTutorialShown(bool shown) async {
    await setSetting('group_tutorial_shown', shown.toString());
  }

  /// Último grupo visitado
  Future<String?> getLastViewedGroup() async {
    return await getSetting('last_viewed_group');
  }
  
  Future<void> setLastViewedGroup(String groupId) async {
    await setSetting('last_viewed_group', groupId);
  }

  /// Grupos favoritos (CSV)
  Future<List<String>> getFavoriteGroups() async {
    final value = await getSetting('favorite_groups');
    if (value == null || value.isEmpty) return [];
    return value.split(',');
  }
  
  Future<void> setFavoriteGroups(List<String> groupIds) async {
    await setSetting('favorite_groups', groupIds.join(','));
  }
  
  Future<void> addFavoriteGroup(String groupId) async {
    final favorites = await getFavoriteGroups();
    if (!favorites.contains(groupId)) {
      favorites.add(groupId);
      await setFavoriteGroups(favorites);
    }
  }
  
  Future<void> removeFavoriteGroup(String groupId) async {
    final favorites = await getFavoriteGroups();
    favorites.remove(groupId);
    await setFavoriteGroups(favorites);
  }

  // ==================== STREAMS ====================
  
  /// Watch setting
  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((setting) => setting?.value);
  }

  /// Watch all settings
  Stream<Map<String, String>> watchAllSettings() {
    return select(appSettings).watch().map((settings) {
      return {for (final s in settings) s.key: s.value};
    });
  }
}
