import 'package:flutter/material.dart';

enum TodayTab { exams, timetable, assignments }

class TodayViewModel extends ChangeNotifier {
  TodayTab _selectedTab = TodayTab.assignments;
  TodayTab get selectedTab => _selectedTab;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Exams', 'Timetable', 'Assignments'];

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

  List<String> get exams => [
    // Add exams data here
  ];

  List<String> get timetable => [
    // Add timetable data here
  ];

  List<String> get assignments => [
    // Add assignments data here
  ];

  bool get hasContent {
    switch (_selectedTab) {
      case TodayTab.exams:
        return exams.isNotEmpty;
      case TodayTab.timetable:
        return timetable.isNotEmpty;
      case TodayTab.assignments:
        return assignments.isNotEmpty;
    }
  }

  String get emptyStateMessage {
    switch (_selectedTab) {
      case TodayTab.exams:
        return 'You have no exams scheduled for today';
      case TodayTab.timetable:
        return 'You have no classes scheduled for today';
      case TodayTab.assignments:
        return 'You have no assignments due for the next 7 days';
    }
  }

  String get emptyStateSubtitle {
    switch (_selectedTab) {
      case TodayTab.exams:
        return 'Time to relax and prepare!';
      case TodayTab.timetable:
        return 'Enjoy your free time!';
      case TodayTab.assignments:
        return 'Time to work on a hobby of yours!';
    }
  }
}