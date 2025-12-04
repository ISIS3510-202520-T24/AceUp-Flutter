// lib/services/cache/calendar_cache_service.dart
import '../../models/planner/class_template_model.dart';
import '../../models/assignments/assignment_model.dart';
import 'lru_cache.dart';

/// LRU Cache service specifically for Calendar View
/// Caches classes and assignments by date to avoid repeated database queries
/// 
/// Strategy: LRU (Least Recently Used) with configurable capacity
/// - Classes and assignments are cached separately by date key (yyyy-MM-dd)
/// - When cache is full, least recently accessed items are evicted
/// - Cache is cleared when data changes (refresh/sync)
class CalendarCacheService {
  // Singleton pattern for global cache access
  static final CalendarCacheService _instance = CalendarCacheService._internal();
  factory CalendarCacheService() => _instance;
  CalendarCacheService._internal();

  // LRU caches with capacity of 30 days each (optimized for monthly view)
  final _classesCache = LruCache<List<ClassTemplate>>(capacity: 30);
  final _assignmentsCache = LruCache<List<Assignment>>(capacity: 30);

  /// Generate cache key from date (format: yyyy-MM-dd)
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get cached classes for a date
  List<ClassTemplate>? getCachedClasses(DateTime date) {
    final key = _dateKey(date);
    final cached = _classesCache.get(key);
    if (cached != null) {
      print('✅ Cache HIT for classes on $key (${cached.length} items)');
    } else {
      print('❌ Cache MISS for classes on $key');
    }
    return cached;
  }

  /// Cache classes for a date
  void cacheClasses(DateTime date, List<ClassTemplate> classes) {
    final key = _dateKey(date);
    _classesCache.set(key, classes);
    print('💾 Cached ${classes.length} classes for $key');
  }

  /// Get cached assignments for a date
  List<Assignment>? getCachedAssignments(DateTime date) {
    final key = _dateKey(date);
    final cached = _assignmentsCache.get(key);
    if (cached != null) {
      print('✅ Cache HIT for assignments on $key (${cached.length} items)');
    } else {
      print('❌ Cache MISS for assignments on $key');
    }
    return cached;
  }

  /// Cache assignments for a date
  void cacheAssignments(DateTime date, List<Assignment> assignments) {
    final key = _dateKey(date);
    _assignmentsCache.set(key, assignments);
    print('💾 Cached ${assignments.length} assignments for $key');
  }

  /// Clear all calendar cache (call when data changes)
  void clearCache() {
    _classesCache.clear();
    _assignmentsCache.clear();
    print('🗑️ Calendar cache cleared');
  }

  /// Clear cache for a specific date
  void clearDateCache(DateTime date) {
    final key = _dateKey(date);
    _classesCache.set(key, []);
    _assignmentsCache.set(key, []);
    print('🗑️ Cache cleared for $key');
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'classes_capacity': _classesCache.capacity,
      'assignments_capacity': _assignmentsCache.capacity,
    };
  }
}
