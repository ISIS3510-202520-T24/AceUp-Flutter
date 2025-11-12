import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/academic_tables.dart';

part 'assignment_dao.g.dart';

@DriftAccessor(tables: [Assignments])
class AssignmentDao extends DatabaseAccessor<AppDatabase> with _$AssignmentDaoMixin {
  AssignmentDao(AppDatabase db) : super(db);

  // ==================== CREATE ====================

  /// Crear o actualizar assignment
  Future<void> upsertAssignment(AssignmentsCompanion assignment) async {
    await into(assignments).insert(
      assignment,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update assignments
  Future<void> upsertAssignmentsBatch(List<AssignmentsCompanion> assignmentsList) async {
    await batch((batch) {
      batch.insertAll(
        assignments,
        assignmentsList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== READ ====================

  /// Obtener assignment por ID
  Future<Assignment?> getAssignmentById(String id) async {
    return await (select(assignments)
      ..where((a) => a.id.equals(id) & a.isDeleted.equals(false))
    ).getSingleOrNull();
  }

  /// Obtener todos los assignments de un usuario (across all terms)
  Future<List<Assignment>> getAllAssignmentsForUser(String userId) async {
    return await (select(assignments)
      ..where((a) => a.userId.equals(userId) & a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.dueDate)])
    ).get();
  }

  /// Obtener assignments de un term específico
  Future<List<Assignment>> getAssignmentsForTerm(String termId) async {
    return await (select(assignments)
      ..where((a) => a.termId.equals(termId) & a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.dueDate)])
    ).get();
  }

  /// Obtener assignments de un subject específico
  Future<List<Assignment>> getAssignmentsForSubject(String subjectId) async {
    return await (select(assignments)
      ..where((a) => a.subjectId.equals(subjectId) & a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.dueDate)])
    ).get();
  }

  /// Obtener assignments pendientes (status = 'Pending')
  Future<List<Assignment>> getPendingAssignments(String userId) async {
    return await (select(assignments)
      ..where((a) =>
      a.userId.equals(userId) &
      a.status.equals('Pending') &
      a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.dueDate)])
    ).get();
  }

  /// Obtener assignments completados
  Future<List<Assignment>> getCompletedAssignments(String userId) async {
    return await (select(assignments)
      ..where((a) =>
      a.userId.equals(userId) &
      a.status.equals('Completed') &
      a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.desc(a.completedAt)])
    ).get();
  }

  /// Obtener assignments que vencen hoy
  Future<List<Assignment>> getAssignmentsDueToday(String userId, DateTime today) async {
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (select(assignments)
      ..where((a) =>
      a.userId.equals(userId) &
      a.dueDate.isBetweenValues(startOfDay, endOfDay) &
      a.isDeleted.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.dueDate)])
    ).get();
  }

  /// Obtener assignments que necesitan sincronización
  Future<List<Assignment>> getAssignmentsNeedingSync() async {
    return await (select(assignments)
      ..where((a) => a.needsSync.equals(true))
    ).get();
  }

  // ==================== UPDATE ====================

  /// Actualizar status de un assignment
  Future<void> updateAssignmentStatus(String id, String newStatus) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      AssignmentsCompanion(
        status: Value(newStatus),
        completedAt: newStatus == 'Completed' ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Actualizar grade de un assignment
  Future<void> updateAssignmentGrade(String id, int grade) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      AssignmentsCompanion(
        grade: Value(grade),
        isGraded: Value(grade > 0),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Marcar assignment como necesitando sincronización
  Future<void> markForSync(String id) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      const AssignmentsCompanion(needsSync: Value(true)),
    );
  }

  /// Marcar assignment como sincronizado
  Future<void> markAsSynced(String id) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      const AssignmentsCompanion(needsSync: Value(false)),
    );
  }

  // ==================== DELETE ====================

  /// Soft delete - marcar como eliminado
  Future<void> softDeleteAssignment(String id) async {
    await (update(assignments)..where((a) => a.id.equals(id))).write(
      AssignmentsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Hard delete - eliminar permanentemente
  Future<void> hardDeleteAssignment(String id) async {
    await (delete(assignments)..where((a) => a.id.equals(id))).go();
  }

  /// Eliminar todos los assignments de un usuario
  Future<void> deleteAllAssignmentsForUser(String userId) async {
    await (delete(assignments)..where((a) => a.userId.equals(userId))).go();
  }

  /// Eliminar assignments antiguos (cache cleanup)
  Future<void> deleteOldCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(assignments)..where((a) => a.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }
}