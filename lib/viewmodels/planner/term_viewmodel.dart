import 'package:flutter/material.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../services/cache/memory_cache_service.dart';
import '../../data/local/database/app_database.dart' hide Term, Subject;

enum TermViewState { idle, loading, error }

class TermViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AppDatabase _db;
  final GpaCalculationService _gpaService;
  final MemoryCacheService _cache = MemoryCacheService();
  final String termId;

  TermViewState _state = TermViewState.idle;
  TermViewState get state => _state;

  Term? _term;
  Term? get term => _term;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _termGPA;
  double? get termGPA => _termGPA;

  int _termCredits = 0;
  int get termCredits => _termCredits;

  TermViewModel({
    required this.termId,
    required AppDatabase database,
    required GpaCalculationService gpaService,
  })  : _db = database,
        _gpaService = gpaService {
    _loadTerm();
  }

  // ==================== LOAD DATA (OFFLINE-FIRST) ====================

  /// Load term and subjects from local database
  Future<void> _loadTerm() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = TermViewState.error;
      notifyListeners();
      return;
    }

    _state = TermViewState.loading;
    notifyListeners();

    try {
      print('📊 Loading term $termId from local database...');
      
      // Load term from local database
      final termData = await _db.academicDao.getTermById(termId);

      if (termData == null) {
        _errorMessage = 'Term not found';
        _state = TermViewState.error;
        notifyListeners();
        return;
      }

      // Convert to model
      _term = Term(
        id: termData.id,
        userId: termData.userId,
        name: termData.name,
        startDate: termData.startDate,
        endDate: termData.endDate,
        createdAt: termData.createdAt,
        updatedAt: termData.updatedAt,
      );

      print('✅ Loaded term: ${_term!.name}');

      // Load subjects
      await _loadSubjects();

      _state = TermViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TermViewState.error;
      print('❌ Error loading term: $e');
    }

    notifyListeners();
  }

  /// Load subjects from local database
  Future<void> _loadSubjects() async {
    try {
      print('📚 Loading subjects for term $termId...');
      
      // Load from local database
      final subjectsData = await _db.academicDao.getSubjectsForTerm(termId);

      // Convert to models
      _subjects = subjectsData.map((subjectData) => Subject(
        id: subjectData.id,
        name: subjectData.name,
        code: subjectData.code,
        credits: subjectData.credits,
        termId: subjectData.termId,
        userId: subjectData.userId,
        createdAt: subjectData.createdAt,
        updatedAt: subjectData.updatedAt,
      )).toList();

      print('✅ Loaded ${_subjects.length} subjects');

      // Calculate term stats
      await _calculateTermStats();
    } catch (e) {
      print('❌ Error loading subjects: $e');
    }
  }

  // ==================== GPA CALCULATIONS ====================

  /// Calculate term GPA and credits with caching
  Future<void> _calculateTermStats() async {
    try {
      // Check cache first
      final cachedGpa = _cache.getCachedTermGpa(termId);
      final cachedCredits = _cache.getCachedTermCredits(termId);
      
      if (cachedGpa != null && cachedCredits != null) {
        _termGPA = cachedGpa;
        _termCredits = cachedCredits;
        print('✅ Using cached GPA for term $termId: ${cachedGpa.toStringAsFixed(2)}');
        return;
      }

      // Calculate credits
      _termCredits = await _gpaService.getTermTotalCredits(termId);
      _cache.cacheTermCredits(termId, _termCredits);

      // Calculate GPA
      _termGPA = await _gpaService.calculateTermGpa(termId);
      _cache.cacheTermGpa(termId, _termGPA);

      print('✅ Calculated term GPA: ${_termGPA?.toStringAsFixed(2) ?? 'N/A'} with $_termCredits credits');
    } catch (e) {
      print('❌ Error calculating term stats: $e');
      _termGPA = null;
      _termCredits = 0;
    }
  }

  /// Get grade for a specific subject with caching
  Future<double?> getSubjectGrade(String subjectId) async {
    // Check cache first
    final cachedGrade = _cache.getCachedSubjectGrade(subjectId);
    if (cachedGrade != null) {
      return cachedGrade;
    }

    // Calculate and cache
    final grade = await _gpaService.calculateSubjectGrade(subjectId);
    _cache.cacheSubjectGrade(subjectId, grade);
    return grade;
  }

  // ==================== ACTIONS ====================

  /// Refresh term data (reload from database and recalculate)
  Future<void> refreshTerm() async {
    // Invalidate cache
    _cache.invalidateTermCache(termId);
    await _loadTerm();
  }

  /// Delete a subject (soft delete in database)
  Future<void> deleteSubject(String subjectId) async {
    try {
      // Soft delete in local database
      await _db.academicDao.softDeleteSubject(subjectId);
      
      // Invalidate cache
      _cache.invalidateSubjectCache(subjectId);
      _cache.invalidateTermCache(termId);

      // Refresh data
      await refreshTerm();
    } catch (e) {
      print('❌ Error deleting subject: $e');
    }
  }

  /// Force recalculate GPA (invalidate cache)
  Future<void> recalculateGPA() async {
    print('🔄 Forcing GPA recalculation for term $termId...');
    
    // Clear cache
    _cache.invalidateTermCache(termId);
    
    // Recalculate
    await _calculateTermStats();
    
    notifyListeners();
  }
}