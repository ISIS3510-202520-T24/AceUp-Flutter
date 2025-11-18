import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditSubjectViewState { idle, saving, error }

class EditSubjectViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final String termId;

  EditSubjectViewState _state = EditSubjectViewState.idle;
  EditSubjectViewState get state => _state;

  Subject? _subject;
  Subject? get subject => _subject;

  bool get isEditMode => _subject != null;

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
    required this.termId,
    Subject? subject,
  }) : _subject = subject {
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_subject != null) {
      nameController = TextEditingController(text: _subject!.name);
      _selectedColor = '#4CAF50'; // Default since Subject model doesn't have color yet
    } else {
      nameController = TextEditingController();
      _selectedColor = colorOptions[0];
    }
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
      final subjectId = _subject?.id ?? _uuid.v4();
      final now = DateTime.now();

      final subjectData = {
        'userId': userId,
        'termId': termId,
        'name': nameController.text.trim(),
        'color': _selectedColor,
        'code': null,
        'credits': 3, // Default credits
        'hasCompleteDataForGPA': false,
        'createdAt': Timestamp.fromDate(_subject?.createdAt ?? now),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .set(subjectData, SetOptions(merge: true));

      _state = EditSubjectViewState.idle;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _state = EditSubjectViewState.error;
      _errorMessage = e.toString();
      print('Error saving subject: $e');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}