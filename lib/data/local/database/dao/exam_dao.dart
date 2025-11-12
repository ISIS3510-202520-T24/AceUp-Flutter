import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/academic_tables.dart';

part 'exam_dao.g.dart';

@DriftAccessor(tables: [Exams])
class ExamDao extends DatabaseAccessor<AppDatabase> with _$ExamDaoMixin {
  ExamDao(AppDatabase db) : super(db);

  // ==================== CREATE ====================

  /// Crear o actualizar exam
  Future<void> upsertExam(ExamsCompanion exam) async {
    await into(exams).insert(
      exam,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update exams
  Future<void> upsertExamsBatch(List<ExamsCompanion> examsList) async {
    await batch((batch) {
      batch.insertAll(
        exams,
        examsList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== READ ====================

  /// Obtener exam por ID
  Future<Exam?> getExamById(String id) async {
    return await (select(exams)
      ..where((e) => e.id.equals(id) & e.isDeleted.equals(false))
    ).getSingleOrNull();
  }

  /// Obtener todos los exams de un usuario
  Future<List<Exam>> getAllExamsForUser(String userId) async {
    return await (select(exams)
      ..where((e) => e.userId.equals(userId) & e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.asc(e.date)])
    ).get();
  }

  /// Obtener exams de un term específico
  Future<List<Exam>> getExamsForTerm(String termId) async {
    return await (select(exams)
      ..where((e) => e.termId.equals(termId) & e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.asc(e.date)])
    ).get();
  }

  /// Obtener exams de un subject específico
  Future<List<Exam>> getExamsForSubject(String subjectId) async {
    return await (select(exams)
      ..where((e) => e.subjectId.equals(subjectId) & e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.asc(e.date)])
    ).get();
  }

  /// Obtener exams pendientes (no completados)
  Future<List<Exam>> getPendingExams(String userId) async {
    return await (select(exams)
      ..where((e) =>
      e.userId.equals(userId) &
      e.isCompleted.equals(false) &
      e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.asc(e.date)])
    ).get();
  }

  /// Obtener exams completados
  Future<List<Exam>> getCompletedExams(String userId) async {
    return await (select(exams)
      ..where((e) =>
      e.userId.equals(userId) &
      e.isCompleted.equals(true) &
      e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.desc(e.completedAt)])
    ).get();
  }

  /// Obtener exams para una fecha específica
  Future<List<Exam>> getExamsForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (select(exams)
      ..where((e) =>
      e.userId.equals(userId) &
      e.date.isBetweenValues(startOfDay, endOfDay) &
      e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.asc(e.date)])
    ).get();
  }

  /// Obtener exams de hoy
  Future<List<Exam>> getExamsToday(String userId, DateTime today) async {
    return await getExamsForDate(userId, today);
  }

  /// Obtener exams que necesitan sincronización
  Future<List<Exam>> getExamsNeedingSync() async {
    return await (select(exams)
      ..where((e) => e.needsSync.equals(true))
    ).get();
  }

  // ==================== UPDATE ====================

  /// Actualizar completion status de un exam
  Future<void> updateExamCompletion(String id, bool isCompleted) async {
    await (update(exams)..where((e) => e.id.equals(id))).write(
      ExamsCompanion(
        isCompleted: Value(isCompleted),
        completedAt: isCompleted ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Actualizar grade de un exam
  Future<void> updateExamGrade(String id, int grade) async {
    await (update(exams)..where((e) => e.id.equals(id))).write(
      ExamsCompanion(
        grade: Value(grade),
        isGraded: Value(grade > 0),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Marcar exam como necesitando sincronización
  Future<void> markForSync(String id) async {
    await (update(exams)..where((e) => e.id.equals(id))).write(
      const ExamsCompanion(needsSync: Value(true)),
    );
  }

  /// Marcar exam como sincronizado
  Future<void> markAsSynced(String id) async {
    await (update(exams)..where((e) => e.id.equals(id))).write(
      const ExamsCompanion(needsSync: Value(false)),
    );
  }

  // ==================== DELETE ====================

  /// Soft delete - marcar como eliminado
  Future<void> softDeleteExam(String id) async {
    await (update(exams)..where((e) => e.id.equals(id))).write(
      ExamsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Hard delete - eliminar permanentemente
  Future<void> hardDeleteExam(String id) async {
    await (delete(exams)..where((e) => e.id.equals(id))).go();
  }

  /// Eliminar todos los exams de un usuario
  Future<void> deleteAllExamsForUser(String userId) async {
    await (delete(exams)..where((e) => e.userId.equals(userId))).go();
  }

  /// Eliminar exams antiguos (cache cleanup)
  Future<void> deleteOldCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(exams)..where((e) => e.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }
}