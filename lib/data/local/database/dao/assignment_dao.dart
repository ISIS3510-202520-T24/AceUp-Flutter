import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'assignment_dao.g.dart';

@DriftAccessor(tables: [Assignments, Subjects, Terms])
class AssignmentDao extends DatabaseAccessor<AppDatabase> with _$AssignmentDaoMixin {
  AssignmentDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get assignment by ID
  Future<AssignmentEntity?> getAssignmentById(String id) {
    return (select(assignments)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch assignment by ID
  Stream<AssignmentEntity?> watchAssignmentById(String id) {
    return (select(assignments)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all assignments for subject
  Future<List<AssignmentEntity>> getAssignmentsForSubject(String subjectId) {
    return (select(assignments)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Watch all assignments for subject
  Stream<List<AssignmentEntity>> watchAssignmentsForSubject(String subjectId) {
    return (select(assignments)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Get all assignments for user (across all subjects/terms)
  Future<List<AssignmentEntity>> getAssignmentsForUser(String userId) async {
    final userTerms = await (select(terms)..where((t) => t.userId.equals(userId))).get();
    final termIds = userTerms.map((t) => t.id).toList();
    if (termIds.isEmpty) return [];

    final userSubjects = await (select(subjects)..where((t) => t.termId.isIn(termIds))).get();
    final subjectIds = userSubjects.map((s) => s.id).toList();
    if (subjectIds.isEmpty) return [];

    return (select(assignments)
          ..where((t) => t.subjectId.isIn(subjectIds))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get pending assignments for user
  Future<List<AssignmentEntity>> getPendingAssignmentsForUser(String userId) async {
    final allAssignments = await getAssignmentsForUser(userId);
    return allAssignments.where((a) => !a.isCompleted).toList();
  }

  /// Get completed assignments for user
  Future<List<AssignmentEntity>> getCompletedAssignmentsForUser(String userId) async {
    final allAssignments = await getAssignmentsForUser(userId);
    return allAssignments.where((a) => a.isCompleted).toList();
  }

  /// Get assignments due today
  Future<List<AssignmentEntity>> getAssignmentsDueToday(String userId, DateTime today) async {
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final allAssignments = await getAssignmentsForUser(userId);
    return allAssignments.where((a) {
      return !a.dueDate.isBefore(startOfDay) && a.dueDate.isBefore(endOfDay);
    }).toList();
  }

  /// Get upcoming assignments (next 7 days)
  Future<List<AssignmentEntity>> getUpcomingAssignments(String userId) async {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    final allAssignments = await getAssignmentsForUser(userId);
    return allAssignments.where((a) {
      return !a.isCompleted && a.dueDate.isAfter(now) && a.dueDate.isBefore(weekFromNow);
    }).toList();
  }

  /// Get overdue assignments
  Future<List<AssignmentEntity>> getOverdueAssignments(String userId) async {
    final now = DateTime.now();

    final allAssignments = await getAssignmentsForUser(userId);
    return allAssignments.where((a) {
      return !a.isCompleted && a.dueDate.isBefore(now);
    }).toList();
  }

  /// Get graded assignments for subject
  Future<List<AssignmentEntity>> getGradedAssignmentsForSubject(String subjectId) {
    return (select(assignments)
          ..where((t) => t.subjectId.equals(subjectId) & t.isGraded.equals(true)))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update assignment
  Future<void> upsertAssignment(AssignmentsCompanion assignment) {
    return into(assignments).insertOnConflictUpdate(assignment);
  }

  /// Insert assignment
  Future<void> insertAssignment(AssignmentsCompanion assignment) {
    return into(assignments).insert(assignment, mode: InsertMode.insertOrReplace);
  }

  /// Update assignment
  Future<bool> updateAssignment(AssignmentsCompanion assignment) {
    return (update(assignments)..where((t) => t.id.equals(assignment.id.value)))
        .write(assignment)
        .then((rows) => rows > 0);
  }

  /// Mark as completed
  Future<void> markAsCompleted(String id, bool completed) {
    return (update(assignments)..where((t) => t.id.equals(id))).write(
      AssignmentsCompanion(
        isCompleted: Value(completed),
        completedAt: completed ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update grade
  Future<void> updateGrade(String id, double? grade, bool isGraded) {
    return (update(assignments)..where((t) => t.id.equals(id))).write(
      AssignmentsCompanion(
        grade: Value(grade),
        isGraded: Value(isGraded),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(assignments)..where((t) => t.id.equals(id))).write(
      AssignmentsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete assignment by ID
  Future<int> deleteAssignment(String id) {
    return (delete(assignments)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all assignments for subject
  Future<int> deleteAssignmentsForSubject(String subjectId) {
    return (delete(assignments)..where((t) => t.subjectId.equals(subjectId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get assignments that need sync
  Future<List<AssignmentEntity>> getAssignmentsNeedingSync() {
    return (select(assignments)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark assignment as synced
  Future<void> markAsSynced(String id) {
    return (update(assignments)..where((t) => t.id.equals(id))).write(
      AssignmentsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple assignments (batch)
  Future<void> insertAssignmentsBatch(List<AssignmentsCompanion> assignmentsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(assignments, assignmentsList);
    });
  }
}