// lib/data/repositories/academic_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../local/database/app_database.dart' as db;
import '../local/database/dao/assignment_dao.dart';
import '../../models/assignments/assignment_model.dart';
import 'package:uuid/uuid.dart';

/// Repository that implements offline-first pattern for Academic/Planner functionality
///
/// **Offline-First Pattern:**
/// 1. All reads come from local SQLite database first
/// 2. All writes go to local SQLite first, marked as needsSync=true
/// 3. SyncService handles background Firebase sync when online
/// 4. Firebase is treated as a backup/sync target, not primary source
class AcademicRepository {
  final db.AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  AcademicRepository({
    required db.AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== TERMS ====================

  /// Get all terms for user (from local database)
  Future<List<db.Term>> getAllTermsForUser(String userId) async {
    print('📖 Reading terms from local database for user $userId');
    return await _db.academicDao.getAllTermsForUser(userId);
  }

  /// Get term by ID (from local database)
  Future<db.Term?> getTermById(String termId) async {
    print('📖 Reading term $termId from local database');
    return await _db.academicDao.getTermById(termId);
  }

  /// Create a new term (offline-first)
  Future<void> createTerm({
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? color,
  }) async {
    final termId = _uuid.v4();
    final now = DateTime.now();

    print('✏️ Creating term "$name" locally (ID: $termId)');

    // 1. Store in local database first
    await _db.academicDao.upsertTerm(
      db.TermsCompanion.insert(
        id: termId,
        userId: userId,
        name: name,
        startDate: startDate,
        endDate: endDate,
        color: Value(color ?? '#6200EA'),
        createdAt: now,
        updatedAt: now,
        cachedAt: now,
        needsSync: const Value(true), // Mark for sync
        isDeleted: const Value(false),
      ),
    );

    // 2. Queue sync operation
    await _queueSyncOperation(
      entityType: 'term',
      entityId: termId,
      operation: 'create',
      data: {
        'userId': userId,
        'name': name,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'color': color ?? '#6200EA',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
    );

    print('✅ Term created locally and queued for sync');
  }

  /// Update a term (offline-first)
  Future<void> updateTerm({
    required String termId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
  }) async {
    print('✏️ Updating term $termId locally');

    // Get existing term
    final existingTerm = await _db.academicDao.getTermById(termId);
    if (existingTerm == null) {
      print('❌ Term $termId not found');
      return;
    }

    // Update in local database
    await _db.academicDao.upsertTerm(
      db.TermsCompanion(
        id: Value(termId),
        name: Value(name ?? existingTerm.name),
        startDate: Value(startDate ?? existingTerm.startDate),
        endDate: Value(endDate ?? existingTerm.endDate),
        color: Value(color ?? existingTerm.color),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'term',
      entityId: termId,
      operation: 'update',
      data: {
        'name': name ?? existingTerm.name,
        'startDate': Timestamp.fromDate(startDate ?? existingTerm.startDate),
        'endDate': Timestamp.fromDate(endDate ?? existingTerm.endDate),
        'color': color ?? existingTerm.color,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
    );

    print('✅ Term updated locally and queued for sync');
  }

  /// Delete a term (offline-first soft delete)
  Future<void> deleteTerm(String termId) async {
    print('🗑️ Soft deleting term $termId locally');

    // Soft delete in local database
    await _db.academicDao.upsertTerm(
      db.TermsCompanion(
        id: Value(termId),
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'term',
      entityId: termId,
      operation: 'delete',
      data: {},
    );

    print('✅ Term soft deleted locally and queued for sync');
  }

  // ==================== SUBJECTS ====================

  /// Get all subjects for a term (from local database)
  Future<List<db.SubjectDetail>> getSubjectsForTerm(String termId) async {
    print('📖 Reading subjects for term $termId from local database');
    return await _db.academicDao.getSubjectsForTerm(termId);
  }

  /// Get subject by ID (from local database)
  Future<db.SubjectDetail?> getSubjectById(String subjectId) async {
    print('📖 Reading subject $subjectId from local database');
    return await _db.academicDao.getSubjectDetailById(subjectId);
  }

  /// Create a new subject (offline-first)
  Future<void> createSubject({
    required String userId,
    required String termId,
    required String name,
    String? code,
    required int credits,
    String? color,
  }) async {
    final subjectId = _uuid.v4();
    final now = DateTime.now();

    print('✏️ Creating subject "$name" locally (ID: $subjectId)');

    // Store in local database
    await _db.academicDao.upsertSubjectDetail(
      db.SubjectDetailsCompanion.insert(
        id: subjectId,
        userId: userId,
        termId: termId,
        name: name,
        code: Value(code),
        color: color ?? '#2196F3',
        credits: credits,
        useFinalGradeOverride: const Value(false),
        isCompleted: const Value(false),
        createdAt: now,
        updatedAt: now,
        cachedAt: now,
        needsSync: const Value(true),
        isDeleted: const Value(false),
      ),
    );

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'subject',
      entityId: subjectId,
      operation: 'create',
      data: {
        'userId': userId,
        'termId': termId,
        'name': name,
        'code': code,
        'color': color ?? '#2196F3',
        'credits': credits,
        'useFinalGradeOverride': false,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      },
    );

    print('✅ Subject created locally and queued for sync');
  }

  /// Update a subject (offline-first)
  Future<void> updateSubject({
    required String subjectId,
    String? name,
    String? code,
    int? credits,
    String? color,
    bool? useFinalGradeOverride,
    double? finalGrade,
  }) async {
    print('✏️ Updating subject $subjectId locally');

    // Get existing subject
    final existingSubject = await _db.academicDao.getSubjectDetailById(subjectId);
    if (existingSubject == null) {
      print('❌ Subject $subjectId not found');
      return;
    }

    // Update in local database
    await _db.academicDao.upsertSubjectDetail(
      db.SubjectDetailsCompanion(
        id: Value(subjectId),
        name: Value(name ?? existingSubject.name),
        code: Value(code ?? existingSubject.code),
        credits: Value(credits ?? existingSubject.credits),
        color: Value(color ?? existingSubject.color),
        useFinalGradeOverride: Value(useFinalGradeOverride ?? existingSubject.useFinalGradeOverride),
        finalGrade: Value(finalGrade ?? existingSubject.finalGrade),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'subject',
      entityId: subjectId,
      operation: 'update',
      data: {
        'name': name ?? existingSubject.name,
        'code': code ?? existingSubject.code,
        'credits': credits ?? existingSubject.credits,
        'color': color ?? existingSubject.color,
        'useFinalGradeOverride': useFinalGradeOverride ?? existingSubject.useFinalGradeOverride,
        'finalGrade': finalGrade ?? existingSubject.finalGrade,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
    );

    print('✅ Subject updated locally and queued for sync');
  }

  /// Delete a subject (offline-first soft delete)
  Future<void> deleteSubject(String subjectId) async {
    print('🗑️ Soft deleting subject $subjectId locally');

    // Soft delete in local database
    await _db.academicDao.softDeleteSubject(subjectId);

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'subject',
      entityId: subjectId,
      operation: 'delete',
      data: {},
    );

    print('✅ Subject soft deleted locally and queued for sync');
  }

  // ==================== ASSIGNMENTS ====================

  /// Get all assignments for user (offline-first)
  Future<List<Assignment>> getAllAssignmentsForUser(
    String userId, {
    bool skipFirestore = false,
  }) async {
    // Load from local cache first (with subject names via join)
    final localAssignments = await _db.assignmentDao.getAllAssignmentsForUser(userId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localAssignments.length} assignments from cache');
      return localAssignments.map(_assignmentWithSubjectToModel).toList();
    }

    // Return cached (background sync handled by InitialLoadService)
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Get assignments for a specific term
  Future<List<Assignment>> getAssignmentsForTerm(
    String userId,
    String termId, {
    bool skipFirestore = false,
  }) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsForTerm(termId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localAssignments.length} assignments for term from cache');
      return localAssignments.map(_assignmentWithSubjectToModel).toList();
    }

    // Return cached (background sync handled by InitialLoadService)
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Get assignments for a specific subject
  Future<List<Assignment>> getAssignmentsForSubject(
    String subjectId, {
    bool skipFirestore = false,
  }) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsForSubject(subjectId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localAssignments.length} assignments for subject from cache');
      return localAssignments.map(_assignmentWithSubjectToModel).toList();
    }

    // Return cached (background sync handled by InitialLoadService)
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Get pending assignments
  Future<List<Assignment>> getPendingAssignments(String userId) async {
    final localAssignments = await _db.assignmentDao.getPendingAssignments(userId);
    print('📦 Loaded ${localAssignments.length} pending assignments from cache');
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Get completed assignments
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    final localAssignments = await _db.assignmentDao.getCompletedAssignments(userId);
    print('📦 Loaded ${localAssignments.length} completed assignments from cache');
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Get assignments due today
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsDueToday(userId, today);
    print('📦 Loaded ${localAssignments.length} assignments due today from cache');
    return localAssignments.map(_assignmentWithSubjectToModel).toList();
  }

  /// Create or update assignment (offline-first)
  Future<void> saveAssignment(Assignment assignment) async {
    print('✏️ Saving assignment "${assignment.title}" locally');

    // 1. Save to local database immediately
    await _db.assignmentDao.upsertAssignment(_assignmentToDb(assignment, needsSync: true));

    // 2. Queue sync operation
    await _queueSyncOperation(
      entityType: 'assignment',
      entityId: assignment.id,
      operation: 'create',
      data: {
        'userId': assignment.userId,
        'termId': assignment.termId,
        'subjectId': assignment.subjectId,
        'title': assignment.title,
        'description': assignment.description,
        'dueDate': Timestamp.fromDate(assignment.dueDate),
        'priority': assignment.priority,
        'weightId': '', // Will be mapped to weight category
        'isCompleted': assignment.status == 'Completed',
        'isGraded': assignment.grade > 0,
        'grade': assignment.grade,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      },
    );

    print('✅ Assignment saved locally and queued for sync');
  }

  /// Update assignment status (offline-first)
  Future<void> updateAssignmentStatus(String id, String newStatus) async {
    print('✏️ Updating assignment status to $newStatus');
    
    await _db.assignmentDao.updateAssignmentStatus(id, newStatus);

    // Queue sync operation
    final assignment = await _db.assignmentDao.getAssignmentById(id);
    if (assignment != null) {
      await _queueSyncOperation(
        entityType: 'assignment',
        entityId: id,
        operation: 'update',
        data: {
          'status': newStatus,
          'completedAt': newStatus == 'Completed' ? Timestamp.now() : null,
          'updatedAt': Timestamp.now(),
        },
      );
    }

    print('✅ Assignment status updated and queued for sync');
  }

  /// Update assignment grade (offline-first)
  Future<void> updateAssignmentGrade(String id, int grade) async {
    print('✏️ Updating assignment grade to $grade');
    
    await _db.assignmentDao.updateAssignmentGrade(id, grade);

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'assignment',
      entityId: id,
      operation: 'update',
      data: {
        'grade': grade,
        'isGraded': grade > 0,
        'updatedAt': Timestamp.now(),
      },
    );

    print('✅ Assignment grade updated and queued for sync');
  }

  /// Delete assignment (offline-first soft delete)
  Future<void> deleteAssignment(String id) async {
    print('🗑️ Soft deleting assignment $id');
    
    await _db.assignmentDao.softDeleteAssignment(id);

    // Queue sync operation
    await _queueSyncOperation(
      entityType: 'assignment',
      entityId: id,
      operation: 'delete',
      data: {},
    );

    print('✅ Assignment deleted and queued for sync');
  }

  // ==================== EXAMS ====================

  /// Get all exams for user (offline-first)
  Future<List<Map<String, dynamic>>> getAllExamsForUser(
    String userId, {
    bool skipFirestore = false,
  }) async {
    final localExams = await _db.examDao.getAllExamsForUser(userId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localExams.length} exams from cache');
      return localExams.map((e) => _examToMap(e)).toList();
    }

    // Return cached (background sync handled by InitialLoadService)
    return localExams.map((e) => _examToMap(e)).toList();
  }

  // ==================== PRIVATE HELPERS ====================

  /// Queue an operation for background sync to Firebase
  Future<void> _queueSyncOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.syncDao.addSyncItem(
        db.SyncQueueCompanion.insert(
          entityType: entityType,
          entityId: entityId,
          operation: operation,
          data: db.Value(data.isNotEmpty ? data : null),
          createdAt: DateTime.now(),
        ),
      );
      print('📤 Queued sync: $operation $entityType $entityId');
    } catch (e) {
      print('❌ Error queuing sync operation: $e');
    }
  }

  /// Convert Assignment model to Drift companion for database storage
  db.AssignmentsCompanion _assignmentToDb(Assignment assignment, {bool needsSync = false}) {
    return db.AssignmentsCompanion.insert(
      id: assignment.id,
      userId: assignment.userId ?? '',
      termId: assignment.termId ?? '',
      subjectId: assignment.subjectId ?? '',
      title: assignment.title,
      description: db.Value(assignment.description),
      dueDate: assignment.dueDate,
      priority: db.Value(assignment.priority),
      weight: db.Value(assignment.weight),
      grade: db.Value(assignment.grade),
      status: db.Value(assignment.status),
      isGraded: db.Value(assignment.grade > 0),
      completedAt: assignment.status == 'Completed'
          ? db.Value(DateTime.now())
          : const db.Value(null),
      createdAt: db.Value(DateTime.now()),
      updatedAt: db.Value(DateTime.now()),
      cachedAt: db.Value(DateTime.now()),
      needsSync: db.Value(needsSync),
      isDeleted: const db.Value(false),
    );
  }

  /// Convert AssignmentWithSubject from DAO to Assignment model
  Assignment _assignmentWithSubjectToModel(AssignmentWithSubject aws) {
    return Assignment(
      id: aws.assignment.id,
      title: aws.assignment.title,
      description: aws.assignment.description,
      dueDate: aws.assignment.dueDate,
      priority: aws.assignment.priority,
      weight: aws.assignment.weight,
      grade: aws.assignment.grade,
      status: aws.assignment.status,
      subjectName: aws.subjectName,
      termId: aws.assignment.termId,
      subjectId: aws.assignment.subjectId,
      userId: aws.assignment.userId,
    );
  }

  /// Convert Exam from Drift to Map
  Map<String, dynamic> _examToMap(db.Exam exam) {
    return {
      'id': exam.id,
      'userId': exam.userId,
      'termId': exam.termId,
      'subjectId': exam.subjectId,
      'title': exam.title,
      'description': exam.description,
      'date': exam.date,
      'startTime': exam.startTime,
      'endTime': exam.endTime,
      'location': exam.location,
      'weight': exam.weight,
      'grade': exam.grade,
      'status': exam.isCompleted,
    };
  }
}