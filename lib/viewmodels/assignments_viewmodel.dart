import 'package:flutter/material.dart';

enum AssignmentsTab { pending, completed }

class AssignmentsViewModel extends ChangeNotifier {
  AssignmentsTab _selectedTab = AssignmentsTab.pending;
  AssignmentsTab get selectedTab => _selectedTab;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Pending', 'Completed'];

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

  List<String> get pendingAssignments => [
    // Add pending assignments data here
  ];

  List<String> get completedAssignments => [
    // Add completed assignments data here
  ];

  bool get hasContent {
    switch (_selectedTab) {
      case AssignmentsTab.pending:
        return pendingAssignments.isNotEmpty;
      case AssignmentsTab.completed:
        return completedAssignments.isNotEmpty;
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
}