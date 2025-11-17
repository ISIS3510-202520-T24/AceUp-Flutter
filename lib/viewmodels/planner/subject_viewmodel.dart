import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> get classes => _classes;

  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> get exams => _exams;

  List<Assignment> _subjectAssignments = [];
  List<Assignment> get subjectAssignments => _subjectAssignments;

  int _classesLeft = 0;
  int get classesLeft => _classesLeft;

  int _examsLeft = 0;
  int get examsLeft => _examsLeft;

  double _currentGrade = 4.00;
  double get currentGrade => _currentGrade;

  bool _useGrades = true;
  bool get useGrades => _useGrades;

  double? _finalSubjectGrade;
  double? get finalSubjectGrade => _finalSubjectGrade;

  Map<String, int> _weights = {};
  Map<String, int> get weights => _weights;

  int _credits = 3;
  int get credits => _credits;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Timetable', 'Assignments', 'Grades'];

  SubjectViewModel({
    required AcademicRepository repository,
    required this.subjectId,
    required this.termId,
  })
      : _repository = repository {
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
      final today = DateTime.now();

      _subjectAssignments = await _repository.getAssignmentsDueToday(userId, today);
      _subjectAssignments.sort((a, b) {
        if (a.isPending && b.isCompleted) return -1;
        if (a.isCompleted && b.isPending) return 1;
        return 0;
      });

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
}