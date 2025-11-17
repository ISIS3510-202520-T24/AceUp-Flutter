import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';

enum TermViewState { idle, loading, error }

class TermViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String termId;

  TermViewState _state = TermViewState.idle;
  TermViewState get state => _state;

  Term? _term;
  Term? get term => _term;

  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _termGPA;
  double? get termGPA => _termGPA;

  int _termCredits = 0;
  int get termCredits => _termCredits;

  TermViewModel({required this.termId}) {
    _loadTerm();
  }

  Future<void> _loadTerm() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = TermViewState.error;
      notifyListeners();
      return;
    }

    _state = TermViewState.loading;
    notifyListeners();

    try {
      // Load term
      final termDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .get();

      if (!termDoc.exists) {
        _errorMessage = 'Term not found';
        _state = TermViewState.error;
        notifyListeners();
        return;
      }

      _term = Term.fromFirestore(termDoc);

      // Load subjects
      await _loadSubjects(userId);

      _state = TermViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = TermViewState.error;
      print('Error loading term: $e');
    }

    notifyListeners();
  }

  Future<void> _loadSubjects(String userId) async {
    try {
      final subjectsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .get();

      _subjects = subjectsSnapshot.docs
          .map((doc) => Subject.fromFirestore(doc))
          .toList();

      _calculateTermStats();
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }

  void _calculateTermStats() {
    _termCredits = 0;
    double weightedGPA = 0;

    for (var subject in _subjects) {
      _termCredits += subject.credits;
      // TODO: Calculate actual GPA based on grades when implemented
      // For now, just count credits
    }

    _termGPA = _subjects.isNotEmpty ? 4.15 : 0.0; // Placeholder
  }

  Future<void> refreshTerm() async {
    await _loadTerm();
  }

  Future<void> deleteSubject(String subjectId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .delete();

      await refreshTerm();
    } catch (e) {
      print('Error deleting subject: $e');
    }
  }
}