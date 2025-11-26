import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart'; // ignore: uri_does_not_exist
import '../../models/planner/term_model.dart';
import '../../services/auth/auth_service.dart';

// ignore_for_file: creation_with_non_type

enum EditTermViewState { idle, loading, saving, error }

class EditTermViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final String? termId;

  EditTermViewState _state = EditTermViewState.idle;
  EditTermViewState get state => _state;

  Term? _term;
  Term? get term => _term;

  bool get isEditMode => termId != null;

  late TextEditingController nameController;

  DateTime _startDate = DateTime.now();
  DateTime get startDate => _startDate;

  DateTime _endDate = DateTime.now().add(const Duration(days: 90));
  DateTime get endDate => _endDate;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  EditTermViewModel({this.termId}) {
    _initializeControllers();
    if (isEditMode) {
      _loadExistingTerm();
    }
  }

  void _initializeControllers() {
    nameController = TextEditingController();
  }

  Future<void> _loadExistingTerm() async {
    if (termId == null) return;

    _state = EditTermViewState.loading;
    notifyListeners();

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = EditTermViewState.error;
      notifyListeners();
      return;
    }

    try {
      final termDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .get();

      if (termDoc.exists) {
        _term = Term.fromFirestore(termDoc);
        nameController.text = _term!.name;
        _startDate = _term!.startDate;
        _endDate = _term!.endDate;
        
        _state = EditTermViewState.idle;
        _errorMessage = null;
      } else {
        _errorMessage = 'Term not found';
        _state = EditTermViewState.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load term: $e';
      _state = EditTermViewState.error;
      print('Error loading term: $e');
    }

    notifyListeners();
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
      final id = termId ?? _uuid.v4();
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
          .doc(id)
          .set(termData, SetOptions(merge: true));

      _state = EditTermViewState.idle;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save term: $e';
      _state = EditTermViewState.error;
      notifyListeners();
      print('Error saving term: $e');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}