import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/assignments/assignment_model.dart';
import '../subjects/subject_service.dart';
import '../analytics/analytics_service.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SubjectService _subjectService = SubjectService();
  final AnalyticsService _analytics = AnalyticsService();

  /// Gets all assignments for a user
  Future<List<Assignment>> getAllAssignmentsForUser(String userId) async {
    List<Assignment> allAssignments = [];

    try {
      // Navigate: users/{userId}/terms/{termId}/subjects/{subjectId}/assignments
      final termsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();

      for (var termDoc in termsSnapshot.docs) {
        final subjectsSnapshot = await termDoc.reference.collection('subjects').get();

        for (var subjectDoc in subjectsSnapshot.docs) {
          final subjectData = subjectDoc.data();
          final subjectName = subjectData['name'] ?? 'Unknown Subject';

          final assignmentsSnapshot =
          await subjectDoc.reference.collection('assignments').get();

          for (var assignmentDoc in assignmentsSnapshot.docs) {
            allAssignments.add(Assignment.fromFirestore(
              assignmentDoc,
              subjectName,
              termId: termDoc.id,
              subjectId: subjectDoc.id,
            ));
          }
        }
      }
    } catch (e) {
      print('Error loading all assignments: $e');
      rethrow;
    }

    return allAssignments;
  }

  /// Gets assignments due today for a user
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final allAssignments = await getAllAssignmentsForUser(userId);

    return allAssignments.where((assignment) {
      return assignment.isDueToday(today);
    }).toList();
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .doc(assignmentId)
          .update({'status': newStatus});
      
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
      // Obtener weight anterior si existe
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

      await assignmentRef.set(assignmentData, SetOptions(merge: true));
      
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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .doc(assignmentId)
          .delete();
      
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
    final allAssignments = await getAllAssignmentsForUser(userId);

    final pending = allAssignments.where((a) => a.isPending).toList();
    pending.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return pending;
  }

  /// Gets completed assignments sorted by due date (most recent first)
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    final allAssignments = await getAllAssignmentsForUser(userId);

    final completed = allAssignments.where((a) => a.isCompleted).toList();
    completed.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return completed;
  }
}