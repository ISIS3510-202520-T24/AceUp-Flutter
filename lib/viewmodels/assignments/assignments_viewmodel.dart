import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../services/assignments/assignment_service.dart';
import '../../services/auth/auth_service.dart';

enum AssignmentsTab { pending, completed }

enum AssignmentsViewState { idle, loading, error }

class AssignmentsViewModel extends ChangeNotifier {
  final AssignmentService _assignmentService = AssignmentService();
  final AuthService _authService = AuthService();

  AssignmentsTab _selectedTab = AssignmentsTab.pending;
  AssignmentsTab get selectedTab => _selectedTab;

  AssignmentsViewState _state = AssignmentsViewState.idle;
  AssignmentsViewState get state => _state;

  List<Assignment> _pendingAssignments = [];
  List<Assignment> _completedAssignments = [];

  List<Assignment> get pendingAssignments => _pendingAssignments;
  List<Assignment> get completedAssignments => _completedAssignments;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Pending', 'Completed'];

  AssignmentsViewModel() {
    _loadAllAssignments();
  }

  void selectTab(int index) {
    if (index >= 0 && index < AssignmentsTab.values.length) {
      _selectedTab = AssignmentsTab.values[index];
      notifyListeners();
    }
  }

  void selectTabByEnum(AssignmentsTab tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> _loadAllAssignments() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = AssignmentsViewState.error;
      notifyListeners();
      return;
    }

    _state = AssignmentsViewState.loading;
    notifyListeners();

    try {
      _pendingAssignments = await _assignmentService.getPendingAssignments(userId);
      _completedAssignments = await _assignmentService.getCompletedAssignments(userId);

      _state = AssignmentsViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AssignmentsViewState.error;
      print('Error loading all assignments: $e');
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

      await _assignmentService.updateAssignmentStatus(
        userId,
        assignment.termId!,
        assignment.subjectId!,
        assignment.id,
        newStatus,
      );

      // Update local state immediately for better UX
      if (assignment.isPending) {
        // Move from pending to completed
        _pendingAssignments.removeWhere((a) => a.id == assignment.id);
        _completedAssignments.add(assignment.copyWith(status: newStatus));

        // Sort completed by distance from today (closest first)
        final now = DateTime.now();
        _completedAssignments.sort((a, b) {
          final distanceA = a.dueDate.difference(now).inDays.abs();
          final distanceB = b.dueDate.difference(now).inDays.abs();
          return distanceA.compareTo(distanceB);
        });
      } else {
        // Move from completed to pending
        _completedAssignments.removeWhere((a) => a.id == assignment.id);
        _pendingAssignments.add(assignment.copyWith(status: newStatus));
        _pendingAssignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling assignment status: $e');
      _errorMessage = 'Failed to update assignment';
      notifyListeners();
    }
  }

  bool get hasContent {
    switch (_selectedTab) {
      case AssignmentsTab.pending:
        return _pendingAssignments.isNotEmpty;
      case AssignmentsTab.completed:
        return _completedAssignments.isNotEmpty;
    }
  }

  String get emptyStateMessage {
    switch (_selectedTab) {
      case AssignmentsTab.pending:
        return 'You have no pending assignments';
      case AssignmentsTab.completed:
        return 'You have no completed assignments';
    }
  }

  String get emptyStateSubtitle {
    switch (_selectedTab) {
      case AssignmentsTab.pending:
        return 'All assignments are up to date';
      case AssignmentsTab.completed:
        return 'No assignments have been completed yet';
    }
  }

  Future<void> refreshAssignments() async {
    await _loadAllAssignments();
  }
}