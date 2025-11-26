// lib/services/storage/app_preferences.dart
// Servicio para manejar preferencias del usuario con SharedPreferences

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // ignore: uri_does_not_exist

// ignore_for_file: undefined_identifier, undefined_class

class AppPreferences {
  static const String _keyAutoRefresh = 'auto_refresh_on_reconnect';
  static const String _keyShowOfflineBanner = 'show_offline_banner';
  static const String _keyLastSyncTime = 'last_sync_time';
  static const String _keyEnableNotifications = 'enable_notifications';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCacheEnabled = 'cache_enabled';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyLastUserId = 'last_user_id';
  static const String _keyAutoSyncInterval = 'auto_sync_interval_minutes';

  static AppPreferences? _instance;
  SharedPreferences? _prefs;
  
  // 🔹 StreamController para notificar cambios en las preferencias
  final _preferencesChangedController = StreamController<String>.broadcast();
  
  /// Stream que emite el nombre de la preferencia que cambió
  Stream<String> get onPreferenceChanged => _preferencesChangedController.stream;

  AppPreferences._();

  static AppPreferences get instance {
    _instance ??= AppPreferences._();
    return _instance!;
  }

  /// Inicializa SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _prefsInstance {
    if (_prefs == null) {
      throw Exception('AppPreferences not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // ==================== AUTO REFRESH ====================

  /// Obtiene si el auto-refresh está habilitado
  bool get autoRefreshOnReconnect {
    return _prefsInstance.getBool(_keyAutoRefresh) ?? true;
  }

  /// Establece si el auto-refresh está habilitado
  Future<bool> setAutoRefreshOnReconnect(bool value) async {
    final result = await _prefsInstance.setBool(_keyAutoRefresh, value);
    if (result) {
      // 🔹 Notificar que cambió esta preferencia
      _preferencesChangedController.add(_keyAutoRefresh);
      print('✅ Preferencia autoRefreshOnReconnect actualizada a: $value');
    }
    return result;
  }

  // ==================== OFFLINE BANNER ====================

  /// Obtiene si se debe mostrar el banner de offline
  bool get showOfflineBanner {
    return _prefsInstance.getBool(_keyShowOfflineBanner) ?? true;
  }

  /// Establece si se debe mostrar el banner de offline
  Future<bool> setShowOfflineBanner(bool value) async {
    final result = await _prefsInstance.setBool(_keyShowOfflineBanner, value);
    if (result) {
      // 🔹 Notificar que cambió esta preferencia
      _preferencesChangedController.add(_keyShowOfflineBanner);
      print('✅ Preferencia showOfflineBanner actualizada a: $value');
    }
    return result;
  }

  // ==================== LAST SYNC TIME ====================

  /// Obtiene la fecha de la última sincronización
  DateTime? get lastSyncTime {
    final timestamp = _prefsInstance.getInt(_keyLastSyncTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Establece la fecha de la última sincronización
  Future<bool> setLastSyncTime(DateTime time) async {
    return await _prefsInstance.setInt(_keyLastSyncTime, time.millisecondsSinceEpoch);
  }

  /// Marca la sincronización como ahora
  Future<bool> markSyncedNow() async {
    return await setLastSyncTime(DateTime.now());
  }

  /// Obtiene hace cuánto fue la última sincronización
  Duration? get timeSinceLastSync {
    final lastSync = lastSyncTime;
    if (lastSync == null) return null;
    return DateTime.now().difference(lastSync);
  }

  // ==================== NOTIFICATIONS ====================

  /// Obtiene si las notificaciones están habilitadas
  bool get notificationsEnabled {
    return _prefsInstance.getBool(_keyEnableNotifications) ?? true;
  }

  /// Establece si las notificaciones están habilitadas
  Future<bool> setNotificationsEnabled(bool value) async {
    return await _prefsInstance.setBool(_keyEnableNotifications, value);
  }

  // ==================== THEME MODE ====================

  /// Obtiene el modo de tema guardado (light, dark, system)
  String get themeMode {
    return _prefsInstance.getString(_keyThemeMode) ?? 'system';
  }

  /// Establece el modo de tema
  Future<bool> setThemeMode(String mode) async {
    if (!['light', 'dark', 'system'].contains(mode)) {
      throw ArgumentError('Invalid theme mode: $mode');
    }
    return await _prefsInstance.setString(_keyThemeMode, mode);
  }

  // ==================== CACHE ENABLED ====================

  /// Obtiene si el cache está habilitado
  bool get cacheEnabled {
    return _prefsInstance.getBool(_keyCacheEnabled) ?? true;
  }

  /// Establece si el cache está habilitado
  Future<bool> setCacheEnabled(bool value) async {
    return await _prefsInstance.setBool(_keyCacheEnabled, value);
  }

  // ==================== FIRST LAUNCH ====================

  /// Obtiene si es la primera vez que se lanza la app
  bool get isFirstLaunch {
    return _prefsInstance.getBool(_keyFirstLaunch) ?? true;
  }

  /// Marca que la app ya no es el primer lanzamiento
  Future<bool> setFirstLaunchComplete() async {
    return await _prefsInstance.setBool(_keyFirstLaunch, false);
  }

  // ==================== LAST USER ====================

  /// Obtiene el ID del último usuario que inició sesión
  String? get lastUserId {
    return _prefsInstance.getString(_keyLastUserId);
  }

  /// Establece el ID del último usuario
  Future<bool> setLastUserId(String userId) async {
    return await _prefsInstance.setString(_keyLastUserId, userId);
  }

  // ==================== AUTO SYNC INTERVAL ====================

  /// Obtiene el intervalo de sincronización automática en minutos
  int get autoSyncIntervalMinutes {
    return _prefsInstance.getInt(_keyAutoSyncInterval) ?? 30;
  }

  /// Establece el intervalo de sincronización automática
  Future<bool> setAutoSyncInterval(int minutes) async {
    if (minutes < 1) {
      throw ArgumentError('Sync interval must be at least 1 minute');
    }
    return await _prefsInstance.setInt(_keyAutoSyncInterval, minutes);
  }

  // ==================== UTILITY METHODS ====================

  /// Limpia todas las preferencias (útil para logout o reset)
  Future<bool> clearAll() async {
    return await _prefsInstance.clear();
  }

  /// Limpia preferencias específicas del usuario (mantiene configuraciones generales)
  Future<void> clearUserPreferences() async {
    await _prefsInstance.remove(_keyLastUserId);
    await _prefsInstance.remove(_keyLastSyncTime);
  }

  /// Obtiene todas las preferencias como un mapa (para debugging/export)
  Map<String, dynamic> getAllPreferences() {
    final keys = _prefsInstance.getKeys();
    final Map<String, dynamic> result = {};
    
    for (final key in keys) {
      final value = _prefsInstance.get(key);
      result[key] = value;
    }
    
    return result;
  }

  /// Exporta las preferencias como JSON string
  String exportPreferences() {
    final prefs = getAllPreferences();
    return prefs.toString();
  }

  /// Reestablece las preferencias a los valores por defecto
  Future<void> resetToDefaults() async {
    await setAutoRefreshOnReconnect(true);
    await setShowOfflineBanner(true);
    await setNotificationsEnabled(true);
    await setThemeMode('system');
    await setCacheEnabled(true);
    await setAutoSyncInterval(30);
  }

  // ==================== STATS ====================

  /// Obtiene estadísticas de las preferencias
  Map<String, dynamic> getPreferencesStats() {
    return {
      'autoRefresh': autoRefreshOnReconnect,
      'offlineBanner': showOfflineBanner,
      'lastSync': lastSyncTime?.toIso8601String(),
      'timeSinceSync': timeSinceLastSync?.inMinutes,
      'notifications': notificationsEnabled,
      'theme': themeMode,
      'cache': cacheEnabled,
      'firstLaunch': isFirstLaunch,
      'syncInterval': autoSyncIntervalMinutes,
    };
  }
}
