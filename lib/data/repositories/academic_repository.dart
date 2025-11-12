import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../local/database/app_database.dart' as db;
import '../../models/assignments/assignment_model.dart';
import 'package:uuid/uuid.dart';

/// Repository that implements offline-first pattern for Academic functionality
///
/// Reads from local SQLite first, falls back to Firestore when needed,
/// queues write operations for background sync
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

  // ==================== ASSIGNMENTS ====================

  /// Get all assignments for user (offline-first)
  Future<List<Assignment>> getAllAssignmentsForUser(
      String userId, {
        bool skipFirestore = false,
      }) async {
    // 1. Load from local cache first
    final localAssignments = await _db.assignmentDao.getAllAssignmentsForUser(userId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localAssignments.length} assignments from cache');
      return localAssignments.map(_assignmentFromDb).toList();
    }

    // 2. Fetch from Firestore in background
    try {
      final assignments = await _fetchAssignmentsFromFirestore(userId);

      // 3. Update local cache
      await _cacheAssignments(assignments);

      return assignments;
    } catch (e) {
      print('⚠️ Error fetching assignments from Firestore, using cache: $e');
      return localAssignments.map(_assignmentFromDb).toList();
    }
  }

  /// Get assignments for a specific term
  Future<List<Assignment>> getAssignmentsForTerm(
      String userId,
      String termId, {
        bool skipFirestore = false,
      }) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsForTerm(termId);

    if (skipFirestore || !_connectivity.isOnline) {
      return localAssignments.map(_assignmentFromDb).toList();
    }

    try {
      final assignments = await _fetchAssignmentsFromFirestore(userId);
      await _cacheAssignments(assignments);

      // Filter by termId
      return assignments.where((a) => a.termId == termId).toList();
    } catch (e) {
      print('⚠️ Error fetching assignments, using cache: $e');
      return localAssignments.map(_assignmentFromDb).toList();
    }
  }

  /// Get assignments for a specific subject
  Future<List<Assignment>> getAssignmentsForSubject(
      String subjectId, {
        bool skipFirestore = false,
      }) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsForSubject(subjectId);

    if (skipFirestore) {
      return localAssignments.map(_assignmentFromDb).toList();
    }

    // Return cached for now (Firestore sync happens in background)
    return localAssignments.map(_assignmentFromDb).toList();
  }

  /// Get pending assignments
  Future<List<Assignment>> getPendingAssignments(String userId) async {
    final localAssignments = await _db.assignmentDao.getPendingAssignments(userId);
    return localAssignments.map(_assignmentFromDb).toList();
  }

  /// Get completed assignments
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    final localAssignments = await _db.assignmentDao.getCompletedAssignments(userId);
    return localAssignments.map(_assignmentFromDb).toList();
  }

  /// Get assignments due today
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final localAssignments = await _db.assignmentDao.getAssignmentsDueToday(userId, today);
    return localAssignments.map(_assignmentFromDb).toList();
  }

  /// Create or update assignment (offline-first)
  Future<void> saveAssignment(Assignment assignment) async {
    // 1. Save to local database immediately
    await _db.assignmentDao.upsertAssignment(_assignmentToDb(assignment, needsSync: true));

    // 2. Queue for sync if online
    if (_connectivity.isOnline) {
      await _syncAssignmentToFirestore(assignment);
    } else {
      print('📴 Offline: Assignment queued for sync');
    }
  }

  /// Update assignment status
  Future<void> updateAssignmentStatus(String id, String newStatus) async {
    await _db.assignmentDao.updateAssignmentStatus(id, newStatus);

    if (_connectivity.isOnline) {
      final assignment = await _db.assignmentDao.getAssignmentById(id);
      if (assignment != null) {
        await _syncAssignmentToFirestore(_assignmentFromDb(assignment));
      }
    }
  }

  /// Update assignment grade
  Future<void> updateAssignmentGrade(String id, int grade) async {
    await _db.assignmentDao.updateAssignmentGrade(id, grade);

    if (_connectivity.isOnline) {
      final assignment = await _db.assignmentDao.getAssignmentById(id);
      if (assignment != null) {
        await _syncAssignmentToFirestore(_assignmentFromDb(assignment));
      }
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(String id) async {
    await _db.assignmentDao.softDeleteAssignment(id);

    if (_connectivity.isOnline) {
      // TODO: Delete from Firestore
      print('🗑️ Assignment deleted locally, sync to Firestore pending');
    }
  }

  // ==================== PRIVATE HELPERS FOR ASSIGNMENTS ====================

  Future<List<Assignment>> _fetchAssignmentsFromFirestore(String userId) async {
    final allAssignments = <Assignment>[];

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

    return allAssignments;
  }

  Future<void> _cacheAssignments(List<Assignment> assignments) async {
    final companions = assignments.map((a) => _assignmentToDb(a)).toList();
    await _db.assignmentDao.upsertAssignmentsBatch(companions);
  }

  Future<void> _syncAssignmentToFirestore(Assignment assignment) async {
    try {
      final assignmentRef = _firestore
          .collection('users')
          .doc(assignment.userId!)
          .collection('terms')
          .doc(assignment.termId)
          .collection('subjects')
          .doc(assignment.subjectId)
          .collection('assignments')
          .doc(assignment.id);

      await assignmentRef.set({
        'title': assignment.title,
        'description': assignment.description,
        'dueDate': Timestamp.fromDate(assignment.dueDate),
        'priority': assignment.priority,
        'weight': assignment.weight,
        'grade': assignment.grade,
        'status': assignment.status,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      // Mark as synced
      await _db.assignmentDao.markAsSynced(assignment.id);

      print('✅ Assignment synced to Firestore');
    } catch (e) {
      print('❌ Error syncing assignment to Firestore: $e');
    }
  }

  db.AssignmentsCompanion _assignmentToDb(Assignment assignment, {bool needsSync = false}) {
    return db.AssignmentsCompanion.insert(
      id: assignment.id,
      userId: assignment.userId ?? '',
      termId: assignment.termId ?? '',
      subjectId: assignment.subjectId ?? '',
      title: assignment.title,
      description: Value(assignment.description),
      dueDate: assignment.dueDate,
      priority: Value(assignment.priority),
      weight: Value(assignment.weight),
      grade: Value(assignment.grade),
      status: Value(assignment.status),
      isGraded: Value(assignment.grade > 0),
      completedAt: assignment.status == 'Completed'
          ? Value(DateTime.now())
          : const Value(null),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      cachedAt: Value(DateTime.now()),
      needsSync: Value(needsSync),
      isDeleted: const Value(false),
    );
  }

  Assignment _assignmentFromDb(db.Assignment dbAssignment) {
    return Assignment(
      id: dbAssignment.id,
      title: dbAssignment.title,
      description: dbAssignment.description,
      dueDate: dbAssignment.dueDate,
      priority: dbAssignment.priority,
      weight: dbAssignment.weight,
      grade: dbAssignment.grade,
      status: dbAssignment.status,
      subjectName: '', // Will be populated from join if needed
      termId: dbAssignment.termId,
      subjectId: dbAssignment.subjectId,
      userId: dbAssignment.userId,
    );
  }

  // ==================== EXAMS ====================

  /// Get all exams for user
  Future<List<Map<String, dynamic>>> getAllExamsForUser(
      String userId, {
        bool skipFirestore = false,
      }) async {
    final localExams = await _db.examDao.getAllExamsForUser(userId);

    if (skipFirestore || !_connectivity.isOnline) {
      print('📦 Loaded ${localExams.length} exams from cache');
      return localExams.map(_examToMap).toList();
    }

    // TODO: Fetch from Firestore and cache
    return localExams.map(_examToMap).toList();
  }

  /// Get exams for a specific term
  Future<List<Map<String, dynamic>>> getExamsForTerm(String termId) async {
    final localExams = await _db.examDao.getExamsForTerm(termId);
    return localExams.map(_examToMap).toList();
  }

  /// Get exams for a specific subject
  Future<List<Map<String, dynamic>>> getExamsForSubject(String subjectId) async {
    final localExams = await _db.examDao.getExamsForSubject(subjectId);
    return localExams.map(_examToMap).toList();
  }

  /// Get pending exams
  Future<List<Map<String, dynamic>>> getPendingExams(String userId) async {
    final localExams = await _db.examDao.getPendingExams(userId);
    return localExams.map(_examToMap).toList();
  }

  /// Get exams for today
  Future<List<Map<String, dynamic>>> getExamsToday(String userId, DateTime today) async {
    final localExams = await _db.examDao.getExamsToday(userId, today);
    return localExams.map(_examToMap).toList();
  }

  /// Save exam
  Future<void> saveExam(Map<String, dynamic> examData) async {
    final examCompanion = _examDataToDb(examData);
    await _db.examDao.upsertExam(examCompanion);

    // TODO: Sync to Firestore if online
  }

  /// Update exam completion
  Future<void> updateExamCompletion(String id, bool isCompleted) async {
    await _db.examDao.updateExamCompletion(id, isCompleted);
  }

  /// Update exam grade
  Future<void> updateExamGrade(String id, int grade) async {
    await _db.examDao.updateExamGrade(id, grade);
  }

  /// Delete exam
  Future<void> deleteExam(String id) async {
    await _db.examDao.softDeleteExam(id);
  }

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
      'teacherId': exam.teacherId,
      'weight': exam.weight,
      'grade': exam.grade,
      'isCompleted': exam.isCompleted,
      'isGraded': exam.isGraded,
    };
  }

  db.ExamsCompanion _examDataToDb(Map<String, dynamic> data) {
    return db.ExamsCompanion.insert(
      id: data['id'] ?? _uuid.v4(),
      userId: data['userId'] ?? '',
      termId: data['termId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      title: data['title'] ?? '',
      description: Value(data['description'] ?? ''),
      date: data['date'] ?? DateTime.now(),
      startTime: Value(data['startTime']),
      endTime: Value(data['endTime']),
      location: Value(data['location']),
      teacherId: Value(data['teacherId']),
      weight: Value(data['weight'] ?? 10),
      grade: Value(data['grade'] ?? 0),
      isCompleted: Value(data['isCompleted'] ?? false),
      isGraded: Value(data['isGraded'] ?? false),
      needsSync: const Value(true),
    );
  }

  // ==================== HOLIDAYS ====================

  /// Get all holidays for user
  Future<List<Map<String, dynamic>>> getAllHolidaysForUser(String userId) async {
    final localHolidays = await _db.holidayDao.getAllHolidaysForUser(userId);
    return localHolidays.map(_holidayToMap).toList();
  }

  /// Get holidays by source (user or api)
  Future<List<Map<String, dynamic>>> getHolidaysBySource(
      String userId,
      String source,
      ) async {
    final localHolidays = await _db.holidayDao.getHolidaysBySource(userId, source);
    return localHolidays.map(_holidayToMap).toList();
  }

  /// Get upcoming holidays
  Future<List<Map<String, dynamic>>> getUpcomingHolidays(String userId) async {
    final localHolidays = await _db.holidayDao.getUpcomingHolidays(userId);
    return localHolidays.map(_holidayToMap).toList();
  }

  /// Check if date is holiday
  Future<bool> isHoliday(String userId, DateTime date) async {
    return await _db.holidayDao.isHoliday(userId, date);
  }

  /// Save holiday
  Future<void> saveHoliday(Map<String, dynamic> holidayData) async {
    final holidayCompanion = _holidayDataToDb(holidayData);
    await _db.holidayDao.upsertHoliday(holidayCompanion);
  }

  /// Save holidays batch (for API holidays)
  Future<void> saveHolidaysBatch(List<Map<String, dynamic>> holidaysData) async {
    final companions = holidaysData.map(_holidayDataToDb).toList();
    await _db.holidayDao.upsertHolidaysBatch(companions);
  }

  /// Delete holiday
  Future<void> deleteHoliday(String id) async {
    await _db.holidayDao.softDeleteHoliday(id);
  }

  /// Delete holidays by source (useful for refreshing API holidays)
  Future<void> deleteHolidaysBySource(String userId, String source) async {
    await _db.holidayDao.deleteHolidaysBySource(userId, source);
  }

  Map<String, dynamic> _holidayToMap(db.Holiday holiday) {
    return {
      'id': holiday.id,
      'userId': holiday.userId,
      'name': holiday.name,
      'startDate': holiday.startDate,
      'endDate': holiday.endDate,
      'source': holiday.source,
      'countryCode': holiday.countryCode,
    };
  }

  db.HolidaysCompanion _holidayDataToDb(Map<String, dynamic> data) {
    return db.HolidaysCompanion.insert(
      id: data['id'] ?? _uuid.v4(),
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      startDate: data['startDate'] ?? DateTime.now(),
      endDate: data['endDate'] ?? DateTime.now(),
      source: Value(data['source'] ?? 'user'),
      countryCode: Value(data['countryCode']),
      needsSync: Value(data['source'] == 'user'), // Only sync user-created holidays
    );
  }

  // ==================== TEACHERS ====================

  /// Get all teachers for user
  Future<List<Map<String, dynamic>>> getAllTeachersForUser(String userId) async {
    final localTeachers = await _db.teacherDao.getAllTeachersForUser(userId);
    return localTeachers.map(_teacherToMap).toList();
  }

  /// Search teachers by name
  Future<List<Map<String, dynamic>>> searchTeachersByName(
      String userId,
      String searchQuery,
      ) async {
    final localTeachers = await _db.teacherDao.searchTeachersByName(userId, searchQuery);
    return localTeachers.map(_teacherToMap).toList();
  }

  /// Save teacher
  Future<void> saveTeacher(Map<String, dynamic> teacherData) async {
    final teacherCompanion = _teacherDataToDb(teacherData);
    await _db.teacherDao.upsertTeacher(teacherCompanion);
  }

  /// Delete teacher
  Future<void> deleteTeacher(String id) async {
    await _db.teacherDao.softDeleteTeacher(id);
  }

  Map<String, dynamic> _teacherToMap(db.Teacher teacher) {
    return {
      'id': teacher.id,
      'userId': teacher.userId,
      'name': teacher.name,
      'position': teacher.position,
      'department': teacher.department,
      'affiliation': teacher.affiliation,
      'email': teacher.email,
      'phone': teacher.phone,
      'officeLocation': teacher.officeLocation,
      'officeHours': teacher.officeHours,
    };
  }

  db.TeachersCompanion _teacherDataToDb(Map<String, dynamic> data) {
    return db.TeachersCompanion.insert(
      id: data['id'] ?? _uuid.v4(),
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      position: Value(data['position']),
      department: Value(data['department']),
      affiliation: Value(data['affiliation']),
      email: Value(data['email']),
      phone: Value(data['phone']),
      officeLocation: Value(data['officeLocation']),
      officeHours: Value(data['officeHours']),
      needsSync: const Value(true),
    );
  }

  // ==================== TERMS & SUBJECTS ====================

  /// Get all terms for user
  Future<List<Map<String, dynamic>>> getAllTermsForUser(String userId) async {
    final localTerms = await _db.academicDao.getAllTermsForUser(userId);
    return localTerms.map(_termToMap).toList();
  }

  /// Get current term
  Future<Map<String, dynamic>?> getCurrentTerm(String userId) async {
    final term = await _db.academicDao.getCurrentTerm(userId);
    return term != null ? _termToMap(term) : null;
  }

  /// Get all subjects for user
  Future<List<Map<String, dynamic>>> getAllSubjectsForUser(String userId) async {
    final localSubjects = await _db.academicDao.getAllSubjectsForUser(userId);
    return localSubjects.map(_subjectDetailToMap).toList();
  }

  /// Get subjects for term
  Future<List<Map<String, dynamic>>> getSubjectsForTerm(String termId) async {
    final localSubjects = await _db.academicDao.getSubjectsForTerm(termId);
    return localSubjects.map(_subjectDetailToMap).toList();
  }

  /// Get term with subjects
  Future<Map<String, dynamic>> getTermWithSubjects(String termId) async {
    return await _db.academicDao.getTermWithSubjects(termId);
  }

  /// Get all terms with subjects
  Future<List<Map<String, dynamic>>> getAllTermsWithSubjects(String userId) async {
    return await _db.academicDao.getAllTermsWithSubjects(userId);
  }

  Map<String, dynamic> _termToMap(db.Term term) {
    return {
      'id': term.id,
      'userId': term.userId,
      'name': term.name,
      'startDate': term.startDate,
      'endDate': term.endDate,
    };
  }

  Map<String, dynamic> _subjectDetailToMap(db.SubjectDetail subject) {
    return {
      'id': subject.id,
      'userId': subject.userId,
      'termId': subject.termId,
      'name': subject.name,
      'code': subject.code,
      'color': subject.color,
      'credits': subject.credits,
      'teacherId': subject.teacherId,
      'location': subject.location,
      'useFinalGradeOverride': subject.useFinalGradeOverride,
      'finalGrade': subject.finalGrade,
      'isCompleted': subject.isCompleted,
    };
  }
}