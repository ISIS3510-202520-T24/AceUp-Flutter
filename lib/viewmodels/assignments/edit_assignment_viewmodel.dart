import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/assignments/assignment_model.dart';
import '../../models/planner/subject_model.dart';
import '../../models/helpers/weight_model.dart';
import '../../models/helpers/subweight_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants/enums.dart';

// ignore_for_file: creation_with_non_type

class EditAssignmentViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AcademicRepository _repository;
  final _uuid = const Uuid();
  final String? termId;
  final String? subjectId;
  final String? assignmentId;

  EditViewState _state = EditViewState.idle;
  EditViewState get state => _state;

  Assignment? _assignment;
  Assignment? get assignment => _assignment;

  bool get isCreateMode => assignmentId == null;
  bool get isEditMode => assignmentId != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Get validation message based on form state
  String get validationMessage {
    if (titleController.text.trim().isEmpty && (_selectedSubject == null || _selectedSubject!.isEmpty)) {
      return 'Please fill in subject and title to save';
    } else if (titleController.text.trim().isEmpty) {
      return 'Please enter a title';
    } else if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      return 'Please select a subject';
    }
    return 'Fill in all required fields';
  }

  // Form fields
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController gradeController;

  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;

  String? _selectedTermId;
  String? _selectedSubjectId;

  DateTime _selectedDueDate = DateTime.now();
  DateTime get selectedDueDate => _selectedDueDate;

  TimeOfDay _selectedDueTime = TimeOfDay.now();
  TimeOfDay get selectedDueTime => _selectedDueTime;

  DateTime? _selectedReminderDate;
  DateTime? get selectedReminderDate => _selectedReminderDate;

  TimeOfDay? _selectedReminderTime;
  TimeOfDay? get selectedReminderTime => _selectedReminderTime;

  String? _selectedWeightId;
  String? get selectedWeightId => _selectedWeightId;

  /// Get the display name of the currently selected weight
  String? get selectedWeightDisplayName {
    if (_selectedWeightId == null) return null;
    final option = _weightOptions.where((w) => w.id == _selectedWeightId).firstOrNull;
    return option?.displayName;
  }

  String _selectedPriority = 'Medium';
  String get selectedPriority => _selectedPriority;

  bool _isGraded = false;
  bool get isGraded => _isGraded;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  // Available options
  List<SubjectOption> _subjects = [];
  List<SubjectOption> get subjects => _subjects;

  List<WeightOption> _weightOptions = [];
  List<WeightOption> get weightOptions => _weightOptions;

  final List<String> priorities = ['High', 'Medium', 'Low'];

  EditAssignmentViewModel({
    this.assignmentId,
    this.subjectId,
    this.termId,
    AuthService? authService,
    required AcademicRepository repository,
  })  : _authService = authService ?? AuthService(),
        _repository = repository {
    _initializeControllers();
    _loadSubjects();
    if (isEditMode) {
      _loadExistingAssignment();
    }
  }

  void _initializeControllers() {
      titleController = TextEditingController();
      descriptionController = TextEditingController();
      gradeController = TextEditingController();

      // Set default due date to tomorrow at 11:59 PM
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _selectedDueDate = tomorrow;
      _selectedDueTime = const TimeOfDay(hour: 23, minute: 59);
  }

  Future<void> _loadExistingAssignment() async {
    if (assignmentId == null) return;

    _state = EditViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditViewState.error;
      notifyListeners();
      return;
    }

    try {
      _assignment = await _repository.getAssignmentById(assignmentId!);

      if (_assignment != null) {
        titleController.text = _assignment!.title;
        descriptionController.text = _assignment!.description ?? '';
        gradeController.text = _assignment!.grade != null && _assignment!.grade! > 0
            ? _assignment!.grade.toString()
            : '';

        _selectedTermId = _assignment!.termId;
        _selectedSubject = _assignment!.subjectName;
        _selectedSubjectId = _assignment!.subjectId;
        _isCompleted = _assignment!.isCompleted;
        _selectedDueDate = _assignment!.dueDate;
        _selectedDueTime = TimeOfDay.fromDateTime(_assignment!.dueDate);
        _selectedWeightId = _assignment!.weightId;
        _selectedPriority = _assignment!.priority.value;
        _isGraded = _assignment!.grade != null && _assignment!.grade! > 0;

        if (_selectedSubjectId != null) {
          await _loadWeightOptionsForSubject(_selectedSubjectId!);
        }

        _state = EditViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Assignment not found';
        _state = EditViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load assignment: $e';
      _state = EditViewState.error;
      print('Error loading assignment: $e');
    }

    notifyListeners();
  }

  Future<void> _loadSubjects() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final terms = await _repository.getTermsForUser(userId);

      List<SubjectOption> subjectOptions = [];
      for (var term in terms) {
        final subjects = await _repository.getSubjectsForTerm(term.id);
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
        _selectedTermId = null;
        _selectedSubjectId = null;
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

      // Load weight options for the selected subject
      await _loadWeightOptionsForSubject(subject.subjectId);

      notifyListeners();
    }
  }

  /// Load weight options from the selected subject
  Future<void> _loadWeightOptionsForSubject(String subjectId) async {
    try {
      final subject = await _repository.getSubjectById(subjectId);
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

  void setDueDate(DateTime date) {
    _selectedDueDate = date;
    notifyListeners();
  }

  void setDueTime(TimeOfDay time) {
    _selectedDueTime = time;
    notifyListeners();
  }

  void setReminderDate(DateTime? date) {
    _selectedReminderDate = date;
    notifyListeners();
  }

  void setReminderTime(TimeOfDay? time) {
    _selectedReminderTime = time;
    notifyListeners();
  }

  void setWeightId(String? weightId) {
    _selectedWeightId = weightId;
    notifyListeners();
  }

  /// Set weight by display name (for UI dropdown binding)
  void setWeightByDisplayName(String? displayName) {
    if (displayName == null) {
      _selectedWeightId = null;
    } else {
      final option = _weightOptions.where((w) => w.displayName == displayName).firstOrNull;
      _selectedWeightId = option?.id;
    }
    notifyListeners();
  }

  void setPriority(String priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void toggleGraded() {
    _isGraded = !_isGraded;
    if (!_isGraded) {
      gradeController.clear();
    }
    notifyListeners();
  }

  void toggleCompleted() {
    if (_assignment != null) {
      _isCompleted = !_isCompleted;
      notifyListeners();
    }
  }

  DateTime get combinedDueDateTime {
    return DateTime(
      _selectedDueDate.year,
      _selectedDueDate.month,
      _selectedDueDate.day,
      _selectedDueTime.hour,
      _selectedDueTime.minute,
    );
  }

  bool get canSave {
    return titleController.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedSubject!.isNotEmpty;
  }

  Future<bool> saveAssignment() async {
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
        // Create new assignment
        await _createAssignment(userId);
      } else {
        // Update existing assignment
        await _updateAssignment(userId);
      }

      _state = EditViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save assignment: $e';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createAssignment(String userId) async {
    final now = DateTime.now();
    final assignmentId = _uuid.v4();

    final newAssignment = Assignment(
      id: assignmentId,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: combinedDueDateTime,
      weightId: _selectedWeightId,
      priority: Priority.fromString(_selectedPriority.toLowerCase()),
      isCompleted: false,
      isGraded: false,
      createdAt: now,
      updatedAt: now,
      termId: _selectedTermId,
      subjectId: _selectedSubjectId,
    );

    // Save via repository (offline-first with proper nested paths)
    await _repository.saveAssignment(
      newAssignment,
      userId,
      _selectedTermId!,
      _selectedSubjectId!,
    );
  }

  Future<void> _updateAssignment(String userId) async {
    if (_assignment == null || _assignment!.termId == null || _assignment!.subjectId == null) {
      throw Exception('Cannot update assignment: missing termId or subjectId');
    }

    final updatedAssignment = _assignment!.copyWith(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: combinedDueDateTime,
      weightId: _selectedWeightId,
      priority: Priority.fromString(_selectedPriority.toLowerCase()),
      grade: _isGraded && gradeController.text.isNotEmpty
          ? double.tryParse(gradeController.text)
          : null,
      isCompleted: _isCompleted,
      isGraded: _isGraded,
      updatedAt: DateTime.now(),
    );

    // Save via repository (offline-first with proper nested paths)
    await _repository.saveAssignment(
      updatedAssignment,
      userId,
      _assignment!.termId!,
      _assignment!.subjectId!,
    );
  }

  bool _validateForm() {
    // Title is required
    if (titleController.text.trim().isEmpty) {
      _errorMessage = 'Title is required';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    // Subject is required
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _errorMessage = 'Subject is required';
      _state = EditViewState.error;
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    gradeController.dispose();
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