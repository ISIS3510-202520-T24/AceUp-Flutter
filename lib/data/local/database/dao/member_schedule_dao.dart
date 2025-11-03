// lib/data/local/database/dao/member_schedule_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'member_schedule_dao.g.dart';

/// DAO para cachear horarios de clases de miembros del grupo
/// Necesario para calcular free blocks offline
@DriftAccessor(tables: [Terms, Subjects, ClassTemplates])
class MemberScheduleDao extends DatabaseAccessor<AppDatabase> with _$MemberScheduleDaoMixin {
  MemberScheduleDao(AppDatabase db) : super(db);

  // ==================== TERMS ====================
  
  /// Cachear terms de un usuario
  Future<void> cacheUserTerms(String userId, List<TermsCompanion> termsList) async {
    await batch((batch) {
      batch.insertAll(terms, termsList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Obtener terms de un usuario
  Future<List<Term>> getUserTerms(String userId) {
    return (select(terms)..where((t) => t.userId.equals(userId))).get();
  }

  // ==================== SUBJECTS ====================
  
  /// Cachear subjects de un term
  Future<void> cacheTermSubjects(String termId, List<SubjectsCompanion> subjectsList) async {
    await batch((batch) {
      batch.insertAll(subjects, subjectsList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Obtener subjects de un term
  Future<List<Subject>> getTermSubjects(String termId) {
    return (select(subjects)..where((s) => s.termId.equals(termId))).get();
  }

  /// Obtener todos los subjects de un usuario
  Future<List<Subject>> getUserSubjects(String userId) {
    return (select(subjects)..where((s) => s.userId.equals(userId))).get();
  }

  // ==================== CLASS TEMPLATES ====================
  
  /// Cachear class templates de un subject
  Future<void> cacheSubjectClasses(String subjectId, List<ClassTemplatesCompanion> classesList) async {
    await batch((batch) {
      batch.insertAll(classTemplates, classesList, mode: InsertMode.insertOrReplace);
    });
  }

  /// Obtener class templates de un subject
  Future<List<ClassTemplate>> getSubjectClasses(String subjectId) {
    return (select(classTemplates)..where((c) => c.subjectId.equals(subjectId))).get();
  }

  /// Obtener todas las clases de un usuario (para generar eventos)
  Future<List<ClassTemplate>> getUserClasses(String userId) {
    return (select(classTemplates)..where((c) => c.userId.equals(userId))).get();
  }

  /// Query completo: obtener terms > subjects > classes de un usuario
  Future<Map<String, dynamic>> getUserCompleteSchedule(String userId) async {
    final userTerms = await getUserTerms(userId);
    final result = <String, dynamic>{};

    for (final term in userTerms) {
      final termSubjects = await getTermSubjects(term.id);
      final subjectsData = <String, dynamic>{};

      for (final subject in termSubjects) {
        final classes = await getSubjectClasses(subject.id);
        subjectsData[subject.id] = {
          'subject': subject,
          'classes': classes,
        };
      }

      result[term.id] = {
        'term': term,
        'subjects': subjectsData,
      };
    }

    return result;
  }

  // ==================== CLEANUP ====================
  
  /// Limpiar datos de un usuario (cuando sale del grupo)
  Future<void> clearUserSchedule(String userId) async {
    await (delete(classTemplates)..where((c) => c.userId.equals(userId))).go();
    await (delete(subjects)..where((s) => s.userId.equals(userId))).go();
    await (delete(terms)..where((t) => t.userId.equals(userId))).go();
  }

  /// Limpiar caché antiguo (más de X días)
  Future<void> clearOldCache(Duration maxAge) async {
    final cutoffDate = DateTime.now().subtract(maxAge);
    await (delete(classTemplates)..where((c) => c.cachedAt.isSmallerThanValue(cutoffDate))).go();
    await (delete(subjects)..where((s) => s.cachedAt.isSmallerThanValue(cutoffDate))).go();
    await (delete(terms)..where((t) => t.cachedAt.isSmallerThanValue(cutoffDate))).go();
  }
}
