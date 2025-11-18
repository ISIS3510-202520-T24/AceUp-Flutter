import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../services/auth/auth_service.dart';

enum PlannerViewState { idle, loading, error }

class PlannerViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PlannerViewState _state = PlannerViewState.idle;
  PlannerViewState get state => _state;

  List<Term> _terms = [];
  List<Term> get terms => _terms;

  Map<String, List<Subject>> _termSubjects = {};
  Map<String, double> _termGPAs = {};
  Map<String, int> _termCredits = {};

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  double? _overallGPA;
  double? get overallGPA => _overallGPA;

  int _totalCredits = 0;
  int get totalCredits => _totalCredits;

  PlannerViewModel() {
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _state = PlannerViewState.error;
      notifyListeners();
      return;
    }

    _state = PlannerViewState.loading;
    notifyListeners();

    try {
      final termsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .orderBy('startDate', descending: true)
          .get();

      _terms = termsSnapshot.docs.map((doc) => Term.fromFirestore(doc)).toList();

      // Load subjects for each term
      for (var term in _terms) {
        await _loadTermSubjects(userId, term.id);
      }

      _calculateOverallGPA();
      _state = PlannerViewState.idle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _state = PlannerViewState.error;
      print('Error loading terms: $e');
    }

    notifyListeners();
  }

  Future<void> _loadTermSubjects(String userId, String termId) async {
    try {
      final subjectsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .get();

      final subjects = subjectsSnapshot.docs
          .map((doc) => Subject.fromFirestore(doc))
          .toList();

      _termSubjects[termId] = subjects;

      // Calculate term GPA and credits
      _calculateTermStats(termId, subjects);
    } catch (e) {
      print('Error loading subjects for term $termId: $e');
    }
  }

  void _calculateTermStats(String termId, List<Subject> subjects) {
    int totalCredits = 0;
    double weightedGPA = 0;

    for (var subject in subjects) {
      totalCredits += subject.credits;
      // TODO: Calculate actual GPA based on grades when implemented
      // For now, just count credits
    }

    _termCredits[termId] = totalCredits;
    _termGPAs[termId] = subjects.isNotEmpty ? 4.15 : 0.0; // Placeholder
  }

  void _calculateOverallGPA() {
    _totalCredits = 0;
    double totalWeightedGPA = 0;

    _termCredits.forEach((termId, credits) {
      _totalCredits += credits;
      totalWeightedGPA += (_termGPAs[termId] ?? 0) * credits;
    });

    _overallGPA = _totalCredits > 0 ? totalWeightedGPA / _totalCredits : 0.0;
  }

  double? getTermGPA(String termId) => _termGPAs[termId];

  int getTermCredits(String termId) => _termCredits[termId] ?? 0;

  String getTermDateRange(Term term) {
    if (term.startDate == null || term.endDate == null) {
      return '';
    }
    final start = _formatDate(term.startDate!);
    final end = _formatDate(term.endDate!);
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Future<void> refreshTerms() async {
    await _loadTerms();
  }

  Future<void> deleteTerm(String termId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .delete();

      await refreshTerms();
    } catch (e) {
      print('Error deleting term: $e');
    }
  }
}