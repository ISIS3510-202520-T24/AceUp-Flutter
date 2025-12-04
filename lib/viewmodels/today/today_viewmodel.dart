import 'package:flutter/material.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/helpers/recurrence_model.dart';
import '../../models/planner/subject_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';
import '../../core/constants/enums.dart';

enum TodayTab { timetable, assignments }

/// Unified timetable item representing either a class or exam
class TimetableItem {
  final String id;
  final String subjectId;
  final String subjectName;
  final Color subjectColor;
  final String name;
  final String? teacherName;
  final String? building;
  final String? room;
  final DateTime startTime;
  final DateTime endTime;
  final bool isExam;
  final IconData? classIcon;

  TimetableItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.name,
    this.teacherName,
    this.building,
    this.room,
    required this.startTime,
    required this.endTime,
    required this.isExam,
    this.classIcon,
  });

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isPast {
    final now = DateTime.now();
    return now.isAfter(endTime);
  }
}

class TodayViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();

  TodayTab _selectedTab = TodayTab.timetable;
  TodayTab get selectedTab => _selectedTab;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  List<Assignment> _assignmentsDueToday = [];
  List<Assignment> get assignmentsDueToday => _assignmentsDueToday;

  List<TimetableItem> _timetableItems = [];
  List<TimetableItem> get timetableItems => _timetableItems;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int get selectedTabIndex => _selectedTab.index;

  final List<String> tabLabels = ['Timetable', 'Assignments'];

  TodayViewModel({required AcademicRepository repository})
      : _repository = repository {
    _loadAssignmentsDueToday();
    _loadTimetableForToday();
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

  Future<void> deleteAssignment(Assignment assignment) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null || assignment.termId == null || assignment.subjectId == null) {
      _errorMessage = 'Cannot delete assignment: missing required information';
      _state = ViewState.error;
      notifyListeners();
      return;
    }

    try {
      await _repository.deleteAssignment(
        assignment.id,
        userId,
        assignment.termId!,
        assignment.subjectId!,
      );

      await _loadAssignmentsDueToday();
    } catch (e) {
      _errorMessage = 'Failed to delete assignment: $e';
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

  bool get hasContent {
    switch (_selectedTab) {
      case TodayTab.timetable:
        return _timetableItems.isNotEmpty;
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
    await _loadTimetableForToday();
  }

  Future<void> refreshTimetable() async {
    await _loadTimetableForToday();
  }

  Future<void> _loadTimetableForToday() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      print('❌ No user logged in for timetable');
      return;
    }

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      print('📅 Loading timetable for today: $today');

      // Load exams for today
      final exams = await _repository.getExamsForToday(userId, today);
      print('📝 Found ${exams.length} exams for today');

      // Load all class templates and calculate which ones occur today
      final classTemplates = await _repository.getClassTemplatesForUser(userId);
      print('📚 Found ${classTemplates.length} class templates');

      // Load all subjects (from all terms) to get names and colors
      final terms = await _repository.getTermsForUser(userId);
      final List<Subject> allSubjects = [];
      for (final term in terms) {
        final termSubjects = await _repository.getSubjectsForTerm(term.id);
        allSubjects.addAll(termSubjects);
      }
      final subjectMap = {for (var s in allSubjects) s.id: s};
      print('🎨 Loaded ${allSubjects.length} subjects');

      final List<TimetableItem> items = [];

      // Process exams
      for (final exam in exams) {
        final subject = subjectMap[exam.subjectId];
        if (subject == null) {
          print('⚠️ Exam ${exam.id} has no matching subject (subjectId: ${exam.subjectId})');
          continue;
        }

        final examDateTime = _parseDateTime(exam.date, exam.startTime);
        final examEndDateTime = _parseDateTime(exam.date, exam.endTime);

        print('✅ Adding exam: ${exam.name} at ${exam.startTime}-${exam.endTime}');

        items.add(TimetableItem(
          id: exam.id,
          subjectId: exam.subjectId!,
          subjectName: subject.name,
          subjectColor: Color(int.parse('0xFF${subject.color.substring(1)}')),
          name: exam.name,
          teacherName: null, // TODO: Load teacher name if needed
          building: exam.building,
          room: exam.room,
          startTime: examDateTime,
          endTime: examEndDateTime,
          isExam: true,
        ));
      }

      // Process class templates to find instances that occur today
      for (final template in classTemplates) {
        // Skip templates with null subjectId (orphaned classes)  
        if (template.subjectId == null) {
          print('⚠️ Class ${template.id} (${template.name}) has null subjectId - skipping');
          continue;
        }

        final subject = subjectMap[template.subjectId];
        if (subject == null) {
          print('⚠️ Class ${template.id} has no matching subject (subjectId: ${template.subjectId})');
          continue;
        }

        // Check if today falls within the template's date range
        if (today.isBefore(template.startDate) || today.isAfter(template.endDate)) {
          print('⏭️ Class ${template.name} skipped - outside date range (${template.startDate} to ${template.endDate})');
          continue;
        }

        // Check if today matches the recurrence pattern
        if (_occursOnDate(template.recurrence, startOfDay)) {
          final classStartTime = _parseDateTime(startOfDay, template.startTime);
          final classEndTime = _parseDateTime(startOfDay, template.endTime);

          print('✅ Adding class: ${template.name} at ${template.startTime}-${template.endTime}');

          items.add(TimetableItem(
            id: template.id,
            subjectId: template.subjectId!,
            subjectName: subject.name,
            subjectColor: Color(int.parse('0xFF${subject.color.substring(1)}')),
            name: template.name,
            teacherName: null, // TODO: Load teacher name if needed
            building: template.building,
            room: template.room,
            startTime: classStartTime,
            endTime: classEndTime,
            isExam: false,
            classIcon: _getIconFromString(template.icon),
          ));
        } else {
          print('⏭️ Class ${template.name} skipped - does not match recurrence for today (day: ${startOfDay.weekday})');
        }
      }

      print('🎯 Total items before filtering: ${items.length}');

      // Filter out past items and sort chronologically
      _timetableItems = items
          .where((item) => !item.isPast)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

      print('📋 Final timetable items: ${_timetableItems.length}');

      notifyListeners();
    } catch (e) {
      print('Error loading timetable: $e');
    }
  }

  DateTime _parseDateTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool _occursOnDate(Recurrence recurrence, DateTime date) {
    // For weekly recurrence, check if the day of week matches
    if (recurrence.unit == 'weeks') {
      final dayOfWeek = date.weekday % 7; // Convert to 0=Sunday format
      final occurs = recurrence.selectedDays.contains(dayOfWeek);
      print('🔍 Checking weekly recurrence: date.weekday=${date.weekday}, dayOfWeek=$dayOfWeek, selectedDays=${recurrence.selectedDays}, occurs=$occurs');
      return occurs;
    }

    // TODO: Implement other recurrence patterns (days, working_days, etc.)
    print('⚠️ Unsupported recurrence unit: ${recurrence.unit}');
    return false;
  }

  IconData _getIconFromString(String iconName) {
    // Map icon names to actual icons
    switch (iconName) {
      case 'chalkboard':
        return AppIcons.chalkboard;
      case 'exam':
        return AppIcons.exam;
      default:
        return AppIcons.chalkboard;
    }
  }
}