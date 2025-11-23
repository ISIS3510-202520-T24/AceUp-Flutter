import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/planner/term_model.dart';
import '../../models/planner/subject_model.dart';
import '../../models/assignments/assignment_model.dart';
import '../../models/planner/class_template_model.dart';
import '../../models/planner/class_exception_model.dart';
import '../../models/planner/exam_model.dart';
import '../../models/helpers/weight_model.dart';
import '../../models/helpers/alert_model.dart';
import '../../models/helpers/recurrence_model.dart';
import '../../core/constants/enums.dart';
import '../local/database/app_database.dart';
import '../local/database/tables/tables.dart';

class AcademicRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  AcademicRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ============================================
  // TERMS
  // ============================================

  /// Get all terms for user
  Future<List<Term>> getTermsForUser(String userId) async {
    final entities = await _db.termDao.getTermsForUser(userId);
    return entities.map(_termEntityToModel).toList();
  }

  /// Watch terms for user
  Stream<List<Term>> watchTermsForUser(String userId) {
    return _db.termDao.watchTermsForUser(userId).map(
          (entities) => entities.map(_termEntityToModel).toList(),
        );
  }

  /// Get term by ID
  Future<Term?> getTermById(String id) async {
    final entity = await _db.termDao.getTermById(id);
    return entity != null ? _termEntityToModel(entity) : null;
  }

  /// Get active term for user
  Future<Term?> getActiveTermForUser(String userId) async {
    final entity = await _db.termDao.getActiveTermForUser(userId);
    return entity != null ? _termEntityToModel(entity) : null;
  }

  /// Create term
  Future<Term> createTerm({
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    bool isActive = false,
  }) async {
    final now = DateTime.now();
    final term = Term(
      id: _uuid.v4(),
      name: name,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save locally
    await _db.termDao.insertTerm(_termModelToCompanion(term, userId));

    // 2. Queue for sync
    await _queueSync('term', term.id, 'create', term.toJson(),
        'users/$userId/terms/${term.id}');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncTermToFirestore(userId, term);
    }

    return term;
  }

  /// Update term
  Future<void> updateTerm(String userId, Term term) async {
    final updated = term.copyWith(updatedAt: DateTime.now());

    // 1. Update locally
    await _db.termDao.updateTerm(_termModelToCompanion(updated, userId));

    // 2. Queue for sync
    await _queueSync('term', updated.id, 'update', updated.toJson(),
        'users/$userId/terms/${updated.id}');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncTermToFirestore(userId, updated);
    }
  }

  /// Set active term
  Future<void> setActiveTerm(String userId, String termId) async {
    await _db.termDao.setActiveTerm(userId, termId);
    
    // Queue sync for all affected terms
    final terms = await getTermsForUser(userId);
    for (final term in terms) {
      await _queueSync('term', term.id, 'update', term.toJson(),
          'users/$userId/terms/${term.id}');
    }
  }

  /// Delete term
  Future<void> deleteTerm(String userId, String termId) async {
    // 1. Delete locally (cascade deletes subjects, assignments, etc.)
    await _db.termDao.deleteTerm(termId);

    // 2. Queue for sync
    await _queueSync('term', termId, 'delete', '{}',
        'users/$userId/terms/$termId');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .delete();
    }
  }

  // ============================================
  // SUBJECTS
  // ============================================

  /// Get subjects for term
  Future<List<Subject>> getSubjectsForTerm(String termId) async {
    final entities = await _db.subjectDao.getSubjectsForTerm(termId);
    return entities.map(_subjectEntityToModel).toList();
  }

  /// Watch subjects for term
  Stream<List<Subject>> watchSubjectsForTerm(String termId) {
    return _db.subjectDao.watchSubjectsForTerm(termId).map(
          (entities) => entities.map(_subjectEntityToModel).toList(),
        );
  }

  /// Get subject by ID
  Future<Subject?> getSubjectById(String id) async {
    final entity = await _db.subjectDao.getSubjectById(id);
    return entity != null ? _subjectEntityToModel(entity) : null;
  }

  /// Create subject
  Future<Subject> createSubject({
    required String userId,
    required String termId,
    required String name,
    required String color,
    required double credits,
    List<Weight> weights = const [],
  }) async {
    final now = DateTime.now();
    final subject = Subject(
      id: _uuid.v4(),
      name: name,
      color: color,
      credits: credits,
      weights: weights,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save locally
    await _db.subjectDao.insertSubject(_subjectModelToCompanion(subject, termId));

    // 2. Queue for sync
    await _queueSync('subject', subject.id, 'create', subject.toJson(),
        'users/$userId/terms/$termId/subjects/${subject.id}');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncSubjectToFirestore(userId, termId, subject);
    }

    return subject;
  }

  /// Update subject
  Future<void> updateSubject(String userId, String termId, Subject subject) async {
    final updated = subject.copyWith(updatedAt: DateTime.now());

    // 1. Update locally
    await _db.subjectDao.updateSubject(_subjectModelToCompanion(updated, termId));

    // 2. Queue for sync
    await _queueSync('subject', updated.id, 'update', updated.toJson(),
        'users/$userId/terms/$termId/subjects/${updated.id}');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncSubjectToFirestore(userId, termId, updated);
    }
  }

  /// Delete subject
  Future<void> deleteSubject(String userId, String termId, String subjectId) async {
    await _db.subjectDao.deleteSubject(subjectId);
    await _queueSync('subject', subjectId, 'delete', '{}',
        'users/$userId/terms/$termId/subjects/$subjectId');

    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .delete();
    }
  }

  // ============================================
  // ASSIGNMENTS
  // ============================================

  /// Get assignments for subject
  Future<List<Assignment>> getAssignmentsForSubject(String subjectId) async {
    final entities = await _db.assignmentDao.getAssignmentsForSubject(subjectId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Watch assignments for subject
  Stream<List<Assignment>> watchAssignmentsForSubject(String subjectId) {
    return _db.assignmentDao.watchAssignmentsForSubject(subjectId).map(
          (entities) => entities.map(_assignmentEntityToModel).toList(),
        );
  }

  /// Get all assignments for user
  Future<List<Assignment>> getAssignmentsForUser(String userId) async {
    final entities = await _db.assignmentDao.getAssignmentsForUser(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get pending assignments
  Future<List<Assignment>> getPendingAssignmentsForUser(String userId) async {
    final entities = await _db.assignmentDao.getPendingAssignmentsForUser(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get assignments due today
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final entities = await _db.assignmentDao.getAssignmentsDueToday(userId, today);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Get upcoming assignments
  Future<List<Assignment>> getUpcomingAssignments(String userId) async {
    final entities = await _db.assignmentDao.getUpcomingAssignments(userId);
    return entities.map(_assignmentEntityToModel).toList();
  }

  /// Create assignment
  Future<Assignment> createAssignment({
    required String userId,
    required String termId,
    required String subjectId,
    required String title,
    String? description,
    required DateTime dueDate,
    String? dueTime,
    String? weightId,
    Priority priority = Priority.medium,
    List<Alert> alerts = const [],
  }) async {
    final now = DateTime.now();
    final assignment = Assignment(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: dueTime,
      weightId: weightId,
      priority: priority,
      alerts: alerts,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save locally
    await _db.assignmentDao.insertAssignment(
        _assignmentModelToCompanion(assignment, subjectId));

    // 2. Queue for sync
    await _queueSync('assignment', assignment.id, 'create', assignment.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/assignments/${assignment.id}');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncAssignmentToFirestore(userId, termId, subjectId, assignment);
    }

    return assignment;
  }

  /// Update assignment
  Future<void> updateAssignment(String userId, String termId, String subjectId,
      Assignment assignment) async {
    final updated = assignment.copyWith(updatedAt: DateTime.now());

    await _db.assignmentDao.updateAssignment(
        _assignmentModelToCompanion(updated, subjectId));

    await _queueSync('assignment', updated.id, 'update', updated.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/assignments/${updated.id}');

    if (_connectivity.isOnline) {
      await _syncAssignmentToFirestore(userId, termId, subjectId, updated);
    }
  }

  /// Mark assignment as completed
  Future<void> markAssignmentCompleted(String assignmentId, bool completed) async {
    await _db.assignmentDao.markAsCompleted(assignmentId, completed);
  }

  /// Update assignment grade
  Future<void> updateAssignmentGrade(String assignmentId, double? grade, bool isGraded) async {
    await _db.assignmentDao.updateGrade(assignmentId, grade, isGraded);
  }

  /// Delete assignment
  Future<void> deleteAssignment(
      String userId, String termId, String subjectId, String assignmentId) async {
    await _db.assignmentDao.deleteAssignment(assignmentId);
    await _queueSync('assignment', assignmentId, 'delete', '{}',
        'users/$userId/terms/$termId/subjects/$subjectId/assignments/$assignmentId');

    if (_connectivity.isOnline) {
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
    }
  }

  // ============================================
  // CLASS TEMPLATES
  // ============================================

  /// Get class templates for subject
  Future<List<ClassTemplate>> getClassTemplatesForSubject(String subjectId) async {
    final entities = await _db.classDao.getClassTemplatesForSubject(subjectId);
    return entities.map(_classTemplateEntityToModel).toList();
  }

  /// Get class templates for active term
  Future<List<ClassTemplate>> getClassTemplatesForActiveTerm(String userId) async {
    final entities = await _db.classDao.getClassTemplatesForActiveTerm(userId);
    return entities.map(_classTemplateEntityToModel).toList();
  }

  /// Create class template
  Future<ClassTemplate> createClassTemplate({
    required String userId,
    required String termId,
    required String subjectId,
    required String name,
    required String icon,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required Recurrence recurrence,
    String? building,
    String? room,
    String? teacherId,
  }) async {
    final now = DateTime.now();
    final template = ClassTemplate(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      recurrence: recurrence,
      building: building,
      room: room,
      teacherId: teacherId,
      createdAt: now,
      updatedAt: now,
    );

    await _db.classDao.insertClassTemplate(
        _classTemplateModelToCompanion(template, subjectId));

    await _queueSync('classTemplate', template.id, 'create', template.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/classTemplates/${template.id}');

    if (_connectivity.isOnline) {
      await _syncClassTemplateToFirestore(userId, termId, subjectId, template);
    }

    return template;
  }

  /// Delete class template
  Future<void> deleteClassTemplate(
      String userId, String termId, String subjectId, String templateId) async {
    await _db.classDao.deleteClassTemplate(templateId);
    await _db.classDao.deleteExceptionsForTemplate(templateId);

    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('classTemplates')
          .doc(templateId)
          .delete();
    }
  }

  // ============================================
  // CLASS EXCEPTIONS
  // ============================================

  /// Get exceptions for class template
  Future<List<ClassException>> getExceptionsForTemplate(String classTemplateId) async {
    final entities = await _db.classDao.getExceptionsForTemplate(classTemplateId);
    return entities.map(_classExceptionEntityToModel).toList();
  }

  /// Cancel class on date
  Future<ClassException> cancelClass({
    required String userId,
    required String termId,
    required String subjectId,
    required String classTemplateId,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final exception = ClassException(
      id: _uuid.v4(),
      classTemplateId: classTemplateId,
      date: date,
      isCancelled: true,
      createdAt: now,
      updatedAt: now,
    );

    await _db.classDao.cancelClass(classTemplateId, date, exception.id);

    await _queueSync('classException', exception.id, 'create', exception.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/classExceptions/${exception.id}');

    return exception;
  }

  /// Add notes to class
  Future<ClassException> addClassNotes({
    required String userId,
    required String termId,
    required String subjectId,
    required String classTemplateId,
    required DateTime date,
    required String notes,
  }) async {
    final now = DateTime.now();
    final exception = ClassException(
      id: _uuid.v4(),
      classTemplateId: classTemplateId,
      date: date,
      isCancelled: false,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    await _db.classDao.addClassNotes(classTemplateId, date, exception.id, notes);

    return exception;
  }

  // ============================================
  // EXAMS
  // ============================================

  /// Get exams for subject
  Future<List<Exam>> getExamsForSubject(String subjectId) async {
    final entities = await _db.examDao.getExamsForSubject(subjectId);
    return entities.map(_examEntityToModel).toList();
  }

  /// Watch exams for subject
  Stream<List<Exam>> watchExamsForSubject(String subjectId) {
    return _db.examDao.watchExamsForSubject(subjectId).map(
          (entities) => entities.map(_examEntityToModel).toList(),
        );
  }

  /// Get all exams for user
  Future<List<Exam>> getExamsForUser(String userId) async {
    final entities = await _db.examDao.getExamsForUser(userId);
    return entities.map(_examEntityToModel).toList();
  }

  /// Get upcoming exams
  Future<List<Exam>> getUpcomingExamsForUser(String userId) async {
    final entities = await _db.examDao.getUpcomingExamsForUser(userId);
    return entities.map(_examEntityToModel).toList();
  }

  /// Get exams for today
  Future<List<Exam>> getExamsForToday(String userId, DateTime today) async {
    final entities = await _db.examDao.getExamsForToday(userId, today);
    return entities.map(_examEntityToModel).toList();
  }

  /// Create exam
  Future<Exam> createExam({
    required String userId,
    required String termId,
    required String subjectId,
    required String name,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? weightId,
    String? building,
    String? room,
    String? teacherId,
  }) async {
    final now = DateTime.now();
    final exam = Exam(
      id: _uuid.v4(),
      name: name,
      date: date,
      startTime: startTime,
      endTime: endTime,
      weightId: weightId,
      building: building,
      room: room,
      teacherId: teacherId,
      createdAt: now,
      updatedAt: now,
    );

    await _db.examDao.insertExam(_examModelToCompanion(exam, subjectId));

    await _queueSync('exam', exam.id, 'create', exam.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/exams/${exam.id}');

    if (_connectivity.isOnline) {
      await _syncExamToFirestore(userId, termId, subjectId, exam);
    }

    return exam;
  }

  /// Update exam
  Future<void> updateExam(String userId, String termId, String subjectId, Exam exam) async {
    final updated = exam.copyWith(updatedAt: DateTime.now());

    await _db.examDao.updateExam(_examModelToCompanion(updated, subjectId));

    await _queueSync('exam', updated.id, 'update', updated.toJson(),
        'users/$userId/terms/$termId/subjects/$subjectId/exams/${updated.id}');

    if (_connectivity.isOnline) {
      await _syncExamToFirestore(userId, termId, subjectId, updated);
    }
  }

  /// Mark exam as completed
  Future<void> markExamCompleted(String examId, bool completed) async {
    await _db.examDao.markAsCompleted(examId, completed);
  }

  /// Update exam grade
  Future<void> updateExamGrade(String examId, double? grade, bool isGraded) async {
    await _db.examDao.updateGrade(examId, grade, isGraded);
  }

  /// Delete exam
  Future<void> deleteExam(
      String userId, String termId, String subjectId, String examId) async {
    await _db.examDao.deleteExam(examId);

    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('exams')
          .doc(examId)
          .delete();
    }
  }

  // ============================================
  // CONVERSION HELPERS
  // ============================================

  Term _termEntityToModel(TermEntity entity) {
    return Term(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TermsCompanion _termModelToCompanion(Term term, String userId) {
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
    );
  }

  Subject _subjectEntityToModel(SubjectEntity entity) {
    return Subject(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      credits: entity.credits,
      finalGrade: entity.finalGrade,
      useFinalGradeOverride: entity.useFinalGradeOverride,
      weights: Weight.fromJsonString(entity.weightsJson),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  SubjectsCompanion _subjectModelToCompanion(Subject subject, String termId) {
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
    );
  }

  Assignment _assignmentEntityToModel(AssignmentEntity entity) {
    return Assignment(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime,
      weightId: entity.weightId,
      priority: Priority.fromString(entity.priority),
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      isGraded: entity.isGraded,
      grade: entity.grade,
      alerts: Alert.fromJsonString(entity.alertsJson),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  AssignmentsCompanion _assignmentModelToCompanion(Assignment assignment, String subjectId) {
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
    );
  }

  ClassTemplate _classTemplateEntityToModel(ClassTemplateEntity entity) {
    return ClassTemplate(
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

  ClassTemplatesCompanion _classTemplateModelToCompanion(ClassTemplate template, String subjectId) {
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
    );
  }

  ClassException _classExceptionEntityToModel(ClassExceptionEntity entity) {
    return ClassException(
      id: entity.id,
      classTemplateId: entity.classTemplateId,
      date: entity.date,
      isCancelled: entity.isCancelled,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Exam _examEntityToModel(ExamEntity entity) {
    return Exam(
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

  ExamsCompanion _examModelToCompanion(Exam exam, String subjectId) {
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
    );
  }

  // ============================================
  // SYNC HELPERS
  // ============================================

  Future<void> _queueSync(String entityType, String entityId, String operation,
      Map<String, dynamic> data, String documentPath) async {
    await _db.syncDao.queueSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }

  Future<void> _syncTermToFirestore(String userId, Term term) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(term.id)
          .set(term.toFirestore(), SetOptions(merge: true));
      await _db.termDao.markAsSynced(term.id);
    } catch (e) {
      print('Error syncing term: $e');
    }
  }

  Future<void> _syncSubjectToFirestore(String userId, String termId, Subject subject) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subject.id)
          .set(subject.toFirestore(), SetOptions(merge: true));
      await _db.subjectDao.markAsSynced(subject.id);
    } catch (e) {
      print('Error syncing subject: $e');
    }
  }

  Future<void> _syncAssignmentToFirestore(
      String userId, String termId, String subjectId, Assignment assignment) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('assignments')
          .doc(assignment.id)
          .set(assignment.toFirestore(), SetOptions(merge: true));
      await _db.assignmentDao.markAsSynced(assignment.id);
    } catch (e) {
      print('Error syncing assignment: $e');
    }
  }

  Future<void> _syncClassTemplateToFirestore(
      String userId, String termId, String subjectId, ClassTemplate template) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('classTemplates')
          .doc(template.id)
          .set(template.toFirestore(), SetOptions(merge: true));
      await _db.classDao.markClassTemplateAsSynced(template.id);
    } catch (e) {
      print('Error syncing class template: $e');
    }
  }

  Future<void> _syncExamToFirestore(
      String userId, String termId, String subjectId, Exam exam) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .doc(termId)
          .collection('subjects')
          .doc(subjectId)
          .collection('exams')
          .doc(exam.id)
          .set(exam.toFirestore(), SetOptions(merge: true));
      await _db.examDao.markAsSynced(exam.id);
    } catch (e) {
      print('Error syncing exam: $e');
    }
  }
}