import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/academic_repository.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';
import '../../models/assignments/assignment_model.dart';

enum SubjectTab { timetable, assignments, grades }

enum SubjectViewState { idle, loading, error }

class SubjectViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final String subjectId;
  final String termId;
  
  SubjectTab _selectedTab = SubjectTab.assignments;
  SubjectTab get selectedTab => _selectedTab;
  
  SubjectViewState _state = SubjectViewState.idle;
  SubjectViewState get state => _state;

  Subject? _subject;
  Subject? get subject => _subject;

  List<Assignment> _subjectAssignments = [];
  List<Assignment> get subjectAssignments => _subjectAssignments;

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
    _loadSubject();
    _loadSubjectAssignments();
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
      _errorMessage = 'User not logged in';
      _state = SubjectViewState.error;
      notifyListeners();
      return;
    }

    try {
      final subjectDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .get();

      if (subjectDoc.exists) {
        _subject = Subject.fromFirestore(subjectDoc);
        
        // Load grades data
        final data = subjectDoc.data();
        _useGrades = data?['useGrades'] ?? true;
        _finalSubjectGrade = data?['finalGrade']?.toDouble();
        
        if (_finalSubjectGrade != null) {
          finalGradeController.text = _finalSubjectGrade!.toStringAsFixed(2);
        }
        
        creditsController.text = _subject!.credits.toString();
        
        // Load weights
        final weightsJson = data?['weightCategoriesJson'] as String?;
        if (weightsJson != null) {
          // Parse weights JSON (simplified version)
          // In a real implementation, you'd properly parse the JSON
          _weights = {};
        }
        
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load subject: $e';
      _state = SubjectViewState.error;
      print('Error loading subject: $e');
      notifyListeners();
    }
  }

  Future<void> _loadSubjectAssignments() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = SubjectViewState.error;
      notifyListeners();
      return;
    }

    _state = SubjectViewState.loading;
    notifyListeners();

    try {
      // Load all assignments for this subject
      _subjectAssignments = await _repository.getAssignmentsForSubject(subjectId);
      
      _state = SubjectViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = SubjectViewState.error;
      print('Error loading subject assignments: $e');
    }

    notifyListeners();
  }

  Future<void> refreshAssignments() async {
    await _loadSubjectAssignments();
  }

  Future<void> refreshSubject() async {
    await _loadSubject();
    await _loadSubjectAssignments();
  }

  Future<void> toggleAssignmentStatus(Assignment assignment) async {
    try {
      final newStatus = assignment.isCompleted ? 'Pending' : 'Completed';
      await _repository.updateAssignmentStatus(assignment.id, newStatus);
      await _loadSubjectAssignments();
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      _state = SubjectViewState.error;
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
    }
  }

  Future<void> _saveGradesData() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final data = <String, dynamic>{
        'useGrades': _useGrades,
        'useFinalGradeOverride': _finalSubjectGrade != null,
        'finalGrade': _finalSubjectGrade,
        'credits': int.tryParse(creditsController.text) ?? _subject?.credits ?? 3,
        'updatedAt': Timestamp.now(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .update(data);
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