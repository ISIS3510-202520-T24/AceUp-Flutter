// lib/services/storage/hive_service.dart
// Servicio para manejar almacenamiento con Hive (BD Llave/Valor)

import 'package:hive_flutter/hive_flutter.dart'; // ignore: uri_does_not_exist
import '../../models/visited_group_history.dart';
import '../../models/cache_config.dart';

// ignore_for_file: undefined_identifier, undefined_class

class HiveService {
  static const String _visitedGroupsBox = 'visited_groups';
  static const String _cacheConfigBox = 'cache_config';
  
  static HiveService? _instance;
  
  HiveService._();
  
  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  /// Inicializa Hive y registra adaptadores
  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Registrar adaptadores de Hive (generados por hive_generator)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(VisitedGroupHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CacheConfigAdapter());
    }
    
    // Abrir boxes
    await Hive.openBox<VisitedGroupHistory>(_visitedGroupsBox);
    await Hive.openBox<CacheConfig>(_cacheConfigBox);
  }

  // ==================== VISITED GROUPS ====================

  /// Obtiene el box de historial de grupos visitados
  Box<VisitedGroupHistory> get _visitedGroupsBoxInstance => 
    Hive.box<VisitedGroupHistory>(_visitedGroupsBox);

  /// Registra una visita a un grupo
  Future<void> recordGroupVisit({
    required String groupId,
    required String groupName,
    String? avatarUrl,
  }) async {
    final box = _visitedGroupsBoxInstance;
    final existing = box.get(groupId);
    
    if (existing != null) {
      // Incrementar contador de visitas
      final updated = existing.copyWith(
        lastVisited: DateTime.now(),
        visitCount: existing.visitCount + 1,
        groupAvatarUrl: avatarUrl ?? existing.groupAvatarUrl,
      );
      await box.put(groupId, updated);
    } else {
      // Primera visita
      final newVisit = VisitedGroupHistory(
        groupId: groupId,
        groupName: groupName,
        lastVisited: DateTime.now(),
        visitCount: 1,
        groupAvatarUrl: avatarUrl,
      );
      await box.put(groupId, newVisit);
    }
  }

  /// Obtiene el historial de grupos visitados ordenados por última visita
  List<VisitedGroupHistory> getVisitedGroups({int? limit}) {
    final box = _visitedGroupsBoxInstance;
    final allVisits = box.values.toList();
    
    // Ordenar por última visita (más reciente primero)
    allVisits.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
    
    if (limit != null && limit > 0) {
      return allVisits.take(limit).toList();
    }
    
    return allVisits;
  }

  /// Obtiene los grupos más visitados
  List<VisitedGroupHistory> getMostVisitedGroups({int limit = 5}) {
    final box = _visitedGroupsBoxInstance;
    final allVisits = box.values.toList();
    
    // Ordenar por contador de visitas (mayor primero)
    allVisits.sort((a, b) => b.visitCount.compareTo(a.visitCount));
    
    return allVisits.take(limit).toList();
  }

  /// Obtiene el historial de un grupo específico
  VisitedGroupHistory? getGroupHistory(String groupId) {
    final box = _visitedGroupsBoxInstance;
    return box.get(groupId);
  }

  /// Elimina un grupo del historial
  Future<void> removeGroupFromHistory(String groupId) async {
    final box = _visitedGroupsBoxInstance;
    await box.delete(groupId);
  }

  /// Limpia todo el historial de grupos visitados
  Future<void> clearVisitedGroupsHistory() async {
    final box = _visitedGroupsBoxInstance;
    await box.clear();
  }

  /// Obtiene estadísticas del historial
  Map<String, dynamic> getVisitStatistics() {
    final box = _visitedGroupsBoxInstance;
    final allVisits = box.values.toList();
    
    if (allVisits.isEmpty) {
      return {
        'totalGroups': 0,
        'totalVisits': 0,
        'averageVisitsPerGroup': 0.0,
        'mostVisitedGroup': null,
      };
    }
    
    final totalVisits = allVisits.fold<int>(0, (sum, visit) => sum + visit.visitCount);
    final mostVisited = allVisits.reduce((a, b) => a.visitCount > b.visitCount ? a : b);
    
    return {
      'totalGroups': allVisits.length,
      'totalVisits': totalVisits,
      'averageVisitsPerGroup': totalVisits / allVisits.length,
      'mostVisitedGroup': mostVisited.toJson(),
    };
  }

  // ==================== CACHE CONFIG ====================

  /// Obtiene el box de configuración de cache
  Box<CacheConfig> get _cacheConfigBoxInstance => 
    Hive.box<CacheConfig>(_cacheConfigBox);

  /// Obtiene la configuración de cache actual
  CacheConfig getCacheConfig() {
    final box = _cacheConfigBoxInstance;
    return box.get('config') ?? CacheConfig();
  }

  /// Guarda la configuración de cache
  Future<void> saveCacheConfig(CacheConfig config) async {
    final box = _cacheConfigBoxInstance;
    await box.put('config', config);
  }

  /// Actualiza el tamaño máximo del cache
  Future<void> updateCacheSize(int maxSize) async {
    final config = getCacheConfig();
    await saveCacheConfig(config.copyWith(maxCacheSize: maxSize));
  }

  /// Actualiza la duración del cache
  Future<void> updateCacheDuration(Duration duration) async {
    final config = getCacheConfig();
    await saveCacheConfig(config.copyWith(cacheDuration: duration));
  }

  /// Activa/desactiva el cache de imágenes
  Future<void> toggleImageCache(bool enabled) async {
    final config = getCacheConfig();
    await saveCacheConfig(config.copyWith(enableImageCache: enabled));
  }

  /// Activa/desactiva el cache de eventos
  Future<void> toggleEventsCache(bool enabled) async {
    final config = getCacheConfig();
    await saveCacheConfig(config.copyWith(enableEventsCache: enabled));
  }

  /// Registra que el cache fue limpiado
  Future<void> markCacheCleared() async {
    final config = getCacheConfig();
    await saveCacheConfig(config.copyWith(lastCacheCleared: DateTime.now()));
  }

  // ==================== CLEANUP ====================

  /// Cierra todas las boxes de Hive
  Future<void> close() async {
    await Hive.close();
  }

  /// Compacta las boxes para liberar espacio
  Future<void> compact() async {
    await _visitedGroupsBoxInstance.compact();
    await _cacheConfigBoxInstance.compact();
  }

  /// Obtiene el tamaño en disco de las boxes (en bytes)
  Future<Map<String, int>> getBoxSizes() async {
    return {
      'visitedGroups': await _getBoxSize(_visitedGroupsBox),
      'cacheConfig': await _getBoxSize(_cacheConfigBox),
    };
  }

  Future<int> _getBoxSize(String boxName) async {
    try {
      final box = Hive.box(boxName);
      // Aproximación del tamaño basado en cantidad de elementos
      return box.length * 100; // 100 bytes promedio por elemento
    } catch (e) {
      return 0;
    }
  }
}
