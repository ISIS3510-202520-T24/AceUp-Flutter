import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/planner/subject_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditSubjectViewState { idle, loading, saving, error }

class EditSubjectViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AcademicRepository _repository;
  final _uuid = const Uuid();
  final String termId;
  final String? subjectId;

  EditSubjectViewState _state = EditSubjectViewState.idle;
  EditSubjectViewState get state => _state;

  Subject? _subject;
  Subject? get subject => _subject;

  bool get isEditMode => subjectId != null;

  late TextEditingController nameController;

  String _selectedColor = '#4CAF50';
  String get selectedColor => _selectedColor;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

    // Predefined color palette
  final List<String> colorOptions = [
    '#E57373', // Red
    '#F06292', // Pink
    '#BA68C8', // Purple
    '#9575CD', // Deep Purple
    '#7986CB', // Indigo
    '#64B5F6', // Blue
    '#4FC3F7', // Light Blue
    '#4DD0E1', // Cyan
    '#4DB6AC', // Teal
    '#81C784', // Green
    '#AED581', // Light Green
    '#FFD54F', // Amber
    '#FFB74D', // Orange
    '#FF8A65', // Deep Orange
    '#A1887F', // Brown
    '#90A4AE', // Blue Grey
  ];

  EditSubjectViewModel({
    this.subjectId,
    required this.termId,
    AuthService? authService,
    required AcademicRepository repository,
  })  : _authService = authService ?? AuthService(),
        _repository = repository {
    _initializeControllers();
    if (isEditMode) {
      _loadExistingSubject();
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
  }

  Future<void> _loadExistingSubject() async {
    if (subjectId == null) return;

    _state = EditSubjectViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditSubjectViewState.error;
      notifyListeners();
      return;
    }

    try {
      _subject = await _repository.getSubjectById(subjectId!);

      if (_subject != null) {
        _subject = subject;
        nameController.text = _subject!.name;
        _selectedColor = colorOptions[0];
        
        _state = EditSubjectViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Subject not found';
        _state = EditSubjectViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load subject: $e';
      _state = EditSubjectViewState.error;
      print('Error loading subject: $e');
    }

    notifyListeners();
  }

  void setColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  bool get canSave {
    return nameController.text.trim().isNotEmpty;
  }

  Future<bool> saveSubject() async {
    if (!canSave) return false;

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    _state = EditSubjectViewState.saving;
    notifyListeners();

    try {
      final id = subjectId ?? _uuid.v4();
      final now = DateTime.now();

      final subject = Subject(
        id: id,
        name: nameController.text.trim(),
        color: _selectedColor,
        credits: 3,
        weights: _subject?.weights ?? [],
        finalGrade: _subject?.finalGrade,
        useFinalGradeOverride: _subject?.useFinalGradeOverride ?? false,
        createdAt: _subject?.createdAt ?? now,
        updatedAt: now,
        termId: termId,
      );

      await _repository.saveSubject(subject, userId, termId);

      _state = EditSubjectViewState.idle;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save subject: $e';
      _state = EditSubjectViewState.error;
      notifyListeners();
      print('Error saving subject: $e');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}