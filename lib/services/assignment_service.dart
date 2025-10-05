import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    } catch (e) {
      print('Error updating assignment status: $e');
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