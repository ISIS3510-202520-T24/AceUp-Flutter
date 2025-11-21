import 'dart:async';

/// In-memory cache for temporary runtime data like GPA calculations
/// This cache is NOT persisted and clears when the app restarts
class MemoryCacheService {
  static final MemoryCacheService _instance = MemoryCacheService._internal();
  factory MemoryCacheService() => _instance;
  
  MemoryCacheService._internal();

  // Cache storage with expiration times
  final Map<String, _CacheEntry> _cache = {};
  
  // Default cache duration
  final Duration defaultDuration = const Duration(minutes: 5);

  // ==================== CACHE OPERATIONS ====================

  /// Store a value in cache with optional custom duration
  void put(String key, dynamic value, {Duration? duration}) {
    final expiresAt = DateTime.now().add(duration ?? defaultDuration);
    _cache[key] = _CacheEntry(value: value, expiresAt: expiresAt);
  }

  /// Get a value from cache, returns null if expired or not found
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;
    
    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value as T?;
  }

  /// Check if a key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Remove expired entries
  void cleanExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => now.isAfter(entry.expiresAt));
  }

  // ==================== GPA-SPECIFIC HELPERS ====================

  /// Cache key generators for GPA values
  String _subjectGradeKey(String subjectId) => 'subject_grade_$subjectId';
  String _termGpaKey(String termId) => 'term_gpa_$termId';
  String _termCreditsKey(String termId) => 'term_credits_$termId';
  String _overallGpaKey(String userId) => 'overall_gpa_$userId';
  String _totalCreditsKey(String userId) => 'total_credits_$userId';

  /// Cache subject grade
  void cacheSubjectGrade(String subjectId, double? grade) {
    if (grade == null) {
      remove(_subjectGradeKey(subjectId));
    } else {
      put(_subjectGradeKey(subjectId), grade);
    }
  }

  /// Get cached subject grade
  double? getCachedSubjectGrade(String subjectId) {
    return get<double>(_subjectGradeKey(subjectId));
  }

  /// Cache term GPA
  void cacheTermGpa(String termId, double? gpa) {
    if (gpa == null) {
      remove(_termGpaKey(termId));
    } else {
      put(_termGpaKey(termId), gpa);
    }
  }

  /// Get cached term GPA
  double? getCachedTermGpa(String termId) {
    return get<double>(_termGpaKey(termId));
  }

  /// Cache term credits
  void cacheTermCredits(String termId, int credits) {
    put(_termCreditsKey(termId), credits);
  }

  /// Get cached term credits
  int? getCachedTermCredits(String termId) {
    return get<int>(_termCreditsKey(termId));
  }

  /// Cache overall GPA
  void cacheOverallGpa(String userId, double? gpa) {
    if (gpa == null) {
      remove(_overallGpaKey(userId));
    } else {
      put(_overallGpaKey(userId), gpa);
    }
  }

  /// Get cached overall GPA
  double? getCachedOverallGpa(String userId) {
    return get<double>(_overallGpaKey(userId));
  }

  /// Cache total credits
  void cacheTotalCredits(String userId, int credits) {
    put(_totalCreditsKey(userId), credits);
  }

  /// Get cached total credits
  int? getCachedTotalCredits(String userId) {
    return get<int>(_totalCreditsKey(userId));
  }

  /// Invalidate all GPA-related cache for a user
  void invalidateUserGpaCache(String userId) {
    // Remove overall GPA
    remove(_overallGpaKey(userId));
    remove(_totalCreditsKey(userId));
    
    // Remove all term and subject caches
    // Note: This is a simple implementation - in production you might want
    // to track which keys belong to which user
    _cache.removeWhere((key, _) => 
      key.startsWith('term_gpa_') || 
      key.startsWith('term_credits_') || 
      key.startsWith('subject_grade_')
    );
  }

  /// Invalidate cache for a specific term
  void invalidateTermCache(String termId) {
    remove(_termGpaKey(termId));
    remove(_termCreditsKey(termId));
  }

  /// Invalidate cache for a specific subject
  void invalidateSubjectCache(String subjectId) {
    remove(_subjectGradeKey(subjectId));
  }

  // ==================== STATISTICS ====================

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    cleanExpired();
    return {
      'totalEntries': _cache.length,
      'keys': _cache.keys.toList(),
    };
  }
}

/// Internal cache entry with expiration
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});
}