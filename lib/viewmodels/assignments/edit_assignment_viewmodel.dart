import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditAssignmentViewState { idle, loading, saving, error }

class EditAssignmentViewModel extends ChangeNotifier {
  final AcademicRepository _repository;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  EditAssignmentViewState _state = EditAssignmentViewState.idle;
  EditAssignmentViewState get state => _state;

  Assignment? _assignment;
  Assignment? get assignment => _assignment;

  bool get isCreateMode => _assignment == null;
  bool get isEditMode => _assignment != null;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  int _selectedWeight = 10;
  int get selectedWeight => _selectedWeight;

  String _selectedPriority = 'Medium';
  String get selectedPriority => _selectedPriority;

  bool _isGraded = false;
  bool get isGraded => _isGraded;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  // Available options
  List<SubjectOption> _subjects = [];
  List<SubjectOption> get subjects => _subjects;

  final List<String> priorities = ['High', 'Medium', 'Low'];
  final List<int> weights = List.generate(20, (index) => (index + 1) * 5); // 5, 10, 15, ..., 100

  EditAssignmentViewModel({
    required AcademicRepository repository,
    Assignment? assignment,
  })  : _repository = repository,
        _assignment = assignment {
    _initializeControllers();
    _loadSubjects();
  }

  void _initializeControllers() {
    if (_assignment != null) {
      // Edit mode - populate with existing data
      titleController = TextEditingController(text: _assignment!.title);
      descriptionController = TextEditingController(text: _assignment!.description);
      gradeController = TextEditingController(
          text: _assignment!.grade > 0 ? _assignment!.grade.toString() : '');

      _selectedSubject = _assignment!.subjectName;
      _selectedTermId = _assignment!.termId;
      _selectedSubjectId = _assignment!.subjectId;
      _isCompleted = _assignment!.status == 'Completed';
      _selectedDueDate = _assignment!.dueDate;
      _selectedDueTime = TimeOfDay.fromDateTime(_assignment!.dueDate);
      _selectedWeight = _assignment!.weight;
      _selectedPriority = _assignment!.priority;
      _isGraded = _assignment!.grade > 0;
    } else {
      // Create mode - empty controllers
      titleController = TextEditingController();
      descriptionController = TextEditingController();
      gradeController = TextEditingController();

      // Set default due date to tomorrow at current time
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _selectedDueDate = tomorrow;
      _selectedDueTime = TimeOfDay.now();
    }
  }

  Future<void> _loadSubjects() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final termsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();

      List<SubjectOption> subjectOptions = [];
      for (var termDoc in termsSnapshot.docs) {
        final subjectsSnapshot = await termDoc.reference.collection('subjects').get();
        for (var subjectDoc in subjectsSnapshot.docs) {
          final subjectData = subjectDoc.data();
          final subjectName = subjectData['name'] ?? 'Unknown Subject';

          subjectOptions.add(SubjectOption(
            name: subjectName,
            termId: termDoc.id,
            subjectId: subjectDoc.id,
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

  void setSubject(String? subjectName) {
    if (subjectName != null) {
      _selectedSubject = subjectName;

      // Find and set the corresponding term and subject IDs
      final subject = _subjects.firstWhere(
            (s) => s.name == subjectName,
        orElse: () => _subjects.first,
      );

      _selectedTermId = subject.termId;
      _selectedSubjectId = subject.subjectId;

      notifyListeners();
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

  void setWeight(int weight) {
    _selectedWeight = weight;
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

  void toggleAssignmentStatus() {
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

  // Validation - required for create mode
  bool get canSave {
    return titleController.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedSubject!.isNotEmpty;
  }

  Future<bool> saveAssignment() async {
    if (!_validateForm()) {
      return false;
    }

    _state = EditAssignmentViewState.saving;
    _errorMessage = null;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditAssignmentViewState.error;
      notifyListeners();
      return false;
    }

    if (_selectedTermId == null || _selectedSubjectId == null) {
      _errorMessage = 'Please select a valid subject';
      _state = EditAssignmentViewState.error;
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

      _state = EditAssignmentViewState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save assignment: $e';
      _state = EditAssignmentViewState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> _createAssignment(String userId) async {
    final assignmentData = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'dueDate': Timestamp.fromDate(combinedDueDateTime),
      'priority': _selectedPriority,
      'weight': _selectedWeight,
      'grade': 0,
      'status': 'Pending',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('terms')
        .doc(_selectedTermId)
        .collection('subjects')
        .doc(_selectedSubjectId)
        .collection('assignments')
        .add(assignmentData);
  }

  Future<void> _updateAssignment(String userId) async {
    final updatedData = {
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'dueDate': Timestamp.fromDate(combinedDueDateTime),
      'priority': _selectedPriority,
      'weight': _selectedWeight,
      'grade': _isGraded && gradeController.text.isNotEmpty
          ? int.tryParse(gradeController.text) ?? 0
          : 0,
      'updatedAt': Timestamp.now(),
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('terms')
        .doc(_assignment!.termId)
        .collection('subjects')
        .doc(_assignment!.subjectId)
        .collection('assignments')
        .doc(_assignment!.id)
        .update(updatedData);
  }

  bool _validateForm() {
    // Title is required
    if (titleController.text.trim().isEmpty) {
      _errorMessage = 'Title is required';
      _state = EditAssignmentViewState.error;
      notifyListeners();
      return false;
    }

    // Subject is required
    if (_selectedSubject == null || _selectedSubject!.isEmpty) {
      _errorMessage = 'Subject is required';
      _state = EditAssignmentViewState.error;
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