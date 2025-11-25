import 'package:flutter/material.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';
import '../../services/grades/gpa_calculation_service.dart';
import '../../services/cache/memory_cache_service.dart';
import '../../data/repositories/academic_repository.dart';

enum TermViewState { idle, loading, error }

class TermViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AcademicRepository _repository;
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
    required AcademicRepository repository,
    required GpaCalculationService gpaService,
  })  : _repository = repository,
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

      // Load term from repository
      _term = await _repository.getTermById(termId);

      if (_term == null) {
        _errorMessage = 'Term not found';
        _state = TermViewState.error;
        notifyListeners();
        return;
      }

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

  /// Load subjects from repository
  Future<void> _loadSubjects() async {
    try {
      print('📚 Loading subjects for term $termId...');

      // Load from repository
      _subjects = await _repository.getSubjectsForTerm(termId);

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

  /// Delete a subject
  Future<void> deleteSubject(String subjectId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      // Delete via repository (requires termId for nested Firestore path)
      await _repository.deleteSubject(subjectId, userId, termId);

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