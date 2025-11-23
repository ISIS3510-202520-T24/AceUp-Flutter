import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'exam_dao.g.dart';

@DriftAccessor(tables: [Exams, Subjects, Terms])
class ExamDao extends DatabaseAccessor<AppDatabase> with _$ExamDaoMixin {
  ExamDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get exam by ID
  Future<ExamEntity?> getExamById(String id) {
    return (select(exams)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch exam by ID
  Stream<ExamEntity?> watchExamById(String id) {
    return (select(exams)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all exams for subject
  Future<List<ExamEntity>> getExamsForSubject(String subjectId) {
    return (select(exams)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Watch all exams for subject
  Stream<List<ExamEntity>> watchExamsForSubject(String subjectId) {
    return (select(exams)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  /// Get all exams for user
  Future<List<ExamEntity>> getExamsForUser(String userId) async {
    final userTerms = await (select(terms)..where((t) => t.userId.equals(userId))).get();
    final termIds = userTerms.map((t) => t.id).toList();
    if (termIds.isEmpty) return [];

    final userSubjects = await (select(subjects)..where((t) => t.termId.isIn(termIds))).get();
    final subjectIds = userSubjects.map((s) => s.id).toList();
    if (subjectIds.isEmpty) return [];

    return (select(exams)
          ..where((t) => t.subjectId.isIn(subjectIds))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Get upcoming exams for user
  Future<List<ExamEntity>> getUpcomingExamsForUser(String userId) async {
    final now = DateTime.now();
    final allExams = await getExamsForUser(userId);
    return allExams.where((e) => !e.isCompleted && e.date.isAfter(now)).toList();
  }

  /// Get exams for today
  Future<List<ExamEntity>> getExamsForToday(String userId, DateTime today) async {
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final allExams = await getExamsForUser(userId);
    return allExams.where((e) {
      return !e.date.isBefore(startOfDay) && e.date.isBefore(endOfDay);
    }).toList();
  }

  /// Get exams for date range
  Future<List<ExamEntity>> getExamsForDateRange(
      String userId, DateTime startDate, DateTime endDate) async {
    final allExams = await getExamsForUser(userId);
    return allExams.where((e) {
      return !e.date.isBefore(startDate) && e.date.isBefore(endDate);
    }).toList();
  }

  /// Get graded exams for subject
  Future<List<ExamEntity>> getGradedExamsForSubject(String subjectId) {
    return (select(exams)
          ..where((t) => t.subjectId.equals(subjectId) & t.isGraded.equals(true)))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update exam
  Future<void> upsertExam(ExamsCompanion exam) {
    return into(exams).insertOnConflictUpdate(exam);
  }

  /// Insert exam
  Future<void> insertExam(ExamsCompanion exam) {
    return into(exams).insert(exam, mode: InsertMode.insertOrReplace);
  }

  /// Update exam
  Future<bool> updateExam(ExamsCompanion exam) {
    return (update(exams)..where((t) => t.id.equals(exam.id.value)))
        .write(exam)
        .then((rows) => rows > 0);
  }

  /// Mark as completed
  Future<void> markAsCompleted(String id, bool completed) {
    return (update(exams)..where((t) => t.id.equals(id))).write(
      ExamsCompanion(
        isCompleted: Value(completed),
        completedAt: completed ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update grade
  Future<void> updateGrade(String id, double? grade, bool isGraded) {
    return (update(exams)..where((t) => t.id.equals(id))).write(
      ExamsCompanion(
        grade: Value(grade),
        isGraded: Value(isGraded),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(exams)..where((t) => t.id.equals(id))).write(
      ExamsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete exam by ID
  Future<int> deleteExam(String id) {
    return (delete(exams)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all exams for subject
  Future<int> deleteExamsForSubject(String subjectId) {
    return (delete(exams)..where((t) => t.subjectId.equals(subjectId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get exams that need sync
  Future<List<ExamEntity>> getExamsNeedingSync() {
    return (select(exams)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark exam as synced
  Future<void> markAsSynced(String id) {
    return (update(exams)..where((t) => t.id.equals(id))).write(
      ExamsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple exams (batch)
  Future<void> insertExamsBatch(List<ExamsCompanion> examsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(exams, examsList);
    });
  }
}