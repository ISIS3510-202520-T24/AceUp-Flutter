import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/academic_tables.dart';

part 'teacher_dao.g.dart';

@DriftAccessor(tables: [Teachers])
class TeacherDao extends DatabaseAccessor<AppDatabase> with _$TeacherDaoMixin {
  TeacherDao(AppDatabase db) : super(db);

  // ==================== CREATE ====================

  /// Crear o actualizar teacher
  Future<void> upsertTeacher(TeachersCompanion teacher) async {
    await into(teachers).insert(
      teacher,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update teachers
  Future<void> upsertTeachersBatch(List<TeachersCompanion> teachersList) async {
    await batch((batch) {
      batch.insertAll(
        teachers,
        teachersList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== READ ====================

  /// Obtener teacher por ID
  Future<Teacher?> getTeacherById(String id) async {
    return await (select(teachers)
      ..where((t) => t.id.equals(id) & t.isDeleted.equals(false))
    ).getSingleOrNull();
  }

  /// Obtener todos los teachers de un usuario
  Future<List<Teacher>> getAllTeachersForUser(String userId) async {
    return await (select(teachers)
      ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
    ).get();
  }

  /// Buscar teachers por nombre
  Future<List<Teacher>> searchTeachersByName(String userId, String searchQuery) async {
    return await (select(teachers)
      ..where((t) =>
      t.userId.equals(userId) &
      t.name.like('%$searchQuery%') &
      t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
    ).get();
  }

  /// Obtener teachers por departamento
  Future<List<Teacher>> getTeachersByDepartment(String userId, String department) async {
    return await (select(teachers)
      ..where((t) =>
      t.userId.equals(userId) &
      t.department.equals(department) &
      t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.name)])
    ).get();
  }

  /// Obtener teachers que necesitan sincronización
  Future<List<Teacher>> getTeachersNeedingSync() async {
    return await (select(teachers)
      ..where((t) => t.needsSync.equals(true))
    ).get();
  }

  // ==================== UPDATE ====================

  /// Actualizar información de contacto
  Future<void> updateTeacherContact(
      String id, {
        String? email,
        String? phone,
        String? officeLocation,
        String? officeHours,
      }) async {
    await (update(teachers)..where((t) => t.id.equals(id))).write(
      TeachersCompanion(
        email: email != null ? Value(email) : const Value.absent(),
        phone: phone != null ? Value(phone) : const Value.absent(),
        officeLocation: officeLocation != null ? Value(officeLocation) : const Value.absent(),
        officeHours: officeHours != null ? Value(officeHours) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Marcar teacher como necesitando sincronización
  Future<void> markForSync(String id) async {
    await (update(teachers)..where((t) => t.id.equals(id))).write(
      const TeachersCompanion(needsSync: Value(true)),
    );
  }

  /// Marcar teacher como sincronizado
  Future<void> markAsSynced(String id) async {
    await (update(teachers)..where((t) => t.id.equals(id))).write(
      const TeachersCompanion(needsSync: Value(false)),
    );
  }

  // ==================== DELETE ====================

  /// Soft delete - marcar como eliminado
  Future<void> softDeleteTeacher(String id) async {
    await (update(teachers)..where((t) => t.id.equals(id))).write(
      TeachersCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Hard delete - eliminar permanentemente
  Future<void> hardDeleteTeacher(String id) async {
    await (delete(teachers)..where((t) => t.id.equals(id))).go();
  }

  /// Eliminar todos los teachers de un usuario
  Future<void> deleteAllTeachersForUser(String userId) async {
    await (delete(teachers)..where((t) => t.userId.equals(userId))).go();
  }

  /// Eliminar teachers antiguos (cache cleanup)
  Future<void> deleteOldCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(teachers)..where((t) => t.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }
}