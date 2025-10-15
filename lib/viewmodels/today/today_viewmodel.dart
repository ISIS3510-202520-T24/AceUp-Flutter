import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../services/assignments/assignment_service.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';

enum TodayTab { exams, timetable, assignments }

enum TodayViewState { idle, loading, error }

class TodayViewModel extends ChangeNotifier {
  final AssignmentService _assignmentService = AssignmentService();
  final AuthService _authService = AuthService();

  TodayTab _selectedTab = TodayTab.assignments;

  TodayTab get selectedTab => _selectedTab;

  TodayViewState _state = TodayViewState.idle;

  TodayViewState get state => _state;

  List<Assignment> _assignmentsDueToday = [];

  List<Assignment> get assignmentsDueToday => _assignmentsDueToday;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Exams', 'Timetable', 'Assignments'];

  TodayViewModel() {
    _loadAssignmentsDueToday();
  }

  void selectTab(int index) {
    if (index >= 0 && index < TodayTab.values.length) {
      _selectedTab = TodayTab.values[index];

      // Reload assignments when switching to assignments tab
      if (_selectedTab == TodayTab.assignments) {
        _loadAssignmentsDueToday();
      }

      notifyListeners();
    }
  }

  void selectTabByEnum(TodayTab tab) {
    _selectedTab = tab;

    if (_selectedTab == TodayTab.assignments) {
      _loadAssignmentsDueToday();
    }

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
      _assignmentsDueToday =
      await _assignmentService.getAssignmentsDueToday(userId, today);

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
    if (userId == null || assignment.termId == null ||
        assignment.subjectId == null) {
      return;
    }

    try {
      final newStatus = assignment.isPending ? 'Completed' : 'Pending';

      await _assignmentService.updateAssignmentStatus(
        userId,
        assignment.termId!,
        assignment.subjectId!,
        assignment.id,
        newStatus,
      );

      // Update local state immediately for better UX
      final index = _assignmentsDueToday.indexWhere((a) =>
      a.id == assignment.id);
      if (index != -1) {
        _assignmentsDueToday[index] = assignment.copyWith(status: newStatus);

        // Re-sort: pending first, then completed
        _assignmentsDueToday.sort((a, b) {
          if (a.isPending && b.isCompleted) return -1;
          if (a.isCompleted && b.isPending) return 1;
          return 0;
        });

        notifyListeners();
      }
    } catch (e) {
      print('Error toggling assignment status: $e');
      _errorMessage = 'Failed to update assignment';
      notifyListeners();
    }
  }

  int get pendingCount =>
      _assignmentsDueToday
          .where((a) => a.isPending)
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
      case TodayTab.exams:
        return exams.isNotEmpty;
      case TodayTab.timetable:
        return timetable.isNotEmpty;
      case TodayTab.assignments:
        return _assignmentsDueToday.isNotEmpty;
    }
  }

  String get emptyStateMessage {
    switch (_selectedTab) {
      case TodayTab.exams:
        return 'You have no exams scheduled for today';
      case TodayTab.timetable:
        return 'You have no classes scheduled for today';
      case TodayTab.assignments:
        return 'No assignments due today!';
    }
  }

  String get emptyStateSubtitle {
    switch (_selectedTab) {
      case TodayTab.exams:
        return 'Time to relax and prepare!';
      case TodayTab.timetable:
        return 'Enjoy your free time!';
      case TodayTab.assignments:
        return 'Great job staying ahead!';
    }
  }

  IconData get emptyStateIcon {
    switch (_selectedTab) {
      case TodayTab.exams:
        return AppIcons.exam;
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