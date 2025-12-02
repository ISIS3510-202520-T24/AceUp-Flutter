import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/planner/class_exception_model.dart';
import '../../models/holidays/holiday_model.dart';
import '../../services/auth/auth_service.dart';

class WeekViewViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AcademicRepository _repository;
  final HolidayRepository? _holidayRepository;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ClassTemplate> _classes = [];
  Map<String, List<ClassException>> _exceptionsByTemplate = {};
  List<Holiday> _holidays = [];

  // Current week being displayed (Monday of the week)
  DateTime _currentWeekStart = _getMonday(DateTime.now());
  DateTime get currentWeekStart => _currentWeekStart;

  // Get the end of the current week (Friday)
  DateTime get currentWeekEnd => _currentWeekStart.add(const Duration(days: 4));

  WeekViewViewModel({
    required AcademicRepository repository,
    HolidayRepository? holidayRepository,
  })  : _repository = repository,
        _holidayRepository = holidayRepository {
    _loadWeekView();
  }

  /// Get Monday of the week containing the given date
  static DateTime _getMonday(DateTime date) {
    // DateTime.weekday: Monday = 1, Sunday = 7
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  /// Navigate to previous week
  void goToPreviousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    notifyListeners();
  }

  /// Navigate to next week
  void goToNextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    notifyListeners();
  }

  /// Navigate to current week
  void goToCurrentWeek() {
    _currentWeekStart = _getMonday(DateTime.now());
    notifyListeners();
  }

  /// Get all class occurrences for the current week
  List<WeeklyClassOccurrence> get weeklyOccurrences {
    final occurrences = <WeeklyClassOccurrence>[];

    for (final classTemplate in _classes) {
      // Generate occurrences for this template for the current week
      final templateOccurrences = _generateOccurrencesForTemplate(
        classTemplate,
        _currentWeekStart,
        currentWeekEnd,
      );
      occurrences.addAll(templateOccurrences);
    }

    return occurrences;
  }

  Future<void> _loadWeekView() async {
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
      // Load holidays if repository is available
      if (_holidayRepository != null) {
        try {
          _holidays = await _holidayRepository!.getHolidaysForUser(userId);
          print('✅ Loaded ${_holidays.length} holidays for filtering');
        } catch (e) {
          print('⚠️ Failed to load holidays: $e');
          _holidays = [];
        }
      }

      final terms = await _repository.getTermsForUser(userId);
      final allClasses = <ClassTemplate>[];
      final allExceptions = <String, List<ClassException>>{};

      for (final term in terms) {
        final subjects = await _repository.getSubjectsForTerm(term.id);

        for (final subject in subjects) {
          // Fetch class templates for this subject
          final subjectClasses = await _repository.getClassTemplatesForSubject(subject.id);

          // Add subject name to each class for display
          final classesWithSubject = subjectClasses.map((c) =>
            c.copyWith(
              subjectName: subject.name,
              subjectId: subject.id,
              termId: term.id,
            )
          ).toList();

          allClasses.addAll(classesWithSubject);

          // Fetch class exceptions for each template
          for (final classTemplate in subjectClasses) {
            final exceptions = await _repository.getClassExceptionsForTemplate(classTemplate.id);
            if (exceptions.isNotEmpty) {
              allExceptions[classTemplate.id] = exceptions;
            }
          }
        }
      }

      _classes = allClasses;
      _exceptionsByTemplate = allExceptions;
      _state = ViewState.idle;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load classes: $e';
      _state = ViewState.error;
      notifyListeners();
    }
  }

  /// Generate class occurrences for a specific date range
  List<WeeklyClassOccurrence> _generateOccurrencesForTemplate(
    ClassTemplate template,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final occurrences = <WeeklyClassOccurrence>[];
    final recurrence = template.recurrence;

    // Only generate occurrences if the template's date range overlaps with the requested range
    if (template.endDate.isBefore(rangeStart) || template.startDate.isAfter(rangeEnd)) {
      return occurrences;
    }

    // Generate dates based on recurrence pattern
    DateTime currentDate = rangeStart.isAfter(template.startDate) ? rangeStart : template.startDate;
    final effectiveEndDate = rangeEnd.isBefore(template.endDate) ? rangeEnd : template.endDate;

    while (currentDate.isBefore(effectiveEndDate) || _isSameDay(currentDate, effectiveEndDate)) {
      bool shouldInclude = false;

      switch (recurrence.unit) {
        case RecurrenceUnit.weeks:
          // Check if current day of week is in selected days
          final weekday = currentDate.weekday == 7 ? 0 : currentDate.weekday; // Convert Sunday to 0
          shouldInclude = recurrence.selectedDays.contains(weekday);
          break;

        case RecurrenceUnit.days:
          // Every N days from start date
          final daysDiff = currentDate.difference(template.startDate).inDays;
          shouldInclude = daysDiff % recurrence.interval == 0;
          break;

        case RecurrenceUnit.workingDays:
          // Monday to Friday, every N working days
          if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
            final workingDaysSinceStart = _countWorkingDays(template.startDate, currentDate);
            shouldInclude = workingDaysSinceStart % recurrence.interval == 0;
          }
          break;

        case RecurrenceUnit.oddDays:
          // Only odd calendar days
          shouldInclude = currentDate.day % 2 == 1;
          break;

        case RecurrenceUnit.evenDays:
          // Only even calendar days
          shouldInclude = currentDate.day % 2 == 0;
          break;

        case RecurrenceUnit.oddWorkingDays:
          // Only odd calendar days, Monday-Friday
          shouldInclude = (currentDate.weekday >= 1 && currentDate.weekday <= 5) &&
                         (currentDate.day % 2 == 1);
          break;

        case RecurrenceUnit.evenWorkingDays:
          // Only even calendar days, Monday-Friday
          shouldInclude = (currentDate.weekday >= 1 && currentDate.weekday <= 5) &&
                         (currentDate.day % 2 == 0);
          break;
      }

      if (shouldInclude) {
        // Check if this occurrence is cancelled by an exception
        final exception = _getExceptionForDate(template.id, currentDate);

        // Check if this date is a holiday
        final isHoliday = _isDateInHoliday(currentDate);

        if ((exception == null || !exception.isCancelled) && !isHoliday) {
          // Create occurrence (only if not cancelled and not a holiday)
          occurrences.add(WeeklyClassOccurrence(
            date: currentDate,
            weekday: currentDate.weekday,
            classTemplate: template,
            notes: exception?.notes,
          ));
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return occurrences;
  }

  /// Get class exception for a specific date
  ClassException? _getExceptionForDate(String templateId, DateTime date) {
    final exceptions = _exceptionsByTemplate[templateId];
    if (exceptions == null) return null;

    for (final exception in exceptions) {
      if (_isSameDay(exception.date, date)) {
        return exception;
      }
    }
    return null;
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Count working days between two dates
  int _countWorkingDays(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = start;

    while (current.isBefore(end) || _isSameDay(current, end)) {
      if (current.weekday >= 1 && current.weekday <= 5) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  Future<void> refreshWeekView() async {
    await _loadWeekView();
  }

  /// Check if a date falls on any holiday
  bool _isDateInHoliday(DateTime date) {
    for (final holiday in _holidays) {
      if (holiday.containsDate(date)) {
        return true;
      }
    }
    return false;
  }
}

class WeeklyClassOccurrence {
  final DateTime date;
  final int weekday; // 1 = Monday, 7 = Sunday
  final ClassTemplate classTemplate;
  final String? notes; // Notes from class exception

  WeeklyClassOccurrence({
    required this.date,
    required this.weekday,
    required this.classTemplate,
    this.notes,
  });

  /// Parse start time to minutes since midnight
  int get startMinutes {
    final parts = classTemplate.startTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Parse end time to minutes since midnight
  int get endMinutes {
    final parts = classTemplate.endTime.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String get title => classTemplate.name;
  String? get subjectName => classTemplate.subjectName;
  String get location => classTemplate.location;

  /// Check if this occurrence has notes from an exception
  bool get hasNotes => notes != null && notes!.isNotEmpty;
}
