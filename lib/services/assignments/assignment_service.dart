import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/assignments/assignment_model.dart';
import '../subjects/subject_service.dart';
import '../analytics/analytics_service.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SubjectService _subjectService = SubjectService();
  final AnalyticsService _analytics = AnalyticsService();


  /// Gets all assignments for a user (using offline-first repository)
  Future<List<Assignment>> getAllAssignmentsForUser(String userId) async {
    return await _repository.getAllAssignmentsForUser(userId);
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
      String newStatus,
      ) async {
    try {
      // Update via repository (offline-first)
      await _repository.updateAssignmentStatus(assignmentId, newStatus);

      // Re-evaluar completitud del subject (BQ 3.1)
      await _subjectService.reevaluateSubjectCompleteness(userId, termId, subjectId);
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
      );

      // Save via repository (offline-first)
      await _repository.saveAssignment(assignment);

      // Re-evaluar completitud del subject después de guardar
      await _subjectService.reevaluateSubjectCompleteness(userId, termId, subjectId);

      // 📊 Analytics: Track cambio de weight (BQ 3.1)
      if (oldWeight != newWeight) {
        final totalWeightAfter = await _subjectService.getTotalWeightForSubject(
          userId,
          termId,
          subjectId,
        );

        await _analytics.trackAssignmentWeightChanged(
          userId: userId,
          subjectId: subjectId,
          assignmentId: assignmentId,
          oldWeight: oldWeight,
          newWeight: newWeight,
          totalWeightAfter: totalWeightAfter,
        );
      }

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
      // Delete via repository (offline-first soft delete)
      await _repository.deleteAssignment(assignmentId);

      // Re-evaluar completitud del subject después de borrar
      await _subjectService.reevaluateSubjectCompleteness(userId, termId, subjectId);

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