import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';
import '../tables/academic_tables.dart';

part 'academic_dao.g.dart';

@DriftAccessor(tables: [Terms, SubjectDetails])
class AcademicDao extends DatabaseAccessor<AppDatabase> with _$AcademicDaoMixin {
  AcademicDao(AppDatabase db) : super(db);

  // ==================== TERMS ====================

  /// Crear o actualizar term
  Future<void> upsertTerm(TermsCompanion term) async {
    await into(terms).insert(
      term,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update terms
  Future<void> upsertTermsBatch(List<TermsCompanion> termsList) async {
    await batch((batch) {
      batch.insertAll(
        terms,
        termsList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Obtener term por ID
  Future<Term?> getTermById(String id) async {
    return await (select(terms)
      ..where((t) => t.id.equals(id))
    ).getSingleOrNull();
  }

  /// Obtener todos los terms de un usuario
  Future<List<Term>> getAllTermsForUser(String userId) async {
    return await (select(terms)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.desc(t.startDate)])
    ).get();
  }

  /// Obtener term activo actual (basado en fecha actual)
  Future<Term?> getCurrentTerm(String userId) async {
    final now = DateTime.now();
    return await (select(terms)
      ..where((t) =>
      t.userId.equals(userId) &
      t.startDate.isSmallerOrEqualValue(now) &
      t.endDate.isBiggerOrEqualValue(now))
      ..limit(1)
    ).getSingleOrNull();
  }

  /// Eliminar term
  Future<void> deleteTerm(String id) async {
    await (delete(terms)..where((t) => t.id.equals(id))).go();
  }

  /// Eliminar todos los terms de un usuario
  Future<void> deleteAllTermsForUser(String userId) async {
    await (delete(terms)..where((t) => t.userId.equals(userId))).go();
  }

  // ==================== SUBJECT DETAILS ====================

  /// Crear o actualizar subject detail
  Future<void> upsertSubjectDetail(SubjectDetailsCompanion subject) async {
    await into(subjectDetails).insert(
      subject,
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Batch insert/update subjects
  Future<void> upsertSubjectDetailsBatch(List<SubjectDetailsCompanion> subjectsList) async {
    await batch((batch) {
      batch.insertAll(
        subjectDetails,
        subjectsList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Obtener subject por ID
  Future<SubjectDetail?> getSubjectDetailById(String id) async {
    return await (select(subjectDetails)
      ..where((s) => s.id.equals(id) & s.isDeleted.equals(false))
    ).getSingleOrNull();
  }

  /// Obtener todos los subjects de un term
  Future<List<SubjectDetail>> getSubjectsForTerm(String termId) async {
    return await (select(subjectDetails)
      ..where((s) => s.termId.equals(termId) & s.isDeleted.equals(false))
      ..orderBy([(s) => OrderingTerm.asc(s.name)])
    ).get();
  }

  /// Obtener todos los subjects de un usuario
  Future<List<SubjectDetail>> getAllSubjectsForUser(String userId) async {
    return await (select(subjectDetails)
      ..where((s) => s.userId.equals(userId) & s.isDeleted.equals(false))
      ..orderBy([(s) => OrderingTerm.asc(s.name)])
    ).get();
  }

  /// Obtener subjects completados
  Future<List<SubjectDetail>> getCompletedSubjects(String userId) async {
    return await (select(subjectDetails)
      ..where((s) =>
      s.userId.equals(userId) &
      s.isCompleted.equals(true) &
      s.isDeleted.equals(false))
      ..orderBy([(s) => OrderingTerm.desc(s.completedAt)])
    ).get();
  }

  /// Obtener subjects por teacher
  Future<List<SubjectDetail>> getSubjectsByTeacher(String userId, String teacherId) async {
    return await (select(subjectDetails)
      ..where((s) =>
      s.userId.equals(userId) &
      s.teacherId.equals(teacherId) &
      s.isDeleted.equals(false))
      ..orderBy([(s) => OrderingTerm.asc(s.name)])
    ).get();
  }

  /// Actualizar completion status de subject
  Future<void> updateSubjectCompletion(String id, bool isCompleted) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      SubjectDetailsCompanion(
        isCompleted: Value(isCompleted),
        completedAt: isCompleted ? Value(DateTime.now()) : const Value(null),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Actualizar final grade override
  Future<void> updateSubjectFinalGrade(String id, double? finalGrade) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      SubjectDetailsCompanion(
        finalGrade: Value(finalGrade),
        useFinalGradeOverride: Value(finalGrade != null),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Actualizar weight categories JSON
  Future<void> updateSubjectWeightCategories(String id, String weightCategoriesJson) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      SubjectDetailsCompanion(
        weightCategoriesJson: Value(weightCategoriesJson),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Marcar subject como necesitando sincronización
  Future<void> markSubjectForSync(String id) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      const SubjectDetailsCompanion(needsSync: Value(true)),
    );
  }

  /// Marcar subject como sincronizado
  Future<void> markSubjectAsSynced(String id) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      const SubjectDetailsCompanion(needsSync: Value(false)),
    );
  }

  /// Obtener subjects que necesitan sincronización
  Future<List<SubjectDetail>> getSubjectsNeedingSync() async {
    return await (select(subjectDetails)
      ..where((s) => s.needsSync.equals(true))
    ).get();
  }

  /// Soft delete - marcar subject como eliminado
  Future<void> softDeleteSubject(String id) async {
    await (update(subjectDetails)..where((s) => s.id.equals(id))).write(
      SubjectDetailsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        needsSync: const Value(true),
      ),
    );
  }

  /// Hard delete - eliminar subject permanentemente
  Future<void> hardDeleteSubject(String id) async {
    await (delete(subjectDetails)..where((s) => s.id.equals(id))).go();
  }

  /// Eliminar todos los subjects de un usuario
  Future<void> deleteAllSubjectsForUser(String userId) async {
    await (delete(subjectDetails)..where((s) => s.userId.equals(userId))).go();
  }

  /// Eliminar cache antiguo de subjects
  Future<void> deleteOldSubjectCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(subjectDetails)..where((s) => s.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }

  // ==================== QUERIES COMPLEJAS ====================

  /// Obtener término con todos sus subjects
  Future<Map<String, dynamic>> getTermWithSubjects(String termId) async {
    final term = await getTermById(termId);
    if (term == null) return {};

    final subjects = await getSubjectsForTerm(termId);

    return {
      'term': term,
      'subjects': subjects,
    };
  }

  /// Obtener todos los términos de un usuario con sus subjects
  Future<List<Map<String, dynamic>>> getAllTermsWithSubjects(String userId) async {
    final userTerms = await getAllTermsForUser(userId);
    final result = <Map<String, dynamic>>[];

    for (final term in userTerms) {
      final subjects = await getSubjectsForTerm(term.id);
      result.add({
        'term': term,
        'subjects': subjects,
      });
    }

    return result;
  }
}