import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist

import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/planner/exam_model.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants/enums.dart';

class EditExamViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AcademicRepository _academicRepo;
  final TeacherRepository _teacherRepo;
  final _uuid = const Uuid(); // ignore: creation_with_non_type
  final String? termId;
  final String? subjectId;
  final String? examId;

  EditViewState _state = EditViewState.idle;
  EditViewState get state => _state;

  Exam? _exam;
  Exam? get exam => _exam;

  bool get isCreateMode => examId == null;
  bool get isEditMode => examId != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late TextEditingController titleController;
  late TextEditingController gradeController;
  late TextEditingController buildingController;
  late TextEditingController roomController;

  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;

  String? _selectedTermId;
  String? _selectedSubjectId;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TimeOfDay _selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay get selectedStartTime => _selectedStartTime;

  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 11, minute: 0);
  TimeOfDay get selectedEndTime => _selectedEndTime;

  String? _selectedWeightId;
  String? get selectedWeightId => _selectedWeightId;

  String? get selectedWeightDisplayName {
    if (_selectedWeightId == null) return null;
    final option = _weightOptions.where((w) => w.id == _selectedWeightId).firstOrNull;
    return option?.displayName;
  }

  bool _isGraded = false;
  bool get isGraded => _isGraded;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  String? _selectedTeacherId;
  String? get selectedTeacherId => _selectedTeacherId;

  String? _selectedTeacherName;
  String? get selectedTeacherName => _selectedTeacherName;

  List<SubjectOption> _subjects = [];
  List<SubjectOption> get subjects => _subjects;

  List<WeightOption> _weightOptions = [];
  List<WeightOption> get weightOptions => _weightOptions;

  List<TeacherOption> _teachers = [];
  List<TeacherOption> get teachers => _teachers;

  EditExamViewModel({
    this.examId,
    this.subjectId,
    this.termId,
    AuthService? authService,
    required AcademicRepository academicRepo,
    required TeacherRepository teacherRepo,
  })  : _authService = authService ?? AuthService(),
        _academicRepo = academicRepo,
        _teacherRepo = teacherRepo {
    _initializeControllers();

    if (isEditMode) {
      _loadExistingExam();
    } else {
      // Set defaults for create mode
      _selectedTermId = termId;
      _selectedSubjectId = subjectId;
      // Load subjects first, then it will auto-select if subjectId is provided
      _initializeForCreateMode();
    }

    _loadTeachers();
  }

  Future<void> _initializeForCreateMode() async {
    _state = EditViewState.loading;
    notifyListeners();

    await _loadSubjects();

    _state = EditViewState.idle;
    notifyListeners();
  }

  void _initializeControllers() {
    titleController = TextEditingController();
    gradeController = TextEditingController();
    buildingController = TextEditingController();
    roomController = TextEditingController();

    // Set default date to tomorrow
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = tomorrow;
  }

  Future<void> _loadExistingExam() async {
    if (examId == null) return;

    _state = EditViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditViewState.error;
      notifyListeners();
      return;
    }

    try{
      _exam = await _academicRepo.getExamById(examId!);

      if (_exam != null) {
        titleController.text = _exam!.name;
        gradeController.text = _exam!.grade != null && _exam!.grade! > 0
            ? _exam!.grade.toString()
            : '';
        buildingController.text = _exam!.building ?? '';
        roomController.text = _exam!.room ?? '';

        _selectedTermId = _exam!.termId;
        _selectedSubject = _exam!.subjectName;
        _selectedSubjectId = _exam!.subjectId;
        _selectedDate = _exam!.date;
        _selectedStartTime = _parseTimeString(_exam!.startTime);
        _selectedEndTime = _parseTimeString(_exam!.endTime);
        _isCompleted = _exam!.isCompleted;
        _selectedWeightId = _exam!.weightId;
        _isGraded = _exam!.isGraded;
        _selectedTeacherId = _exam!.teacherId;

        if (_selectedTeacherId != null) {
          final teacher = _teachers.where((t) => t.id == _selectedTeacherId).firstOrNull;
          _selectedTeacherName = teacher?.name;
        }

        if (_selectedSubjectId != null) {
          await _loadWeightOptionsForSubject(_selectedSubjectId!);
        }

        _state = EditViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Exam not found';
        _state = EditViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load exam: $e';
      _state = EditViewState.error;
      notifyListeners();
      print('Error loading exam: $e');
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

      // Set selected subject if subjectId was provided in create mode
      if (isCreateMode && subjectId != null) {
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

  void setSubject(String? subjectName) async {
    if (subjectName != null) {
      _selectedSubject = subjectName;

      final subject = _subjects.firstWhere(
            (s) => s.name == subjectName,
        orElse: () => _subjects.first,
      );

      _selectedTermId = subject.termId;
      _selectedSubjectId = subject.subjectId;

      await _loadWeightOptionsForSubject(subject.subjectId);

      notifyListeners();
    }
  }

  Future<void> _loadWeightOptionsForSubject(String subjectId) async {
    try {
      final subject = await _academicRepo.getSubjectById(subjectId);
      if (subject == null) {
        _weightOptions = [];
        return;
      }

      // Build weight options from subject's weights and subweights
      final options = <WeightOption>[];

      for (final weight in subject.weights) {
        // Add the weight itself
        options.add(WeightOption(
          id: weight.id,
          name: weight.name,
          displayName: weight.name,
          percentage: weight.percentage,
          isSubweight: false,
        ));

        // Add all subweights
        for (final subweight in weight.subweights) {
          options.add(WeightOption(
            id: subweight.id,
            name: subweight.name,
            displayName: '${weight.name} > ${subweight.name}',
            percentage: subweight.percentage,
            isSubweight: true,
            parentWeightName: weight.name,
          ));
        }
      }

      _weightOptions = options;
    } catch (e) {
      print('Error loading weight options: $e');
      _weightOptions = [];
    }
  }

  void setWeightId(String? weightId) {
    _selectedWeightId = weightId;
    notifyListeners();
  }

  void setWeightByDisplayName(String? displayName) {
    if (displayName == null) {
      _selectedWeightId = null;
    } else {
      final option = _weightOptions.where((w) => w.displayName == displayName).firstOrNull;
      _selectedWeightId = option?.id;
    }
    notifyListeners();
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

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    _selectedStartTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    _selectedEndTime = time;
    notifyListeners();
  }

  /// Parse HH:mm string to TimeOfDay
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

  /// Convert TimeOfDay to HH:mm string format
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void toggleGraded() {
    _isGraded = !_isGraded;
    if (!_isGraded) {
      gradeController.clear();
    }
    notifyListeners();
  }

  void toggleCompleted() {
    _isCompleted = !_isCompleted;
    notifyListeners();
  }

  bool get canSave {
    return titleController.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedSubject!.isNotEmpty;
  }

  Future<bool> saveExam() async {
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
        await _createExam(userId);
      } else {
        await _updateExam(userId);
      }

      _state = EditViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save exam: $e';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createExam(String userId) async {
    final now = DateTime.now();
    final examId = _uuid.v4();

    final newExam = Exam(
      id: examId,
      name: titleController.text.trim(),
      date: _selectedDate,
      startTime: _formatTimeOfDay(_selectedStartTime),
      endTime: _formatTimeOfDay(_selectedEndTime),
      weightId: _selectedWeightId,
      building: buildingController.text.trim().isEmpty ? null : buildingController.text.trim(),
      room: roomController.text.trim().isEmpty ? null : roomController.text.trim(),
      teacherId: _selectedTeacherId,
      isCompleted: false,
      isGraded: false,
      createdAt: now,
      updatedAt: now,
      termId: _selectedTermId,
      subjectId: _selectedSubjectId,
    );
    await _academicRepo.saveExam(
      newExam,
      userId,
      _selectedTermId!,
      _selectedSubjectId!,
    );
  }

  Future<void> _updateExam(String userId) async {
    if (_exam == null || _exam!.termId == null || _exam!.subjectId == null) {
      throw Exception('Cannot update exam: missing termId or subjectId');
    }

    final updatedExam = _exam!.copyWith(
      name: titleController.text.trim(),
      date: _selectedDate,
      startTime: _formatTimeOfDay(_selectedStartTime),
      endTime: _formatTimeOfDay(_selectedEndTime),
      weightId: _selectedWeightId,
      building: buildingController.text.trim().isEmpty ? null : buildingController.text.trim(),
      room: roomController.text.trim().isEmpty ? null : roomController.text.trim(),
      teacherId: _selectedTeacherId,
      grade: _isGraded && gradeController.text.isNotEmpty
          ? double.tryParse(gradeController.text)
          : null,
      isGraded: _isGraded,
      isCompleted: _isCompleted,
      completedAt: _isCompleted ? (_exam!.completedAt ?? DateTime.now()) : null,
      updatedAt: DateTime.now(),
    );

    await _academicRepo.saveExam(
      updatedExam,
      userId,
      _exam!.termId!,
      _exam!.subjectId!,
    );
  }

  bool _validateForm() {
    if (titleController.text.trim().isEmpty) {
      _errorMessage = 'Title is required';
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

    // Validate end time is after start time
    final startMinutes = _selectedStartTime.hour * 60 + _selectedStartTime.minute;
    final endMinutes = _selectedEndTime.hour * 60 + _selectedEndTime.minute;

    if (endMinutes <= startMinutes) {
      _errorMessage = 'End time must be after start time';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    gradeController.dispose();
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

class WeightOption {
  final String id;
  final String name;
  final String displayName;
  final double percentage;
  final bool isSubweight;
  final String? parentWeightName;

  WeightOption({
    required this.id,
    required this.name,
    required this.displayName,
    required this.percentage,
    required this.isSubweight,
    this.parentWeightName,
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