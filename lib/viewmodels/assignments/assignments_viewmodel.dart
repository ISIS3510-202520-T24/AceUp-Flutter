import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';

enum AssignmentsTab { pending, completed }

enum AssignmentsViewState { idle, loading, error }

class AssignmentsViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
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

  AssignmentsViewModel({required AcademicRepository repository})
      : _repository = repository {
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
      _pendingAssignments = await _repository.getPendingAssignments(userId);
      _completedAssignments = await _repository.getCompletedAssignments(userId);

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
      final newStatus = assignment.isCompleted ? false : true;

      await _repository.updateAssignmentStatus(assignment.id, newStatus);

      await _loadAllAssignments();
    } catch (e) {
      _errorMessage = 'Failed to update assignment: $e';
      _state = AssignmentsViewState.error;
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