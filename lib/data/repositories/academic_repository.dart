import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../models/planner/term_model.dart' as model;
import '../../models/planner/subject_model.dart' as model;
import '../../models/assignments/assignment_model.dart' as model;
import '../../models/planner/exam_model.dart' as model;
import '../../models/planner/class_template_model.dart' as model;
import '../../models/planner/class_exception_model.dart' as model;
import '../../models/helpers/weight_model.dart';
import '../../models/helpers/alert_model.dart';
import '../../core/constants/enums.dart';
import '../local/database/app_database.dart';

/// Repository for academic data (terms, subjects, assignments, exams, classes)
class AcademicRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  AcademicRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== TERMS ====================

  /// Get all terms for user from local database
  Future<List<model.Term>> getTermsForUser(String userId) async {
    final entities = await _db.termDao.getTermsForUser(userId);
    return entities.map(_termEntityToModel).toList();
  }

  /// Watch terms for user (stream)
  Stream<List<model.Term>> watchTermsForUser(String userId) {
    return _db.termDao.watchTermsForUser(userId).map(
          (entities) => entities.map(_termEntityToModel).toList(),
        );
  }

  /// Get term by ID
  Future<model.Term?> getTermById(String termId) async {
    final entity = await _db.termDao.getTermById(termId);
    if (entity == null) return null;
    return _termEntityToModel(entity);
  }

  /// Watch term by ID (stream)
  Stream<model.Term?> watchTermById(String termId) {
    return _db.termDao.watchTermById(termId).map((entity) {
      if (entity == null) return null;
      return _termEntityToModel(entity);
    });
  }

  /// Get active term for user
  Future<model.Term?> getActiveTermForUser(String userId) async {
    final entity = await _db.termDao.getActiveTermForUser(userId);
    if (entity == null) return null;
    return _termEntityToModel(entity);
  }

  /// Watch active term for user (stream)
  Stream<model.Term?> watchActiveTermForUser(String userId) {
    return _db.termDao.watchActiveTermForUser(userId).map((entity) {
      if (entity == null) return null;
      return _termEntityToModel(entity);
    });
  }

  /// Save term locally and queue for sync
  Future<void> saveTerm(model.Term term, String userId) async {
    final companion = _termModelToCompanion(term, userId);

    await _db.termDao.upsertTerm(companion);

    await _queueSync(
      entityType: 'term',
      entityId: term.id,
      operation: 'update',
      data: term.toFirestore(),
      documentPath: 'users/$userId/terms/${term.id}',
    );
  }

  /// Set active term
  Future<void> setActiveTerm(String userId, String termId) async {
    await _db.termDao.setActiveTerm(userId, termId);

    // Queue sync for all terms affected
    final terms = await _db.termDao.getTermsForUser(userId);
    for (final term in terms) {
      await _queueSync(
        entityType: 'term',
        entityId: term.id,
        operation: 'update',
        data: {'isActive': term.id == termId},
        documentPath: 'users/$userId/terms/${term.id}',
      );
    }
  }

  /// Delete term
  Future<void> deleteTerm(String termId, String userId) async {
    await _db.termDao.deleteTerm(termId);

    await _queueSync(
      entityType: 'term',
      entityId: termId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId',
    );
  }

  /// Fetch all terms from Firebase for user
  Future<List<model.Term>> fetchTermsFromFirebase(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();

      final terms = snapshot.docs.map((doc) => model.Term.fromFirestore(doc)).toList();

      // Store locally
      final companions = terms.map((term) => _termModelToCompanion(term, userId)).toList();
      await _db.termDao.insertTermsBatch(companions);

      // Mark as synced
      for (final term in terms) {
        await _db.termDao.markAsSynced(term.id);
      }

      return terms;
    } catch (e) {
      print('Error fetching terms from Firebase: $e');
      rethrow;
    }
  }

  // ==================== SUBJECTS ====================

  /// Get subjects for term from local database
  Future<List<model.Subject>> getSubjectsForTerm(String termId) async {
    final entities = await _db.subjectDao.getSubjectsForTerm(termId);
    return entities.map(_subjectEntityToModel).toList();
  }

  /// Watch subjects for term (stream)
  Stream<List<model.Subject>> watchSubjectsForTerm(String termId) {
    return _db.subjectDao.watchSubjectsForTerm(termId).map(
          (entities) => entities.map(_subjectEntityToModel).toList(),
        );
  }

  /// Get subject by ID
  Future<model.Subject?> getSubjectById(String subjectId) async {
    final entity = await _db.subjectDao.getSubjectById(subjectId);
    if (entity == null) return null;
    return _subjectEntityToModel(entity);
  }

  /// Watch subject by ID (stream)
  Stream<model.Subject?> watchSubjectById(String subjectId) {
    return _db.subjectDao.watchSubjectById(subjectId).map((entity) {
      if (entity == null) return null;
      return _subjectEntityToModel(entity);
    });
  }

  /// Get subjects for active term
  Future<List<model.Subject>> getSubjectsForActiveTerm(String userId) async {
    final entities = await _db.subjectDao.getSubjectsForActiveTerm(userId);
    return entities.map(_subjectEntityToModel).toList();
  }

  /// Save subject locally and queue for sync
  Future<void> saveSubject(model.Subject subject, String userId, String termId) async {
    final companion = _subjectModelToCompanion(subject, termId);

    await _db.subjectDao.upsertSubject(companion);

    await _queueSync(
      entityType: 'subject',
      entityId: subject.id,
      operation: 'update',
      data: subject.toFirestore(),
      documentPath: 'users/$userId/terms/$termId/subjects/${subject.id}',
    );
  }

  /// Delete subject
  Future<void> deleteSubject(String subjectId, String userId, String termId) async {
    await _db.subjectDao.deleteSubject(subjectId);

    await _queueSync(
      entityType: 'subject',
      entityId: subjectId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId',
    );
  }

  /// Fetch all subjects from Firebase for a specific term
  Future<List<model.Subject>> fetchSubjectsFromFirebase(String userId, String termId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .get();

      final subjects = snapshot.docs.map((doc) => model.Subject.fromFirestore(doc)).toList();

      // Store locally
      for (final subject in subjects) {
        final companion = _subjectModelToCompanion(subject, termId);
        await _db.subjectDao.upsertSubject(companion);
        await _db.subjectDao.markAsSynced(subject.id);
      }

      return subjects;
    } catch (e) {
      print('Error fetching subjects from Firebase: $e');
      rethrow;
    }
  }

  // ==================== ASSIGNMENTS ====================

  /// Get assignments for subject
  Future<List<model.Assignment>> getAssignmentsForSubject(String subjectId) async {
    final entities = await _db.assignmentDao.getAssignmentsForSubject(subjectId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Watch assignments for subject (stream)
  Stream<List<model.Assignment>> watchAssignmentsForSubject(String subjectId) {
    return _db.assignmentDao.watchAssignmentsForSubject(subjectId).map(
          (entities) => entities.map(_assignmentEntityToModel).toList(),
        );
  }

  /// Get assignment by ID
  Future<model.Assignment?> getAssignmentById(String assignmentId) async {
    final entity = await _db.assignmentDao.getAssignmentById(assignmentId);
    if (entity == null) return null;
    return _assignmentEntityToModel(entity);
  }

  /// Get all assignments for user
  Future<List<model.Assignment>> getAssignmentsForUser(String userId) async {
    final entities = await _db.assignmentDao.getAssignmentsForUser(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get pending assignments for user
  Future<List<model.Assignment>> getPendingAssignments(String userId) async {
    final entities = await _db.assignmentDao.getPendingAssignmentsForUser(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get completed assignments for user
  Future<List<model.Assignment>> getCompletedAssignments(String userId) async {
    final entities = await _db.assignmentDao.getCompletedAssignmentsForUser(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get assignments due today
  Future<List<model.Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final entities = await _db.assignmentDao.getAssignmentsDueToday(userId, today);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get upcoming assignments
  Future<List<model.Assignment>> getUpcomingAssignments(String userId) async {
    final entities = await _db.assignmentDao.getUpcomingAssignments(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get overdue assignments
  Future<List<model.Assignment>> getOverdueAssignments(String userId) async {
    final entities = await _db.assignmentDao.getOverdueAssignments(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Save assignment locally and queue for sync
  Future<void> saveAssignment(model.Assignment assignment, String userId, String termId, String subjectId) async {
    final companion = _assignmentModelToCompanion(assignment, subjectId);

    await _db.assignmentDao.upsertAssignment(companion);

    await _queueSync(
      entityType: 'assignment',
      entityId: assignment.id,
      operation: 'update',
      data: assignment.toFirestore(),
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/assignments/${assignment.id}',
    );
  }

  /// Mark assignment as completed
  Future<void> markAssignmentCompleted(String assignmentId, bool completed, String userId, String termId, String subjectId) async {
    await _db.assignmentDao.markAsCompleted(assignmentId, completed);

    await _queueSync(
      entityType: 'assignment',
      entityId: assignmentId,
      operation: 'update',
      data: {
        'isCompleted': completed,
        'completedAt': completed ? Timestamp.fromDate(DateTime.now()) : null,
      },
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/assignments/$assignmentId',
    );
  }

  /// Update assignment status
  Future<void> updateAssignmentStatus(String assignmentId, bool newStatus) async {
    final isCompleted = newStatus;
    final entity = await _db.assignmentDao.getAssignmentById(assignmentId);
    if (entity == null) return;

    // Extract userId and termId from the assignment's subject
    final subject = await _db.subjectDao.getSubjectById(entity.subjectId);
    if (subject == null) return;

    final term = await _db.termDao.getTermById(subject.termId);
    if (term == null) return;

    await markAssignmentCompleted(assignmentId, isCompleted, term.userId, subject.termId, entity.subjectId);
  }

  /// Delete assignment
  Future<void> deleteAssignment(String assignmentId, String userId, String termId, String subjectId) async {
    await _db.assignmentDao.deleteAssignment(assignmentId);

    await _queueSync(
      entityType: 'assignment',
      entityId: assignmentId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/assignments/$assignmentId',
    );
  }

  /// Fetch all assignments from Firebase for a specific subject
  Future<List<model.Assignment>> fetchAssignmentsFromFirebase(String userId, String termId, String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .get();

      final assignments = snapshot.docs.map((doc) => model.Assignment.fromFirestore(doc)).toList();

      // Store locally
      for (final assignment in assignments) {
        final companion = _assignmentModelToCompanion(assignment, subjectId);
        await _db.assignmentDao.upsertAssignment(companion);
        await _db.assignmentDao.markAsSynced(assignment.id);
      }

      return assignments;
    } catch (e) {
      print('Error fetching assignments from Firebase: $e');
      rethrow;
    }
  }

  /// Fetch all assignments across all subjects for a user (iterates through all terms and subjects)
  Future<List<model.Assignment>> fetchAllAssignmentsForUser(String userId) async {
    final allAssignments = <model.Assignment>[];

    try {
      // Get all terms
      final terms = await getTermsForUser(userId);

      // For each term, get all subjects
      for (final term in terms) {
        final subjects = await getSubjectsForTerm(term.id);

        // For each subject, fetch assignments
        for (final subject in subjects) {
          final assignments = await fetchAssignmentsFromFirebase(userId, term.id, subject.id);
          allAssignments.addAll(assignments);
        }
      }

      return allAssignments;
    } catch (e) {
      print('Error fetching all assignments for user: $e');
      rethrow;
    }
  }

  // ==================== EXAMS ====================

  /// Get exams for subject
  Future<List<model.Exam>> getExamsForSubject(String subjectId) async {
    final entities = await _db.examDao.getExamsForSubject(subjectId);
    return entities.map(_examEntityToModel).toList();
  }

  /// Watch exams for subject (stream)
  Stream<List<model.Exam>> watchExamsForSubject(String subjectId) {
    return _db.examDao.watchExamsForSubject(subjectId).map(
          (entities) => entities.map(_examEntityToModel).toList(),
        );
  }

  /// Get exam by ID
  Future<model.Exam?> getExamById(String examId) async {
    final entity = await _db.examDao.getExamById(examId);
    if (entity == null) return null;
    return _examEntityToModel(entity);
  }

  /// Save exam locally and queue for sync
  Future<void> saveExam(model.Exam exam, String userId, String termId, String subjectId) async {
    final companion = _examModelToCompanion(exam, subjectId);

    await _db.examDao.upsertExam(companion);

    await _queueSync(
      entityType: 'exam',
      entityId: exam.id,
      operation: 'update',
      data: exam.toFirestore(),
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/exams/${exam.id}',
    );
  }

  /// Delete exam
  Future<void> deleteExam(String examId, String userId, String termId, String subjectId) async {
    await _db.examDao.deleteExam(examId);

    await _queueSync(
      entityType: 'exam',
      entityId: examId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/exams/$examId',
    );
  }

  /// Fetch exams from Firebase for a specific subject
  Future<List<model.Exam>> fetchExamsFromFirebase(String userId, String termId, String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('exams')
          .get();

      final exams = snapshot.docs.map((doc) => model.Exam.fromFirestore(doc)).toList();

      // Store locally
      for (final exam in exams) {
        final companion = _examModelToCompanion(exam, subjectId);
        await _db.examDao.upsertExam(companion);
        await _db.examDao.markAsSynced(exam.id);
      }

      return exams;
    } catch (e) {
      print('Error fetching exams from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CLASS TEMPLATES ====================

  /// Get class templates for subject
  Future<List<model.ClassTemplate>> getClassTemplatesForSubject(String subjectId) async {
    final entities = await _db.classDao.getClassTemplatesForSubject(subjectId);
    return entities.map(_classTemplateEntityToModel).toList();
  }

  /// Watch class templates for subject (stream)
  Stream<List<model.ClassTemplate>> watchClassTemplatesForSubject(String subjectId) {
    return _db.classDao.watchClassTemplatesForSubject(subjectId).map(
          (entities) => entities.map(_classTemplateEntityToModel).toList(),
        );
  }

  /// Get class template by ID
  Future<model.ClassTemplate?> getClassTemplateById(String templateId) async {
    final entity = await _db.classDao.getClassTemplateById(templateId);
    if (entity == null) return null;
    return _classTemplateEntityToModel(entity);
  }

  /// Save class template locally and queue for sync
  Future<void> saveClassTemplate(model.ClassTemplate template, String userId, String termId, String subjectId) async {
    final companion = _classTemplateModelToCompanion(template, subjectId);

    await _db.classDao.upsertClassTemplate(companion);

    await _queueSync(
      entityType: 'classTemplate',
      entityId: template.id,
      operation: 'update',
      data: template.toFirestore(),
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/classTemplates/${template.id}',
    );
  }

  /// Delete class template
  Future<void> deleteClassTemplate(String templateId, String userId, String termId, String subjectId) async {
    await _db.classDao.deleteClassTemplate(templateId);

    await _queueSync(
      entityType: 'classTemplate',
      entityId: templateId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/classTemplates/$templateId',
    );
  }

  /// Fetch class templates from Firebase for a specific subject
  Future<List<model.ClassTemplate>> fetchClassTemplatesFromFirebase(String userId, String termId, String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('classTemplates')
          .get();

      final templates = snapshot.docs.map((doc) => model.ClassTemplate.fromFirestore(doc)).toList();

      // Store locally
      for (final template in templates) {
        final companion = _classTemplateModelToCompanion(template, subjectId);
        await _db.classDao.upsertClassTemplate(companion);
        await _db.classDao.markClassTemplateSynced(template.id);
      }

      return templates;
    } catch (e) {
      print('Error fetching class templates from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CLASS EXCEPTIONS ====================

  /// Get class exceptions for template
  Future<List<model.ClassException>> getClassExceptionsForTemplate(String templateId) async {
    final entities = await _db.classDao.getClassExceptionsForTemplate(templateId);
    return entities.map(_classExceptionEntityToModel).toList();
  }

  /// Watch class exceptions for template (stream)
  Stream<List<model.ClassException>> watchClassExceptionsForTemplate(String templateId) {
    return _db.classDao.watchClassExceptionsForTemplate(templateId).map(
          (entities) => entities.map(_classExceptionEntityToModel).toList(),
        );
  }

  /// Get class exception by ID
  Future<model.ClassException?> getClassExceptionById(String exceptionId) async {
    final entity = await _db.classDao.getClassExceptionById(exceptionId);
    if (entity == null) return null;
    return _classExceptionEntityToModel(entity);
  }

  /// Save class exception locally and queue for sync
  Future<void> saveClassException(model.ClassException exception, String userId, String termId, String subjectId) async {
    final companion = _classExceptionModelToCompanion(exception);

    await _db.classDao.upsertClassException(companion);

    await _queueSync(
      entityType: 'classException',
      entityId: exception.id,
      operation: 'update',
      data: exception.toFirestore(),
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/classExceptions/${exception.id}',
    );
  }

  /// Delete class exception
  Future<void> deleteClassException(String exceptionId, String userId, String termId, String subjectId) async {
    await _db.classDao.deleteClassException(exceptionId);

    await _queueSync(
      entityType: 'classException',
      entityId: exceptionId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/terms/$termId/subjects/$subjectId/classExceptions/$exceptionId',
    );
  }

  /// Fetch class exceptions from Firebase for a specific subject
  Future<List<model.ClassException>> fetchClassExceptionsFromFirebase(String userId, String termId, String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('classExceptions')
          .get();

      final exceptions = snapshot.docs.map((doc) => model.ClassException.fromFirestore(doc)).toList();

      // Store locally
      for (final exception in exceptions) {
        final companion = _classExceptionModelToCompanion(exception);
        await _db.classDao.upsertClassException(companion);
        await _db.classDao.markClassExceptionSynced(exception.id);
      }

      return exceptions;
    } catch (e) {
      print('Error fetching class exceptions from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert term entity to model
  model.Term _termEntityToModel(TermEntity entity) {
    return model.Term(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert term model to companion
  TermsCompanion _termModelToCompanion(model.Term term, String userId) {
    return TermsCompanion(
      id: Value(term.id),
      userId: Value(userId),
      name: Value(term.name),
      startDate: Value(term.startDate),
      endDate: Value(term.endDate),
      isActive: Value(term.isActive),
      createdAt: Value(term.createdAt),
      updatedAt: Value(term.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Convert subject entity to model
  model.Subject _subjectEntityToModel(SubjectEntity entity) {
    final weights = Weight.fromJsonString(entity.weightsJson);

    return model.Subject(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      credits: entity.credits,
      finalGrade: entity.finalGrade,
      useFinalGradeOverride: entity.useFinalGradeOverride,
      weights: weights,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert subject model to companion
  SubjectsCompanion _subjectModelToCompanion(model.Subject subject, String termId) {
    return SubjectsCompanion(
      id: Value(subject.id),
      termId: Value(termId),
      name: Value(subject.name),
      color: Value(subject.color),
      credits: Value(subject.credits),
      finalGrade: Value(subject.finalGrade),
      useFinalGradeOverride: Value(subject.useFinalGradeOverride),
      weightsJson: Value(Weight.toJsonString(subject.weights)),
      createdAt: Value(subject.createdAt),
      updatedAt: Value(subject.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Convert assignment entity to model
  model.Assignment _assignmentEntityToModel(AssignmentEntity entity) {
    final alerts = Alert.fromJsonString(entity.alertsJson);

    return model.Assignment(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime,
      weightId: entity.weightId,
      priority: _stringToPriority(entity.priority),
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      isGraded: entity.isGraded,
      grade: entity.grade,
      alerts: alerts,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert assignment model to companion
  AssignmentsCompanion _assignmentModelToCompanion(model.Assignment assignment, String subjectId) {
    return AssignmentsCompanion(
      id: Value(assignment.id),
      subjectId: Value(subjectId),
      title: Value(assignment.title),
      description: Value(assignment.description),
      dueDate: Value(assignment.dueDate),
      dueTime: Value(assignment.dueTime),
      weightId: Value(assignment.weightId),
      priority: Value(assignment.priority.value),
      isCompleted: Value(assignment.isCompleted),
      completedAt: Value(assignment.completedAt),
      isGraded: Value(assignment.isGraded),
      grade: Value(assignment.grade),
      alertsJson: Value(Alert.toJsonString(assignment.alerts)),
      createdAt: Value(assignment.createdAt),
      updatedAt: Value(assignment.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Convert string to Priority enum
  Priority _stringToPriority(String priority) {
    return Priority.fromString(priority);
  }

  /// Convert exam entity to model
  model.Exam _examEntityToModel(ExamEntity entity) {
    return model.Exam(
      id: entity.id,
      name: entity.name,
      date: entity.date,
      startTime: entity.startTime,
      endTime: entity.endTime,
      weightId: entity.weightId,
      building: entity.building,
      room: entity.room,
      teacherId: entity.teacherId,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      isGraded: entity.isGraded,
      grade: entity.grade,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert exam model to companion
  ExamsCompanion _examModelToCompanion(model.Exam exam, String subjectId) {
    return ExamsCompanion(
      id: Value(exam.id),
      subjectId: Value(subjectId),
      name: Value(exam.name),
      date: Value(exam.date),
      startTime: Value(exam.startTime),
      endTime: Value(exam.endTime),
      weightId: Value(exam.weightId),
      building: Value(exam.building),
      room: Value(exam.room),
      teacherId: Value(exam.teacherId),
      isCompleted: Value(exam.isCompleted),
      completedAt: Value(exam.completedAt),
      isGraded: Value(exam.isGraded),
      grade: Value(exam.grade),
      createdAt: Value(exam.createdAt),
      updatedAt: Value(exam.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Convert class template entity to model
  model.ClassTemplate _classTemplateEntityToModel(ClassTemplateEntity entity) {
    return model.ClassTemplate(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      startDate: entity.startDate,
      endDate: entity.endDate,
      startTime: entity.startTime,
      endTime: entity.endTime,
      recurrence: Recurrence.fromJsonString(entity.recurrenceJson),
      building: entity.building,
      room: entity.room,
      teacherId: entity.teacherId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert class template model to companion
  ClassTemplatesCompanion _classTemplateModelToCompanion(model.ClassTemplate template, String subjectId) {
    return ClassTemplatesCompanion(
      id: Value(template.id),
      subjectId: Value(subjectId),
      name: Value(template.name),
      icon: Value(template.icon),
      startDate: Value(template.startDate),
      endDate: Value(template.endDate),
      startTime: Value(template.startTime),
      endTime: Value(template.endTime),
      recurrenceJson: Value(template.recurrence.toJsonString()),
      building: Value(template.building),
      room: Value(template.room),
      teacherId: Value(template.teacherId),
      createdAt: Value(template.createdAt),
      updatedAt: Value(template.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  /// Convert class exception entity to model
  model.ClassException _classExceptionEntityToModel(ClassExceptionEntity entity) {
    return model.ClassException(
      id: entity.id,
      classTemplateId: entity.classTemplateId,
      date: entity.date,
      isCancelled: entity.isCancelled,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert class exception model to companion
  ClassExceptionsCompanion _classExceptionModelToCompanion(model.ClassException exception) {
    return ClassExceptionsCompanion(
      id: Value(exception.id),
      classTemplateId: Value(exception.classTemplateId),
      date: Value(exception.date),
      isCancelled: Value(exception.isCancelled),
      notes: Value(exception.notes),
      createdAt: Value(exception.createdAt),
      updatedAt: Value(exception.updatedAt),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  // ==================== SYNC QUEUE HELPERS ====================

  /// Queue sync operation
  Future<void> _queueSync({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    required String documentPath,
  }) async {
    await _db.syncDao.queueSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
