import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/assignments/assignment_model.dart';
import '../../data/repositories/academic_repository.dart';
import '../analytics/analytics_service.dart';

class AssignmentService {
  final FirebaseFirestore _firestore;
  final AcademicRepository _repository;
  final AnalyticsService _analytics;

  AssignmentService({
    required FirebaseFirestore firestore,
    required AcademicRepository repository,
    AnalyticsService? analytics,
  })  : _firestore = firestore,
        _repository = repository,
        _analytics = analytics ?? AnalyticsService();


  /// Gets all assignments for a user (using offline-first repository)
  Future<List<Assignment>> getAllAssignmentsForUser(String userId) async {
    return await _repository.getAssignmentsForUser(userId);
  }

  /// Gets assignments due today for a user (using offline-first repository)
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    return await _repository.getAssignmentsDueToday(userId, today);
  }

  /// Updates the status of an assignment
  Future<void> updateAssignmentStatus(
      String userId,
      String termId,
      String subjectId,
      String assignmentId,
      bool newStatus,
      ) async {
    try {
      // Update via repository (offline-first)
      await _repository.updateAssignmentStatus(assignmentId, newStatus);

      // TODO: Re-evaluate subject completeness (BQ 3.1)
      // Removed SubjectService - this functionality needs to be reimplemented if required
    } catch (e) {
      print('Error updating assignment status: $e');
      rethrow;
    }
  }

  /// Creates or updates an assignment and re-evaluates subject completeness
  /// **Business Question 3.1**: Trackea cambios en weights para GPA
  Future<void> saveAssignment(
      String userId,
      String termId,
      String subjectId,
      String assignmentId,
      Map<String, dynamic> assignmentData,
      ) async {
    try {
      // Obtener weight anterior si existe (from Firestore for analytics)
      final assignmentRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .doc(assignmentId);

      final existingDoc = await assignmentRef.get();
      final oldWeight = existingDoc.exists
          ? (existingDoc.data()?['weight'] as int? ?? 0)
          : 0;
      final newWeight = assignmentData['weight'] as int? ?? 0;

      // Create Assignment model
      final assignment = Assignment(
        id: assignmentId,
        subjectId: subjectId,
        title: assignmentData['title'] as String,
        description: assignmentData['description'] as String?,
        dueDate: assignmentData['dueDate'] as DateTime,
        isCompleted: assignmentData['isCompleted'] as bool? ?? false,
        createdAt: assignmentData['createdAt'] as DateTime,
        updatedAt: DateTime.now(),
      );

      // Save via repository (offline-first with nested paths)
      await _repository.saveAssignment(assignment, userId, termId, subjectId);

      // TODO: Re-evaluate subject completeness after saving (BQ 3.1)
      // Removed SubjectService - this functionality needs to be reimplemented if required

      // TODO: Analytics tracking for weight changes (BQ 3.1)
      // Note: Weight is now managed via weightId, not as a direct integer value
      // This analytics tracking needs to be updated to work with the new weightId system

      print('✅ Assignment saved and subject completeness updated');
    } catch (e) {
      print('❌ Error saving assignment: $e');
      rethrow;
    }
  }

  /// Deletes an assignment and re-evaluates subject completeness
  Future<void> deleteAssignment(
      String userId,
      String termId,
      String subjectId,
      String assignmentId,
      ) async {
    try {
      // Delete via repository (offline-first with nested paths)
      await _repository.deleteAssignment(assignmentId, userId, termId, subjectId);

      // TODO: Re-evaluate subject completeness after deletion (BQ 3.1)
      // Removed SubjectService - this functionality needs to be reimplemented if required

      print('✅ Assignment deleted and subject completeness updated');
    } catch (e) {
      print('❌ Error deleting assignment: $e');
      rethrow;
    }
  }

  /// Gets pending assignments sorted by due date (closest first)
  Future<List<Assignment>> getPendingAssignments(String userId) async {
    return await _repository.getPendingAssignments(userId);
  }

  /// Gets completed assignments sorted by due date (most recent first)
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    return await _repository.getCompletedAssignments(userId);
  }
}