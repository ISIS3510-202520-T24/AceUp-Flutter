import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist

import '../../core/constants/enums.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/helpers/recurrence_model.dart';
import '../../models/planner/class_template_model.dart';
import '../../services/auth/auth_service.dart';
import '../../themes/app_icons.dart';

// ignore_for_file: creation_with_non_type

class EditClassViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AcademicRepository _academicRepo;
  final TeacherRepository _teacherRepo;
  final _uuid = const Uuid();
  final String? classTemplateId;
  final String? subjectId;
  final String? termId;

  EditViewState _state = EditViewState.idle;
  EditViewState get state => _state;

  ClassTemplate? _classTemplate;
  ClassTemplate? get classTemplate => _classTemplate;

  bool get isEditMode => classTemplateId != null;
  bool get isCreateMode => classTemplateId == null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form controllers
  late TextEditingController nameController;
  late TextEditingController buildingController;
  late TextEditingController roomController;

  // Subject selection
  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;

  String? _selectedTermId;
  String? _selectedSubjectId;

  List<SubjectOption> _subjects = [];
  List<SubjectOption> get subjects => _subjects;

  // Icon selection
  IconData _selectedIcon = AppIcons.chalkboard;
  IconData get selectedIcon => _selectedIcon;

  String _selectedIconName = 'chalkboard';
  String get selectedIconName => _selectedIconName;

  // Date and time
  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  DateTime get endDate => _endDate;

  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get startTime => _startTime;

  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay get endTime => _endTime;

  // Recurrence
  int _recurrenceInterval = 1;
  int get recurrenceInterval => _recurrenceInterval;

  RecurrenceUnit _recurrenceUnit = RecurrenceUnit.weeks;
  RecurrenceUnit get recurrenceUnit => _recurrenceUnit;

  List<int> _selectedDays = [1]; // Monday by default
  List<int> get selectedDays => _selectedDays;

  // Teacher selection
  String? _selectedTeacherId;
  String? get selectedTeacherId => _selectedTeacherId;

  String? _selectedTeacherName;
  String? get selectedTeacherName => _selectedTeacherName;

  List<TeacherOption> _teachers = [];
  List<TeacherOption> get teachers => _teachers;

  // Class icon options (from AppIcons after line 52)
  static final List<ClassIconOption> classIcons = [
    // Arts
    ClassIconOption(name: 'art', icon: AppIcons.art, label: 'Art'),
    ClassIconOption(name: 'music', icon: AppIcons.music, label: 'Music'),
    ClassIconOption(name: 'theatre', icon: AppIcons.theatre, label: 'Theatre'),
    ClassIconOption(name: 'film', icon: AppIcons.film, label: 'Film'),
    // Humanities
    ClassIconOption(name: 'history', icon: AppIcons.history, label: 'History'),
    ClassIconOption(name: 'language', icon: AppIcons.language, label: 'Language'),
    ClassIconOption(name: 'law', icon: AppIcons.law, label: 'Law'),
    // Life forms
    ClassIconOption(name: 'plant', icon: AppIcons.plant, label: 'Plant'),
    ClassIconOption(name: 'paw', icon: AppIcons.paw, label: 'Paw'),
    // STEM
    ClassIconOption(name: 'laptop', icon: AppIcons.laptop, label: 'Laptop'),
    ClassIconOption(name: 'laptopCode', icon: AppIcons.laptopCode, label: 'Coding'),
    ClassIconOption(name: 'code', icon: AppIcons.code, label: 'Code'),
    ClassIconOption(name: 'math', icon: AppIcons.math, label: 'Math'),
    ClassIconOption(name: 'science', icon: AppIcons.science, label: 'Science'),
    // Entertainment
    ClassIconOption(name: 'controller', icon: AppIcons.controller, label: 'Gaming'),
    ClassIconOption(name: 'book', icon: AppIcons.book, label: 'Book'),
    ClassIconOption(name: 'dice', icon: AppIcons.dice, label: 'Dice'),
    // Default
    ClassIconOption(name: 'chalkboard', icon: AppIcons.chalkboard, label: 'Default'),
  ];

  // Recurrence unit options
  static final List<RecurrenceUnitOption> recurrenceUnitOptions = [
    RecurrenceUnitOption(unit: RecurrenceUnit.weeks, label: 'Weeks'),
    RecurrenceUnitOption(unit: RecurrenceUnit.days, label: 'Days'),
    RecurrenceUnitOption(unit: RecurrenceUnit.workingDays, label: 'Work Days'),
    RecurrenceUnitOption(unit: RecurrenceUnit.oddDays, label: 'Odd Days'),
    RecurrenceUnitOption(unit: RecurrenceUnit.evenDays, label: 'Even Days'),
    RecurrenceUnitOption(unit: RecurrenceUnit.oddWorkingDays, label: 'Odd Work Days'),
    RecurrenceUnitOption(unit: RecurrenceUnit.evenWorkingDays, label: 'Even Work Days'),
  ];

  EditClassViewModel({
    this.classTemplateId,
    this.subjectId,
    this.termId,
    AuthService? authService,
    required AcademicRepository academicRepo,
    required TeacherRepository teacherRepo,
  })  : _authService = authService ?? AuthService(),
        _academicRepo = academicRepo,
        _teacherRepo = teacherRepo {
    _initializeControllers();
    _loadSubjects();
    _loadTeachers();
    if (isEditMode) {
      _loadExistingClass();
    } else {
      // Set defaults for create mode
      _selectedTermId = termId;
      _selectedSubjectId = subjectId;
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    buildingController = TextEditingController();
    roomController = TextEditingController();
  }

  Future<void> _loadExistingClass() async {
    if (classTemplateId == null) return;

    _state = EditViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _state = EditViewState.error;
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _classTemplate = await _academicRepo.getClassTemplateById(classTemplateId!);

      if (_classTemplate != null) {
        nameController.text = _classTemplate!.name;
        buildingController.text = _classTemplate!.building ?? '';
        roomController.text = _classTemplate!.room ?? '';

        _selectedTermId = _classTemplate!.termId;
        _selectedSubject = _classTemplate!.subjectName;
        _selectedSubjectId = _classTemplate!.subjectId;
        _selectedTeacherId = _classTemplate!.teacherId;

        // Load icon
        final iconOption = classIcons.where((i) => i.name == _classTemplate!.icon).firstOrNull;
        if (iconOption != null) {
          _selectedIcon = iconOption.icon;
          _selectedIconName = iconOption.name;
        }

        // Load dates
        _startDate = _classTemplate!.startDate;
        _endDate = _classTemplate!.endDate;

        // Load times
        _startTime = _parseTimeString(_classTemplate!.startTime);
        _endTime = _parseTimeString(_classTemplate!.endTime);

        // Load recurrence
        _recurrenceInterval = _classTemplate!.recurrence.interval;
        _recurrenceUnit = _classTemplate!.recurrence.unit;
        _selectedDays = _classTemplate!.recurrence.selectedDays;

        if (_selectedTeacherId != null) {
          final teacher = _teachers.where((t) => t.id == _selectedTeacherId).firstOrNull;
          _selectedTeacherName = teacher?.name;
        }

        _state = EditViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Class not found';
        _state = EditViewState.error;
      }
    } catch (e) {
      _state = EditViewState.error;
      _errorMessage = 'Failed to load class data';
    }

    notifyListeners();
  }

  Future<void> _loadSubjects() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final terms = await _academicRepo.getTermsForUser(userId);

      List<SubjectOption> subjectOptions = [];
      for (var term in terms) {
        final subjects = await _academicRepo.getSubjectsForTerm(term.id);
        for (var subject in subjects) {
          subjectOptions.add(SubjectOption(
            name: subject.name,
            termId: term.id,
            subjectId: subject.id,
          ));
        }
      }

      _subjects = subjectOptions;

      // Set selected subject if in edit mode or if subjectId was provided
      if (isEditMode && _selectedSubjectId != null) {
        final subject = _subjects.where((s) => s.subjectId == _selectedSubjectId).firstOrNull;
        if (subject != null) {
          _selectedSubject = subject.name;
        }
      } else if (isCreateMode && subjectId != null) {
        final subject = _subjects.where((s) => s.subjectId == subjectId).firstOrNull;
        if (subject != null) {
          _selectedSubject = subject.name;
          _selectedSubjectId = subject.subjectId;
          _selectedTermId = subject.termId;
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  void setSubject(String? subjectName) {
    if (subjectName != null) {
      _selectedSubject = subjectName;

      final subject = _subjects.where((s) => s.name == subjectName).firstOrNull;
      if (subject != null) {
        _selectedTermId = subject.termId;
        _selectedSubjectId = subject.subjectId;
      }

      notifyListeners();
    }
  }

  Future<void> _loadTeachers() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final teachers = await _teacherRepo.getTeachersForUser(userId);
      _teachers = teachers
          .map((t) => TeacherOption(
                id: t.id,
                name: t.name,
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading teachers: $e');
    }
  }

  void setTeacher(String? teacherName) {
    if (teacherName != null) {
      _selectedTeacherName = teacherName;
      final teacher = _teachers.where((t) => t.name == teacherName).firstOrNull;
      _selectedTeacherId = teacher?.id;
    } else {
      _selectedTeacherName = null;
      _selectedTeacherId = null;
    }
    notifyListeners();
  }

  void setIcon(String iconName) {
    final iconOption = classIcons.where((i) => i.name == iconName).firstOrNull;
    if (iconOption != null) {
      _selectedIcon = iconOption.icon;
      _selectedIconName = iconOption.name;
      notifyListeners();
    }
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _endTime = time;
    notifyListeners();
  }

  void setRecurrenceInterval(int interval) {
    if (interval >= 1 && interval <= 6) {
      _recurrenceInterval = interval;
      notifyListeners();
    }
  }

  void setRecurrenceUnit(RecurrenceUnit unit) {
    _recurrenceUnit = unit;
    // Clear selectedDays if not weeks
    if (unit != RecurrenceUnit.weeks) {
      _selectedDays = [];
    } else if (_selectedDays.isEmpty) {
      _selectedDays = [1]; // Default to Monday
    }
    notifyListeners();
  }

  void toggleDay(int day) {
    if (_selectedDays.contains(day)) {
      if (_selectedDays.length > 1) {
        // Don't allow removing the last day
        _selectedDays = List.from(_selectedDays)..remove(day);
      }
    } else {
      _selectedDays = List.from(_selectedDays)..add(day);
      _selectedDays.sort();
    }
    notifyListeners();
  }

  bool isDaySelected(int day) {
    return _selectedDays.contains(day);
  }

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('Error parsing time string: $timeString');
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get canSave {
    return nameController.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedSubject!.isNotEmpty;
  }

  Future<bool> saveClassTemplate() async {
    if (!_validateForm()) {
      return false;
    }

    _state = EditViewState.saving;
    _errorMessage = null;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    if (_selectedTermId == null || _selectedSubjectId == null) {
      _errorMessage = 'Please select a valid subject';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    try {
      if (isCreateMode) {
        await _createClassTemplate(userId);
      } else {
        await _updateClassTemplate(userId);
      }

      _state = EditViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save class: $e';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createClassTemplate(String userId) async {
    final now = DateTime.now();
    final classId = _uuid.v4();

    final recurrence = Recurrence(
      interval: _recurrenceInterval,
      unit: _recurrenceUnit,
      selectedDays: _recurrenceUnit == RecurrenceUnit.weeks ? _selectedDays : [],
    );

    final newClassTemplate = ClassTemplate(
      id: classId,
      name: nameController.text.trim(),
      icon: _selectedIconName,
      startDate: _startDate,
      endDate: _endDate,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      recurrence: recurrence,
      building: buildingController.text.trim().isEmpty ? null : buildingController.text.trim(),
      room: roomController.text.trim().isEmpty ? null : roomController.text.trim(),
      teacherId: _selectedTeacherId,
      createdAt: now,
      updatedAt: now,
      termId: _selectedTermId,
      subjectId: _selectedSubjectId,
    );

    await _academicRepo.saveClassTemplate(
      newClassTemplate,
      userId,
      _selectedTermId!,
      _selectedSubjectId!,
    );
  }

  Future<void> _updateClassTemplate(String userId) async {
    if (_classTemplate == null || _classTemplate!.termId == null || _classTemplate!.subjectId == null) {
      throw Exception('Cannot update class: missing termId or subjectId');
    }

    final recurrence = Recurrence(
      interval: _recurrenceInterval,
      unit: _recurrenceUnit,
      selectedDays: _recurrenceUnit == RecurrenceUnit.weeks ? _selectedDays : [],
    );

    final updatedClassTemplate = _classTemplate!.copyWith(
      name: nameController.text.trim(),
      icon: _selectedIconName,
      startDate: _startDate,
      endDate: _endDate,
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      recurrence: recurrence,
      building: buildingController.text.trim().isEmpty ? null : buildingController.text.trim(),
      room: roomController.text.trim().isEmpty ? null : roomController.text.trim(),
      teacherId: _selectedTeacherId,
      updatedAt: DateTime.now(),
    );

    await _academicRepo.saveClassTemplate(
      updatedClassTemplate,
      userId,
      _classTemplate!.termId!,
      _classTemplate!.subjectId!,
    );
  }

  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Class name is required';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _errorMessage = 'Subject is required';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    if (_endDate.isBefore(_startDate)) {
      _errorMessage = 'End date must be after start date';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    // Validate end time is after start time
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      _errorMessage = 'End time must be after start time';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    if (_recurrenceUnit == RecurrenceUnit.weeks && _selectedDays.isEmpty) {
      _errorMessage = 'Please select at least one day';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    nameController.dispose();
    buildingController.dispose();
    roomController.dispose();
    super.dispose();
  }
}

class SubjectOption {
  final String name;
  final String termId;
  final String subjectId;

  SubjectOption({
    required this.name,
    required this.termId,
    required this.subjectId,
  });
}

class TeacherOption {
  final String id;
  final String name;

  TeacherOption({
    required this.id,
    required this.name,
  });
}

class ClassIconOption {
  final String name;
  final IconData icon;
  final String label;

  ClassIconOption({
    required this.name,
    required this.icon,
    required this.label,
  });
}

class RecurrenceUnitOption {
  final RecurrenceUnit unit;
  final String label;

  RecurrenceUnitOption({
    required this.unit,
    required this.label,
  });
}
