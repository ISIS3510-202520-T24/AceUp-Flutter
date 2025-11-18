import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/planner/term_model.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditTermViewState { idle, saving, error }

class EditTermViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  EditTermViewState _state = EditTermViewState.idle;
  EditTermViewState get state => _state;

  Term? _term;
  Term? get term => _term;

  bool get isEditMode => _term != null;

  late TextEditingController nameController;

  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  DateTime get endDate => _endDate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EditTermViewModel({Term? term}) : _term = term {
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_term != null) {
      nameController = TextEditingController(text: _term!.name);
      _startDate = _term!.startDate ?? DateTime.now();
      _endDate = _term!.endDate ?? DateTime.now().add(const Duration(days: 90));
    } else {
      nameController = TextEditingController();
    }
  }

  void setStartDate(DateTime date) {
    _startDate = date;
    if (_endDate.isBefore(_startDate)) {
      _endDate = _startDate.add(const Duration(days: 90));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  bool get canSave {
    return nameController.text.trim().isNotEmpty &&
        !_endDate.isBefore(_startDate);
  }

  Future<bool> saveTerm() async {
    if (!canSave) return false;

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    _state = EditTermViewState.saving;
    notifyListeners();

    try {
      final termId = _term?.id ?? _uuid.v4();
      final now = DateTime.now();

      final termData = {
        'userId': userId,
        'name': nameController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate),
        'endDate': Timestamp.fromDate(_endDate),
        'createdAt': Timestamp.fromDate(_term?.createdAt ?? now),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .set(termData, SetOptions(merge: true));

      _state = EditTermViewState.idle;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _state = EditTermViewState.error;
      _errorMessage = e.toString();
      print('Error saving term: $e');
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