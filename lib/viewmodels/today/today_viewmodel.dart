import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';

enum TodayTab { timetable, assignments }

enum TodayViewState { idle, loading, error }

class TodayViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();

  TodayTab _selectedTab = TodayTab.timetable;
  TodayTab get selectedTab => _selectedTab;

  TodayViewState _state = TodayViewState.idle;
  TodayViewState get state => _state;

  List<Assignment> _assignmentsDueToday = [];
  List<Assignment> get assignmentsDueToday => _assignmentsDueToday;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Timetable', 'Assignments'];

  // Mock data for timetable (you'll implement this properly later)
  List<String> get timetable => ['Morning Class', 'Afternoon Lab'];
  List<String> get exams => ['Midterm Exam'];

  String get emptyStateMessage {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return 'No classes today';
      case TodayTab.assignments:
        return 'No assignments due today';
    }
  }

  String get emptyStateSubtitle {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return 'Enjoy your free day!';
      case TodayTab.assignments:
        return 'You\'re all caught up!';
    }
  }

  IconData get emptyStateIcon {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return AppIcons.calendarDay;
      case TodayTab.assignments:
        return AppIcons.assignments;
    }
  }

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
      _state = TodayViewState.error;
      notifyListeners();
      return;
    }

    _state = TodayViewState.loading;
    notifyListeners();

    try {
      final today = DateTime.now();

      // Load from repository (offline-first)
      _assignmentsDueToday = await _repository.getAssignmentsDueToday(userId, today);

      // Sort: pending first, then completed
      _assignmentsDueToday.sort((a, b) {
        if (a.isPending && b.isCompleted) return -1;
        if (a.isCompleted && b.isPending) return 1;
        return 0;
      });

      _state = TodayViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TodayViewState.error;
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
      final newStatus = assignment.isPending ? 'Completed' : 'Pending';

      // Update via repository (offline-first)
      await _repository.updateAssignmentStatus(assignment.id, newStatus);

      // Reload assignments
      await _loadAssignmentsDueToday();
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      _state = TodayViewState.error;
      notifyListeners();
    }
  }

  Future<void> refreshAssignments() async {
    await _loadAssignmentsDueToday();
  }
}