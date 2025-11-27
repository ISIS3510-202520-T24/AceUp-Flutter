import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist

import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../models/planner/class_template_model.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditClassViewState { idle, loading, saving, error }

class EditClassViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AcademicRepository _academicRepo;
  final TeacherRepository _teacherRepo;
  final _uuid = const Uuid();
  final String? classId;
  final String? subjectId;
  final String? termId;

  EditClassViewState _state = EditClassViewState.idle;
  EditClassViewState get state => _state;

  ClassTemplate? _class;
  ClassTemplate? get classModel => _class;

  bool get isEditMode => classId != null;
  bool get isCreateMode => classId == null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  late TextEditingController nameController;
  late TextEditingController buildingController;
  late TextEditingController roomController;

  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;

  String? _selectedTermId;
  String? _selectedSubjectId;

  String? _selectedTeacherId;
  String? get selectedTeacherId => _selectedTeacherId;

  String? _selectedTeacherName;
  String? get selectedTeacherName => _selectedTeacherName;

  List<SubjectOption> _subjects = [];
  List<SubjectOption> get subjects => _subjects;

  List<TeacherOption> _teachers = [];
  List<TeacherOption> get teachers => _teachers;


  EditClassViewModel({
    this.classId,
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
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    buildingController = TextEditingController();
    roomController = TextEditingController();
  }

  Future<void> _loadExistingClass() async {
    if (classId == null) return;

    _state = EditClassViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _state = EditClassViewState.error;
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _class = await _academicRepo.getClassTemplateById(classId!);

      if (_class != null) {
        nameController.text = _class!.name;
        buildingController.text = _class!.building ?? '';
        roomController.text = _class!.room ?? '';

        _selectedTermId = _class!.termId;
        _selectedSubject = _class!.subjectName;
        _selectedSubjectId = _class!.subjectId;
        _selectedTeacherId = _class!.teacherId;

        if (_selectedTeacherId != null) {
          final teacher = _teachers.where((t) => t.id == _selectedTeacherId).firstOrNull;
          _selectedTeacherName = teacher?.name;
        }

        _state = EditClassViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Class not found';
        _state = EditClassViewState.error;
      }
    } catch (e) {
      _state = EditClassViewState.error;
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

      if (_subjects.isNotEmpty && isCreateMode) {
        _selectedSubject = null;
        _selectedSubjectId = null;
        _selectedTermId = null;
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