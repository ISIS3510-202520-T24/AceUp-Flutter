import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/subject_model.dart';
import '../analytics/analytics_service.dart';

/// Servicio para gestionar Subjects con validación de datos para GPA
/// 
/// **Business Question 3.1**: Trackea si los subjects tienen datos completos
/// para habilitar el cálculo automático de GPA.
class SubjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics = AnalyticsService();

  /// Obtiene todos los subjects de un usuario
  Future<List<Subject>> getSubjectsForUser(String userId) async {
    try {
      final termsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();

      List<Subject> allSubjects = [];

      for (var termDoc in termsSnapshot.docs) {
        final subjectsSnapshot = await termDoc.reference
            .collection('subjects')
            .get();

        for (var subjectDoc in subjectsSnapshot.docs) {
          allSubjects.add(Subject.fromFirestore(subjectDoc));
        }
      }

      return allSubjects;
    } catch (e) {
      print('Error loading subjects: $e');
      return [];
    }
  }

  /// Obtiene subjects de un term específico
  Future<List<Subject>> getSubjectsForTerm(String userId, String termId) async {
    try {
      final subjectsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .get();

      return subjectsSnapshot.docs
          .map((doc) => Subject.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading subjects for term: $e');
      return [];
    }
  }

  /// Crea o actualiza un subject
  Future<void> saveSubject(String userId, Subject subject, {int? oldCredits}) async {
    try {
      final subjectRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(subject.termId)
          .collection('subjects')
          .doc(subject.id);

      // Verificar si existe previamente
      final existingDoc = await subjectRef.get();
      final isNew = !existingDoc.exists;

      // Verificar si tiene datos completos antes de guardar
      final hasCompleteData = await checkSubjectCompleteness(
        userId, 
        subject.termId, 
        subject.id,
        creditsToCheck: subject.credits,
      );

      final previouslyComplete = existingDoc.exists 
          ? (existingDoc.data()?['hasCompleteDataForGPA'] as bool? ?? false)
          : false;

      final subjectToSave = subject.copyWith(
        hasCompleteDataForGPA: hasCompleteData,
        dataCompletedAt: hasCompleteData && subject.dataCompletedAt == null
            ? DateTime.now()
            : subject.dataCompletedAt,
      );

      await subjectRef.set(subjectToSave.toFirestore());

      print('Subject saved: ${subject.name} (credits: ${subject.credits}, complete: $hasCompleteData)');

      // Analytics tracking (BQ 3.1)
      if (isNew) {
        // Track creación de subject
        await _analytics.trackSubjectCreated(
          userId: userId,
          subjectId: subject.id,
          subjectName: subject.name,
          termId: subject.termId,
          credits: subject.credits,
        );
      }

      // Track si se actualizaron credits
      if (oldCredits != null && oldCredits != subject.credits) {
        await _analytics.trackCreditsUpdated(
          userId: userId,
          subjectId: subject.id,
          oldCredits: oldCredits,
          newCredits: subject.credits,
        );
      }

      // Track si alcanzó completitud
      if (hasCompleteData && !previouslyComplete) {
        final totalWeight = await getTotalWeightForSubject(userId, subject.termId, subject.id);
        await _analytics.trackSubjectCompleted(
          userId: userId,
          subjectId: subject.id,
          subjectName: subject.name,
          termId: subject.termId,
          credits: subject.credits,
          totalWeight: totalWeight,
        );
      }
    } catch (e) {
      print('Error saving subject: $e');
      rethrow;
    }
  }

  /// Verifica si un subject tiene datos completos para cálculo de GPA
  /// 
  /// **Criterios BQ 3.1**:
  /// 1. Credits > 0 (definidos)
  /// 2. Suma de weights de assignments = 100%
  Future<bool> checkSubjectCompleteness(
    String userId,
    String termId,
    String subjectId, {
    int? creditsToCheck,
  }) async {
    try {
      // 1. Verificar credits
      int credits = creditsToCheck ?? 0;
      
      if (creditsToCheck == null) {
        final subjectDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('terms')
            .doc(termId)
            .collection('subjects')
            .doc(subjectId)
            .get();

        if (!subjectDoc.exists) return false;
        credits = (subjectDoc.data()?['credits'] as int?) ?? 0;
      }

      if (credits <= 0) {
        print('Subject incomplete: credits not defined ($credits)');
        return false;
      }

      // 2. Verificar suma de weights
      final totalWeight = await getTotalWeightForSubject(userId, termId, subjectId);
      
      if (totalWeight != 100) {
        print('Subject incomplete: weights sum to $totalWeight% (expected 100%)');
        return false;
      }

      print('Subject complete: credits=$credits, weights=$totalWeight%');
      return true;
    } catch (e) {
      print('Error checking subject completeness: $e');
      return false;
    }
  }

  /// Obtiene la suma total de weights de todos los assignments de un subject
  Future<int> getTotalWeightForSubject(
    String userId,
    String termId,
    String subjectId,
  ) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .get();

      int totalWeight = 0;
      for (var doc in assignmentsSnapshot.docs) {
        totalWeight += (doc.data()['weight'] as int?) ?? 0;
      }

      return totalWeight;
    } catch (e) {
      print('Error calculating total weight: $e');
      return 0;
    }
  }

  /// Obtiene el peso disponible restante para asignar assignments
  Future<int> getAvailableWeight(
    String userId,
    String termId,
    String subjectId, {
    String? excludeAssignmentId,
  }) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .get();

      int totalWeight = 0;
      for (var doc in assignmentsSnapshot.docs) {
        // Excluir el assignment actual si estamos editando
        if (excludeAssignmentId != null && doc.id == excludeAssignmentId) {
          continue;
        }
        totalWeight += (doc.data()['weight'] as int?) ?? 0;
      }

      final available = 100 - totalWeight;
      print('Available weight for subject: $available% (used: $totalWeight%)');
      return available;
    } catch (e) {
      print('Error calculating available weight: $e');
      return 0;
    }
  }

  /// Valida si se puede agregar/actualizar un assignment con el weight especificado
  Future<bool> validateWeightAllocation(
    String userId,
    String termId,
    String subjectId,
    int newWeight, {
    String? excludeAssignmentId,
  }) async {
    final available = await getAvailableWeight(
      userId,
      termId,
      subjectId,
      excludeAssignmentId: excludeAssignmentId,
    );

    return newWeight <= available;
  }

  /// Re-evalúa la completitud de un subject después de cambios en assignments
  Future<void> reevaluateSubjectCompleteness(
    String userId,
    String termId,
    String subjectId,
  ) async {
    try {
      final subjectDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .get();

      if (!subjectDoc.exists) return;

      final subject = Subject.fromFirestore(subjectDoc);
      final isComplete = await checkSubjectCompleteness(userId, termId, subjectId);

      // Solo actualizar si el estado cambió
      if (subject.hasCompleteDataForGPA != isComplete) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('terms')
            .doc(termId)
            .collection('subjects')
            .doc(subjectId)
            .update({
          'hasCompleteDataForGPA': isComplete,
          'dataCompletedAt': isComplete && subject.dataCompletedAt == null
              ? Timestamp.fromDate(DateTime.now())
              : subject.dataCompletedAt != null
                  ? Timestamp.fromDate(subject.dataCompletedAt!)
                  : null,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });

        print('Subject completeness updated: $isComplete');
      }
    } catch (e) {
      print('Error reevaluating subject completeness: $e');
    }
  }

  /// Obtiene estadísticas de completitud de subjects para un usuario
  /// 
  /// **Business Question 3.1**: Calcula el porcentaje de subjects completos
  Future<SubjectCompletenessStats> getCompletenessStats(String userId) async {
    try {
      final subjects = await getSubjectsForUser(userId);

      int totalSubjects = subjects.length;
      int completeSubjects = subjects.where((s) => s.hasCompleteDataForGPA).length;
      int subjectsWithCredits = subjects.where((s) => s.credits > 0).length;
      int subjectsWithoutCredits = totalSubjects - subjectsWithCredits;

      // Calcular subjects con weights inválidos
      int subjectsWithInvalidWeights = 0;
      for (var subject in subjects) {
        final totalWeight = await getTotalWeightForSubject(userId, subject.termId, subject.id);
        if (totalWeight != 100 && totalWeight != 0) {
          subjectsWithInvalidWeights++;
        }
      }

      double completionRate = totalSubjects > 0
          ? (completeSubjects / totalSubjects) * 100
          : 0.0;

      return SubjectCompletenessStats(
        totalSubjects: totalSubjects,
        completeSubjects: completeSubjects,
        subjectsWithCredits: subjectsWithCredits,
        subjectsWithoutCredits: subjectsWithoutCredits,
        subjectsWithInvalidWeights: subjectsWithInvalidWeights,
        completionRate: completionRate,
      );
    } catch (e) {
      print('Error calculating completeness stats: $e');
      return SubjectCompletenessStats(
        totalSubjects: 0,
        completeSubjects: 0,
        subjectsWithCredits: 0,
        subjectsWithoutCredits: 0,
        subjectsWithInvalidWeights: 0,
        completionRate: 0.0,
      );
    }
  }

  /// Elimina un subject
  Future<void> deleteSubject(String userId, String termId, String subjectId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .delete();

      print('Subject deleted: $subjectId');
    } catch (e) {
      print('Error deleting subject: $e');
      rethrow;
    }
  }
}

/// Estadísticas de completitud de subjects para BQ 3.1
class SubjectCompletenessStats {
  final int totalSubjects;
  final int completeSubjects;
  final int subjectsWithCredits;
  final int subjectsWithoutCredits;
  final int subjectsWithInvalidWeights;
  final double completionRate;

  SubjectCompletenessStats({
    required this.totalSubjects,
    required this.completeSubjects,
    required this.subjectsWithCredits,
    required this.subjectsWithoutCredits,
    required this.subjectsWithInvalidWeights,
    required this.completionRate,
  });

  @override
  String toString() {
    return 'SubjectCompletenessStats(\n'
           '  totalSubjects: $totalSubjects,\n'
           '  completeSubjects: $completeSubjects,\n'
           '  completionRate: ${completionRate.toStringAsFixed(2)}%,\n'
           '  withCredits: $subjectsWithCredits,\n'
           '  withoutCredits: $subjectsWithoutCredits,\n'
           '  withInvalidWeights: $subjectsWithInvalidWeights\n'
           ')';
  }
}
