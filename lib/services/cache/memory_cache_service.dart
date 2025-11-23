import 'dart:collection';

class MemoryCacheService {
  static final MemoryCacheService _instance = MemoryCacheService._internal();
  factory MemoryCacheService() => _instance;

  MemoryCacheService._internal();

  /// Maximum number of entries allowed
  final int _capacity = 100;

  /// LRU cache using LinkedHashMap (keeps insertion/use order)
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();

  /// Default lifetime (optional; LRU works without TTL but we keep it)
  final Duration defaultDuration = const Duration(minutes: 5);

  // ================== CORE LRU CACHE ==================

  void put(String key, dynamic value, {Duration? duration}) {
    final expiresAt = DateTime.now().add(duration ?? defaultDuration);
    _cache[key] = _CacheEntry(value: value, expiresAt: expiresAt);

    _refreshUsage(key);
    _evictIfNeeded();
  }

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    _refreshUsage(key);
    return entry.value as T?;
  }

  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return false;
    }

    _refreshUsage(key);
    return true;
  }

  void remove(String key) => _cache.remove(key);

  void clear() => _cache.clear();

  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiresAt));
  }

  void _refreshUsage(String key) {
    final entry = _cache.remove(key);
    if (entry != null) _cache[key] = entry; // reinsert → most recently used
  }

  void _evictIfNeeded() {
    if (_cache.length > _capacity) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
  }

  // ================= GPA HELPERS (UNCHANGED) =================

  String _subjectGradeKey(String subjectId) => 'subject_grade_$subjectId';
  String _termGpaKey(String termId) => 'term_gpa_$termId';
  String _termCreditsKey(String termId) => 'term_credits_$termId';
  String _overallGpaKey(String userId) => 'overall_gpa_$userId';
  String _totalCreditsKey(String userId) => 'total_credits_$userId';

  void cacheSubjectGrade(String subjectId, double? grade) {
    grade == null
      ? remove(_subjectGradeKey(subjectId))
      : put(_subjectGradeKey(subjectId), grade);
  }

  double? getCachedSubjectGrade(String subjectId) =>
      get<double>(_subjectGradeKey(subjectId));

  void cacheTermGpa(String termId, double? gpa) {
    gpa == null
      ? remove(_termGpaKey(termId))
      : put(_termGpaKey(termId), gpa);
  }

  double? getCachedTermGpa(String termId) =>
      get<double>(_termGpaKey(termId));

  void cacheTermCredits(String termId, int credits) =>
      put(_termCreditsKey(termId), credits);

  int? getCachedTermCredits(String termId) =>
      get<int>(_termCreditsKey(termId));

  void cacheOverallGpa(String userId, double? gpa) {
    gpa == null
      ? remove(_overallGpaKey(userId))
      : put(_overallGpaKey(userId), gpa);
  }

  double? getCachedOverallGpa(String userId) =>
      get<double>(_overallGpaKey(userId));

  void cacheTotalCredits(String userId, int credits) =>
      put(_totalCreditsKey(userId), credits);

  int? getCachedTotalCredits(String userId) =>
      get<int>(_totalCreditsKey(userId));

  void invalidateUserGpaCache(String userId) {
    remove(_overallGpaKey(userId));
    remove(_totalCreditsKey(userId));
    _cache.removeWhere((key, _) =>
        key.startsWith('term_gpa_') ||
        key.startsWith('term_credits_') ||
        key.startsWith('subject_grade_'));
  }

  void invalidateTermCache(String termId) {
    remove(_termGpaKey(termId));
    remove(_termCreditsKey(termId));
  }

  void invalidateSubjectCache(String subjectId) =>
      remove(_subjectGradeKey(subjectId));

  Map<String, dynamic> getStats() {
    cleanExpired();
    return {
      'totalEntries': _cache.length,
      'keys': _cache.keys.toList(),
    };
  }
}

/// Internal cache entry
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});
}
