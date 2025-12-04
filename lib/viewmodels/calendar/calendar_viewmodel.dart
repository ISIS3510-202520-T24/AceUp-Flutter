// lib/viewmodels/calendar_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';

enum CalendarTab { timetable, assignments }

class CalendarViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  CalendarTab _selectedTab = CalendarTab.timetable;
  
  bool _loading = false;
  List<ClassTemplate> _classesForDay = [];
  List<Assignment> _assignmentsForDay = [];

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;
  CalendarTab get selectedTab => _selectedTab;
  bool get loading => _loading;
  List<ClassTemplate> get classesForDay => _classesForDay;
  List<Assignment> get assignmentsForDay => _assignmentsForDay;

  CalendarViewModel(this._repository) {
    _loadDataForSelectedDate();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _loadDataForSelectedDate();
    notifyListeners();
  }

  void changeMonth(int monthOffset) {
    _focusedMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + monthOffset,
      1,
    );
    notifyListeners();
  }

  void selectTab(int index) {
    if (index >= 0 && index < CalendarTab.values.length) {
      _selectedTab = CalendarTab.values[index];
      notifyListeners();
    }
  }

  Future<void> _loadDataForSelectedDate() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    _loading = true;
    notifyListeners();

    try {
      // Load classes for the selected day
      _classesForDay = await _getClassesForDate(_selectedDate, userId);
      
      // Load assignments for the selected day
      _assignmentsForDay = await _getAssignmentsForDate(_selectedDate, userId);
    } catch (e) {
      print('Error loading calendar data: $e');
      _classesForDay = [];
      _assignmentsForDay = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<ClassTemplate>> _getClassesForDate(DateTime date, String userId) async {
    try {
      final activeTerm = await _repository.getActiveTermForUser(userId);
      if (activeTerm == null) return [];

      final subjects = await _repository.getSubjectsForTerm(activeTerm.id);
      final List<ClassTemplate> allClasses = [];

      for (final subject in subjects) {
        final classes = await _repository.getClassTemplatesForSubject(subject.id);
        
        // Filter classes that occur on the selected date
        final classesForDate = classes.where((classTemplate) {
          return _doesClassOccurOnDate(classTemplate, date);
        }).toList();

        allClasses.addAll(classesForDate);
      }

      // Sort by start time
      allClasses.sort((a, b) => a.startTime.compareTo(b.startTime));
      return allClasses;
    } catch (e) {
      print('Error getting classes for date: $e');
      return [];
    }
  }

  Future<List<Assignment>> _getAssignmentsForDate(DateTime date, String userId) async {
    try {
      final activeTerm = await _repository.getActiveTermForUser(userId);
      if (activeTerm == null) return [];

      final subjects = await _repository.getSubjectsForTerm(activeTerm.id);
      final List<Assignment> allAssignments = [];

      for (final subject in subjects) {
        final assignments = await _repository.getAssignmentsForSubject(subject.id);
        
        // Filter assignments due on the selected date
        final assignmentsForDate = assignments.where((assignment) {
          return _isSameDay(assignment.dueDate, date);
        }).toList();

        allAssignments.addAll(assignmentsForDate);
      }

      // Sort by time (if available) then by priority
      allAssignments.sort((a, b) {
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        }
        return b.priority.index.compareTo(a.priority.index);
      });
      
      return allAssignments;
    } catch (e) {
      print('Error getting assignments for date: $e');
      return [];
    }
  }

  bool _doesClassOccurOnDate(ClassTemplate classTemplate, DateTime date) {
    // Check if date is within the class template range
    if (date.isBefore(classTemplate.startDate) || date.isAfter(classTemplate.endDate)) {
      return false;
    }

    // Check if the day matches the recurrence pattern
    // selectedDays uses 0=Sunday, 6=Saturday, but DateTime.weekday uses 1=Monday, 7=Sunday
    // Convert DateTime.weekday to selectedDays format
    final weekday = date.weekday == 7 ? 0 : date.weekday; // Convert Sunday from 7 to 0
    return classTemplate.recurrence.selectedDays.contains(weekday);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> refresh() async {
    await _loadDataForSelectedDate();
  }
}
