import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'teacher_dao.g.dart';

@DriftAccessor(tables: [Teachers])
class TeacherDao extends DatabaseAccessor<AppDatabase> with _$TeacherDaoMixin {
  TeacherDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get teacher by ID
  Future<TeacherEntity?> getTeacherById(String id) {
    return (select(teachers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch teacher by ID
  Stream<TeacherEntity?> watchTeacherById(String id) {
    return (select(teachers)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all teachers for user
  Future<List<TeacherEntity>> getTeachersForUser(String userId) {
    return (select(teachers)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all teachers for user
  Stream<List<TeacherEntity>> watchTeachersForUser(String userId) {
    return (select(teachers)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Search teachers by name
  Future<List<TeacherEntity>> searchTeachers(String userId, String query) {
    return (select(teachers)
          ..where((t) => t.userId.equals(userId) & t.name.contains(query)))
        .get();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update teacher
  Future<void> upsertTeacher(TeachersCompanion teacher) {
    return into(teachers).insertOnConflictUpdate(teacher);
  }

  /// Insert teacher
  Future<void> insertTeacher(TeachersCompanion teacher) {
    return into(teachers).insert(teacher, mode: InsertMode.insertOrReplace);
  }

  /// Update teacher
  Future<bool> updateTeacher(TeachersCompanion teacher) {
    return (update(teachers)..where((t) => t.id.equals(teacher.id.value)))
        .write(teacher)
        .then((rows) => rows > 0);
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(teachers)..where((t) => t.id.equals(id))).write(
      TeachersCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete teacher by ID
  Future<int> deleteTeacher(String id) {
    return (delete(teachers)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all teachers for user
  Future<int> deleteTeachersForUser(String userId) {
    return (delete(teachers)..where((t) => t.userId.equals(userId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get teachers that need sync
  Future<List<TeacherEntity>> getTeachersNeedingSync() {
    return (select(teachers)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark teacher as synced
  Future<void> markAsSynced(String id) {
    return (update(teachers)..where((t) => t.id.equals(id))).write(
      TeachersCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple teachers (batch)
  Future<void> insertTeachersBatch(List<TeachersCompanion> teachersList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(teachers, teachersList);
    });
  }
}