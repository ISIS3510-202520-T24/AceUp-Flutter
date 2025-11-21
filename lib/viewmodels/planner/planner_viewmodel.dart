import 'package:flutter/material.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../services/cache/memory_cache_service.dart';
import '../../data/local/database/app_database.dart' hide Term, Subject;

enum PlannerViewState { idle, loading, error }

class PlannerViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AppDatabase _db;
  final GpaCalculationService _gpaService;
  final MemoryCacheService _cache = MemoryCacheService();

  PlannerViewState _state = PlannerViewState.idle;
  PlannerViewState get state => _state;

  List<Term> _terms = [];
  List<Term> get terms => _terms;

  // Map of termId -> subjects for that term
  final Map<String, List<Subject>> _termSubjects = {};
  
  // Cached GPA values (computed at runtime)
  final Map<String, double?> _termGPAs = {};
  final Map<String, int> _termCredits = {};

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _overallGPA;
  double? get overallGPA => _overallGPA;

  int _totalCredits = 0;
  int get totalCredits => _totalCredits;

  PlannerViewModel({
    required AppDatabase database,
    required GpaCalculationService gpaService,
  })  : _db = database,
        _gpaService = gpaService {
    _loadTerms();
  }

  // ==================== LOAD DATA (OFFLINE-FIRST) ====================

  /// Load terms from local database (offline-first)
  Future<void> _loadTerms() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = PlannerViewState.error;
      notifyListeners();
      return;
    }

    _state = PlannerViewState.loading;
    notifyListeners();

    try {
      print('📊 Loading terms from local database...');
      
      // Load terms from local Drift database
      final termsData = await _db.academicDao.getAllTermsForUser(userId);
      
      // Convert Drift Term objects to model Term objects
      _terms = termsData.map((termData) => Term(
        id: termData.id,
        userId: termData.userId,
        name: termData.name,
        startDate: termData.startDate,
        endDate: termData.endDate,
        createdAt: termData.createdAt,
        updatedAt: termData.updatedAt,
      )).toList();

      print('✅ Loaded ${_terms.length} terms from local database');

      // Load subjects for each term
      for (var term in _terms) {
        await _loadTermSubjects(term.id);
      }

      // Calculate overall GPA and credits
      await _calculateOverallGPA(userId);
      
      _state = PlannerViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PlannerViewState.error;
      print('❌ Error loading terms: $e');
    }

    notifyListeners();
  }

  /// Load subjects for a specific term from local database
  Future<void> _loadTermSubjects(String termId) async {
    try {
      print('📚 Loading subjects for term $termId...');
      
      // Load subjects from local database
      final subjectsData = await _db.academicDao.getSubjectsForTerm(termId);
      
      // Convert to model objects
      final subjects = subjectsData.map((subjectData) => Subject(
        id: subjectData.id,
        name: subjectData.name,
        code: subjectData.code,
        credits: subjectData.credits,
        termId: subjectData.termId,
        userId: subjectData.userId,
        createdAt: subjectData.createdAt,
        updatedAt: subjectData.updatedAt,
      )).toList();

      _termSubjects[termId] = subjects;

      // Calculate term stats (GPA and credits)
      await _calculateTermStats(termId, subjects);
      
      print('✅ Loaded ${subjects.length} subjects for term $termId');
    } catch (e) {
      print('❌ Error loading subjects for term $termId: $e');
    }
  }

  // ==================== GPA CALCULATIONS ====================

  /// Calculate term statistics (GPA and credits) with caching
  Future<void> _calculateTermStats(String termId, List<Subject> subjects) async {
    try {
      // Check cache first
      final cachedGpa = _cache.getCachedTermGpa(termId);
      final cachedCredits = _cache.getCachedTermCredits(termId);
      
      if (cachedGpa != null && cachedCredits != null) {
        _termGPAs[termId] = cachedGpa;
        _termCredits[termId] = cachedCredits;
        print('✅ Using cached GPA for term $termId: ${cachedGpa.toStringAsFixed(2)}');
        return;
      }

      // Calculate credits
      final totalCredits = await _gpaService.getTermTotalCredits(termId);
      _termCredits[termId] = totalCredits;
      _cache.cacheTermCredits(termId, totalCredits);

      // Calculate GPA
      final termGpa = await _gpaService.calculateTermGpa(termId);
      _termGPAs[termId] = termGpa;
      _cache.cacheTermGpa(termId, termGpa);

      print('✅ Calculated GPA for term $termId: ${termGpa?.toStringAsFixed(2) ?? 'N/A'}');
    } catch (e) {
      print('❌ Error calculating term stats for $termId: $e');
      _termGPAs[termId] = null;
      _termCredits[termId] = 0;
    }
  }

  /// Calculate overall GPA across all terms with caching
  Future<void> _calculateOverallGPA(String userId) async {
    try {
      // Check cache first
      final cachedGpa = _cache.getCachedOverallGpa(userId);
      final cachedCredits = _cache.getCachedTotalCredits(userId);
      
      if (cachedGpa != null && cachedCredits != null) {
        _overallGPA = cachedGpa;
        _totalCredits = cachedCredits;
        print('✅ Using cached overall GPA: ${cachedGpa.toStringAsFixed(2)}');
        return;
      }

      // Calculate total credits
      _totalCredits = await _gpaService.getTotalCredits(userId);
      _cache.cacheTotalCredits(userId, _totalCredits);

      // Calculate overall GPA
      _overallGPA = await _gpaService.calculateOverallGpa(userId);
      _cache.cacheOverallGpa(userId, _overallGPA);

      print('✅ Calculated overall GPA: ${_overallGPA?.toStringAsFixed(2) ?? 'N/A'}');
    } catch (e) {
      print('❌ Error calculating overall GPA: $e');
      _overallGPA = null;
      _totalCredits = 0;
    }
  }

  // ==================== GETTERS ====================

  double? getTermGPA(String termId) => _termGPAs[termId];

  int getTermCredits(String termId) => _termCredits[termId] ?? 0;

  List<Subject> getTermSubjects(String termId) => _termSubjects[termId] ?? [];

  String getTermDateRange(Term term) {
    if (term.startDate == null || term.endDate == null) {
      return '';
    }
    final start = _formatDate(term.startDate!);
    final end = _formatDate(term.endDate!);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // ==================== ACTIONS ====================

  /// Refresh terms (reload from database and recalculate)
  Future<void> refreshTerms() async {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      // Invalidate cache
      _cache.invalidateUserGpaCache(userId);
    }
    await _loadTerms();
  }

  /// Delete a term (soft delete in database, triggers sync)
  Future<void> deleteTerm(String termId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      // Soft delete in local database (will be synced to Firebase)
      await _db.academicDao.deleteTerm(termId);
      
      // Invalidate cache
      _cache.invalidateTermCache(termId);
      _cache.invalidateUserGpaCache(userId);

      // Refresh data
      await refreshTerms();
    } catch (e) {
      print('❌ Error deleting term: $e');
    }
  }

  /// Force recalculate all GPA values (invalidate cache)
  Future<void> recalculateAllGPA() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    print('🔄 Forcing GPA recalculation...');
    
    // Clear all GPA cache
    _cache.invalidateUserGpaCache(userId);
    
    // Recalculate for all terms
    for (var term in _terms) {
      final subjects = _termSubjects[term.id] ?? [];
      await _calculateTermStats(term.id, subjects);
    }
    
    // Recalculate overall
    await _calculateOverallGPA(userId);
    
    notifyListeners();
  }
}