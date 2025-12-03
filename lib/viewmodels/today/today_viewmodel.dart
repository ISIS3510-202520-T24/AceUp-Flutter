import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';
import '../../core/constants/enums.dart';

enum TodayTab { timetable, assignments }

class TodayViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();

  TodayTab _selectedTab = TodayTab.timetable;
  TodayTab get selectedTab => _selectedTab;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Assignment> _assignmentsDueToday = [];
  List<Assignment> get assignmentsDueToday => _assignmentsDueToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Timetable', 'Assignments'];

  TodayViewModel({required AcademicRepository repository})
      : _repository = repository {
    _loadAssignmentsDueToday();
  }

  void selectTab(int index) {
    if (index >= 0 && index < TodayTab.values.length) {
      _selectedTab = TodayTab.values[index];
      notifyListeners();
    }
  }

  void selectTabByEnum(TodayTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> _loadAssignmentsDueToday() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    try {
      final today = DateTime.now();

      _assignmentsDueToday = await _repository.getAssignmentsDueToday(userId, today);
      _assignmentsDueToday.sort((a, b) {
        if (!a.isCompleted && b.isCompleted) return -1;
        if (a.isCompleted && !b.isCompleted) return 1;
        return 0;
      });

      _state = ViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
      print('Error loading assignments due today: $e');
    }

    notifyListeners();
  }

  Future<void> toggleAssignmentStatus(Assignment assignment) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null || assignment.termId == null || assignment.subjectId == null) {
      return;
    }

    try {
      final newStatus = assignment.isCompleted ? false : true;

      await _repository.updateAssignmentStatus(assignment.id, newStatus);

      await _loadAssignmentsDueToday();
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      _state = ViewState.error;
      notifyListeners();
    }
  }

  int get pendingCount =>
      _assignmentsDueToday
          .where((a) => !a.isCompleted)
          .length;

  int get completedCount =>
      _assignmentsDueToday
          .where((a) => a.isCompleted)
          .length;

  List<String> get exams => [];

  List<String> get timetable => [];

  List<String> get assignments => [];

  bool get hasContent {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return timetable.isNotEmpty && exams.isNotEmpty;
      case TodayTab.assignments:
        return _assignmentsDueToday.isNotEmpty;
    }
  }

  String get emptyStateMessage {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return 'No classes left for today';
      case TodayTab.assignments:
        return 'No assignments due today';
    }
  }

  String get emptyStateSubtitle {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return 'Enjoy your free time!';
      case TodayTab.assignments:
        return 'What a relief!';
    }
  }

  IconData get emptyStateIcon {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return AppIcons.chalkboard;
      case TodayTab.assignments:
        return AppIcons.assignments;
    }
  }

  Future<void> refreshAssignments() async {
    await _loadAssignmentsDueToday();
  }
}