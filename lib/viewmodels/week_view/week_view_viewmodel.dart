import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../models/planner/class_template_model.dart';
import '../../services/auth/auth_service.dart';


enum WeekViewViewState { idle, loading, error}

class WeekViewViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final AcademicRepository _repository;

  WeekViewViewState _state = WeekViewViewState.idle;
  WeekViewViewState get state => _state;


  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ClassTemplate> _classes = [];

  List<WeeklyClassOccurrence> get weeklyOccurrences {
    final occurrences = <WeeklyClassOccurrence>[];
    
    for (final classTemplate in _classes) {
      final classOccurrences = _generateOccurrencesForClass(classTemplate);
      occurrences.addAll(classOccurrences);
    }
    
    return occurrences;
  }

  WeekViewViewModel({
    required AcademicRepository repository,
  })  : _repository = repository {
    _loadWeekView();
  }

  Future<void> _loadWeekView() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = WeekViewViewState.error;
      notifyListeners();
      return;
    }

    _state = WeekViewViewState.loading;
    notifyListeners();

    try {
      final terms = await _repository.getTermsForUser(userId);
      final classes = <ClassTemplate>[];

      for (final term in terms) {
        final subjects = await _repository.getSubjectsForTerm(term.id);
        
        for (final subject in subjects) {
          final classes = await _repository.getClassTemplatesForSubject(subject.id);

          // Add subject name to each class for display
          final classesWithSubject = classes.map((c) => 
            c.copyWith(
              subjectName: subject.name,
              subjectId: subject.id,
              termId: term.id,
            )
          ).toList();
          
          classes.addAll(classesWithSubject);
        }
      }

      _classes = classes;
      _state = WeekViewViewState.idle;
    } catch (e) {
      _errorMessage = 'Failed to load classes';
      _state = WeekViewViewState.error;
    }
  }

  List<WeeklyClassOccurrence> _generateOccurrencesForClass(ClassTemplate classTemplate) {
    final occurrences = <WeeklyClassOccurrence>[];
    final recurrence = classTemplate.recurrence;

    switch (recurrence.unit) {
      case RecurrenceUnit.weeks:
        // For weekly recurrence, create occurrences for selected days
        for (final day in recurrence.selectedDays) {
          occurrences.add(WeeklyClassOccurrence(
            weekday: day == 0 ? 7 : day, // Convert Sunday from 0 to 7
            classTemplate: classTemplate,
          ));
        }
        break;

      case RecurrenceUnit.days:
        // Every N days - show all 7 days
        for (int day = 1; day <= 7; day++) {
          occurrences.add(WeeklyClassOccurrence(
            weekday: day,
            classTemplate: classTemplate,
          ));
        }
        break;

      case RecurrenceUnit.workingDays:
        // Monday to Friday
        for (int day = 1; day <= 5; day++) {
          occurrences.add(WeeklyClassOccurrence(
            weekday: day,
            classTemplate: classTemplate,
          ));
        }
        break;

      case RecurrenceUnit.oddDays:
      case RecurrenceUnit.evenDays:
      case RecurrenceUnit.oddWorkingDays:
      case RecurrenceUnit.evenWorkingDays:
        // For odd/even patterns, show Monday to Friday
        // The actual filtering would require date context
        for (int day = 1; day <= 5; day++) {
          occurrences.add(WeeklyClassOccurrence(
            weekday: day,
            classTemplate: classTemplate,
          ));
        }
        break;
    }

    return occurrences;
  }

  Future<void> refreshWeekView() async {
    await _loadWeekView();
    notifyListeners();
  }
}

class WeeklyClassOccurrence {
  final int weekday; // 1 = Monday, 7 = Sunday
  final ClassTemplate classTemplate;

  WeeklyClassOccurrence({
    required this.weekday,
    required this.classTemplate,
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
}
