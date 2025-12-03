import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../models/planner/subject_model.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/planner/exam_model.dart';
import '../../services/auth/auth_service.dart';
import '../../models/assignments/assignment_model.dart';

enum SubjectTab { timetable, assignments, grades }

class SubjectViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();
  final String subjectId;
  final String termId;

  SubjectTab _selectedTab = SubjectTab.assignments;
  SubjectTab get selectedTab => _selectedTab;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  Subject? _subject;
  Subject? get subject => _subject;

  List<Assignment> _subjectAssignments = [];
  List<Assignment> get subjectAssignments => _subjectAssignments;

  List<ClassTemplate> _classTemplates = [];
  List<ClassTemplate> get classTemplates => _classTemplates;

  List<Exam> _exams = [];
  List<Exam> get exams => _exams;

  // TODO: Implement classes left calculation (complex - requires date calculations, holiday checks, etc.)
  int get classesLeft => 23; // Static placeholder for now

  int get examsLeft => _exams.where((exam) => !exam.isCompleted).length;

  double _currentGrade = 4.00;
  double get currentGrade => _currentGrade;

  bool _useGrades = true;
  bool get useGrades => _useGrades;

  double? _finalSubjectGrade;
  double? get finalSubjectGrade => _finalSubjectGrade;

  Map<String, int> _weights = {};
  Map<String, int> get weightsList => _weights;

  late TextEditingController finalGradeController;
  late TextEditingController creditsController;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Timetable', 'Assignments', 'Grades'];

  SubjectViewModel({
    required AcademicRepository repository,
    required this.subjectId,
    required this.termId,
  }) : _repository = repository {
    finalGradeController = TextEditingController();
    creditsController = TextEditingController();
    _initializeData();
  }

  /// Initialize all data with proper loading state
  Future<void> _initializeData() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      // Load all data in parallel
      await Future.wait([
        _loadSubject(),
        _loadSubjectAssignments(),
        _loadClassTemplates(),
        _loadExams(),
      ]);

      // Initialize form fields after subject is loaded
      if (_subject != null) {
        _initializeFormFields();
      }

      _state = ViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load subject data: $e';
      _state = ViewState.error;
      print('❌ Error initializing subject data: $e');
    }

    notifyListeners();
  }

  void selectTab(int index) {
    if (index >= 0 && index < SubjectTab.values.length) {
      _selectedTab = SubjectTab.values[index];
      notifyListeners();
    }
  }

  void selectTabByEnum(SubjectTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> _loadSubject() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      print('📊 Loading subject $subjectId from local database...');

      _subject = await _repository.getSubjectById(subjectId);

      if (_subject == null) {
        throw Exception('Subject not found');
      }

      print('✅ Loaded subject: ${_subject!.name}');
    } catch (e) {
      print('❌ Error loading subject: $e');
      rethrow;
    }
  }

  /// Initialize form fields from loaded subject data
  void _initializeFormFields() {
    if (_subject == null) return;

    // Initialize credits controller
    creditsController.text = _subject!.credits.toString();

    // Initialize final grade if override is enabled
    if (_subject!.useFinalGradeOverride && _subject!.finalGrade != null) {
      _finalSubjectGrade = _subject!.finalGrade;
      finalGradeController.text = _subject!.finalGrade!.toStringAsFixed(2);
    }

    // Build weights map for display
    _weights = {};
    for (final weight in _subject!.weights) {
      _weights[weight.name] = weight.percentage.toInt();
    }

    // Note: _currentGrade should be calculated from assignments/exams
    // TODO: Implement grade calculation
    _currentGrade = _subject!.finalGrade ?? 0.0;
  }

  Future<void> _loadSubjectAssignments() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Load all assignments for this subject
      _subjectAssignments = await _repository.getAssignmentsForSubject(subjectId);
    } catch (e) {
      print('❌ Error loading subject assignments: $e');
      rethrow;
    }
  }

  Future<void> _loadClassTemplates() async {
    try {
      _classTemplates = await _repository.getClassTemplatesForSubject(subjectId);
    } catch (e) {
      print('❌ Error loading class templates: $e');
      rethrow;
    }
  }

  Future<void> _loadExams() async {
    try {
      _exams = await _repository.getExamsForSubject(subjectId);
    } catch (e) {
      print('❌ Error loading exams: $e');
      rethrow;
    }
  }

  Future<void> refreshAssignments() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      await _loadSubjectAssignments();
      _state = ViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh assignments: $e';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  Future<void> refreshSubject() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      await Future.wait([
        _loadSubject(),
        _loadSubjectAssignments(),
        _loadClassTemplates(),
        _loadExams(),
      ]);

      // Re-initialize form fields after refresh
      if (_subject != null) {
        _initializeFormFields();
      }

      _state = ViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to refresh subject: $e';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  Future<void> toggleAssignmentStatus(Assignment assignment) async {
    try {
      final newStatus = assignment.isCompleted ? false : true;
      await _repository.updateAssignmentStatus(assignment.id, newStatus);
      await _loadSubjectAssignments();
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      _state = ViewState.error;
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(Assignment assignment) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null || assignment.termId == null || assignment.subjectId == null) {
      _errorMessage = 'Cannot delete assignment: missing required information';
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    try {
      await _repository.deleteAssignment(
        assignment.id,
        userId,
        assignment.termId!,
        assignment.subjectId!,
      );

      await _loadSubjectAssignments();
    } catch (e) {
      _errorMessage = 'Failed to delete assignment: $e';
      _state = ViewState.error;
      notifyListeners();
    }
  }

  void toggleUseGrades() {
    _useGrades = !_useGrades;
    _saveGradesData();
    notifyListeners();
  }

  void toggleFinalGradeOverride() {
    if (_finalSubjectGrade == null) {
      _finalSubjectGrade = 0.0;
      finalGradeController.text = '0.00';
    } else {
      _finalSubjectGrade = null;
      finalGradeController.clear();
    }
    _saveGradesData();
    notifyListeners();
  }

  void updateFinalGrade(String value) {
    final grade = double.tryParse(value);
    if (grade != null) {
      _finalSubjectGrade = grade;
      _saveGradesData();
    }
  }

  void updateCredits(String value) {
    final credits = int.tryParse(value);
    if (credits != null && credits > 0) {
      _saveGradesData();
      notifyListeners();
    }
  }

  Future<void> _saveGradesData() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null || _subject == null) return;

    try {
      // Update subject with new grade settings
      final updatedSubject = _subject!.copyWith(
        useFinalGradeOverride: _finalSubjectGrade != null,
        finalGrade: _finalSubjectGrade,
        credits: int.tryParse(creditsController.text) ?? _subject!.credits,
        updatedAt: DateTime.now(),
      );

      // Save to repository (offline-first with sync queue)
      await _repository.saveSubject(
        updatedSubject,
        userId,
        termId,
      );

      _subject = updatedSubject;
    } catch (e) {
      print('Error saving grades data: $e');
    }
  }

  @override
  void dispose() {
    finalGradeController.dispose();
    creditsController.dispose();
    super.dispose();
  }
}