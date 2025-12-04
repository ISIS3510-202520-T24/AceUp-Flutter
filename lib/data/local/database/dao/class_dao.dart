import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'class_dao.g.dart';

@DriftAccessor(tables: [ClassTemplates, ClassExceptions, Subjects, Terms])
class ClassDao extends DatabaseAccessor<AppDatabase> with _$ClassDaoMixin {
  ClassDao(AppDatabase db) : super(db);

  // ==================== CLASS TEMPLATES - READ ====================

  /// Get class template by ID
  Future<ClassTemplateEntity?> getClassTemplateById(String id) {
    return (select(classTemplates)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch class template by ID
  Stream<ClassTemplateEntity?> watchClassTemplateById(String id) {
    return (select(classTemplates)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all class templates for subject
  Future<List<ClassTemplateEntity>> getClassTemplatesForSubject(String subjectId) {
    return (select(classTemplates)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  /// Watch all class templates for subject
  Stream<List<ClassTemplateEntity>> watchClassTemplatesForSubject(String subjectId) {
    return (select(classTemplates)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  /// Get all class templates for user
  Future<List<ClassTemplateEntity>> getClassTemplatesForUser(String userId) async {
    final userTerms = await (select(terms)..where((t) => t.userId.equals(userId))).get();
    final termIds = userTerms.map((t) => t.id).toList();
    if (termIds.isEmpty) return [];

    final userSubjects = await (select(subjects)..where((t) => t.termId.isIn(termIds))).get();
    final subjectIds = userSubjects.map((s) => s.id).toList();
    if (subjectIds.isEmpty) return [];

    return (select(classTemplates)..where((t) => t.subjectId.isIn(subjectIds))).get();
  }

  /// Get class templates for active term
  Future<List<ClassTemplateEntity>> getClassTemplatesForActiveTerm(String userId) async {
    final activeTerm = await (select(terms)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true)))
        .getSingleOrNull();

    if (activeTerm == null) return [];

    final termSubjects = await (select(subjects)..where((t) => t.termId.equals(activeTerm.id))).get();
    final subjectIds = termSubjects.map((s) => s.id).toList();
    if (subjectIds.isEmpty) return [];

    return (select(classTemplates)..where((t) => t.subjectId.isIn(subjectIds))).get();
  }

  // ==================== CLASS TEMPLATES - CREATE/UPDATE ====================

  /// Insert or update class template
  Future<void> upsertClassTemplate(ClassTemplatesCompanion template) {
    return into(classTemplates).insertOnConflictUpdate(template);
  }

  /// Insert class template
  Future<void> insertClassTemplate(ClassTemplatesCompanion template) {
    return into(classTemplates).insert(template, mode: InsertMode.insertOrReplace);
  }

  /// Update class template
  Future<bool> updateClassTemplate(ClassTemplatesCompanion template) {
    return (update(classTemplates)..where((t) => t.id.equals(template.id.value)))
        .write(template)
        .then((rows) => rows > 0);
  }

  /// Update sync status
  Future<void> updateClassTemplateSyncStatus(String id, String status) {
    return (update(classTemplates)..where((t) => t.id.equals(id))).write(
      ClassTemplatesCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== CLASS TEMPLATES - DELETE ====================

  /// Delete class template by ID
  Future<int> deleteClassTemplate(String id) {
    return (delete(classTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all class templates for subject
  Future<int> deleteClassTemplatesForSubject(String subjectId) {
    return (delete(classTemplates)..where((t) => t.subjectId.equals(subjectId))).go();
  }

  // ==================== CLASS EXCEPTIONS - READ ====================

  /// Get class exception by ID
  Future<ClassExceptionEntity?> getClassExceptionById(String id) {
    return (select(classExceptions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get class exceptions for template
  Future<List<ClassExceptionEntity>> getExceptionsForTemplate(String classTemplateId) {
    return (select(classExceptions)
          ..where((t) => t.classTemplateId.equals(classTemplateId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Watch class exceptions for template
  Stream<List<ClassExceptionEntity>> watchExceptionsForTemplate(String classTemplateId) {
    return (select(classExceptions)
          ..where((t) => t.classTemplateId.equals(classTemplateId))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  /// Get exception for specific date
  Future<ClassExceptionEntity?> getExceptionForDate(String classTemplateId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(classExceptions)
          ..where((t) =>
              t.classTemplateId.equals(classTemplateId) &
              t.date.isBiggerOrEqualValue(startOfDay) &
              t.date.isSmallerThanValue(endOfDay)))
        .getSingleOrNull();
  }

  /// Get cancelled classes for template
  Future<List<ClassExceptionEntity>> getCancelledClassesForTemplate(String classTemplateId) {
    return (select(classExceptions)
          ..where((t) =>
              t.classTemplateId.equals(classTemplateId) & t.isCancelled.equals(true)))
        .get();
  }

  // ==================== CLASS EXCEPTIONS - CREATE/UPDATE ====================

  /// Insert or update class exception
  Future<void> upsertClassException(ClassExceptionsCompanion exception) {
    return into(classExceptions).insertOnConflictUpdate(exception);
  }

  /// Insert class exception
  Future<void> insertClassException(ClassExceptionsCompanion exception) {
    return into(classExceptions).insert(exception, mode: InsertMode.insertOrReplace);
  }

  /// Update class exception
  Future<bool> updateClassException(ClassExceptionsCompanion exception) {
    return (update(classExceptions)..where((t) => t.id.equals(exception.id.value)))
        .write(exception)
        .then((rows) => rows > 0);
  }

  /// Cancel class on specific date
  Future<void> cancelClass(String classTemplateId, DateTime date, String exceptionId) {
    return upsertClassException(ClassExceptionsCompanion(
      id: Value(exceptionId),
      classTemplateId: Value(classTemplateId),
      date: Value(date),
      isCancelled: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));
  }

  /// Add notes to class on specific date
  Future<void> addClassNotes(String classTemplateId, DateTime date, String exceptionId, String notes) {
    return upsertClassException(ClassExceptionsCompanion(
      id: Value(exceptionId),
      classTemplateId: Value(classTemplateId),
      date: Value(date),
      notes: Value(notes),
      isCancelled: const Value(false),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('pending'),
    ));
  }

  // ==================== CLASS EXCEPTIONS - DELETE ====================

  /// Delete class exception by ID
  Future<int> deleteClassException(String id) {
    return (delete(classExceptions)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all class exceptions for template
  Future<int> deleteExceptionsForTemplate(String classTemplateId) {
    return (delete(classExceptions)..where((t) => t.classTemplateId.equals(classTemplateId))).go();
  }

  /// Delete all class exceptions for subject
  Future<int> deleteClassExceptionsForSubject(String subjectId) async {
    final templates = await (select(classTemplates)..where((t) => t.subjectId.equals(subjectId))).get();
    final templateIds = templates.map((t) => t.id).toList();
    if (templateIds.isEmpty) return 0;

    return (delete(classExceptions)..where((t) => t.classTemplateId.isIn(templateIds))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get class templates that need sync
  Future<List<ClassTemplateEntity>> getClassTemplatesNeedingSync() {
    return (select(classTemplates)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Get class exceptions that need sync
  Future<List<ClassExceptionEntity>> getClassExceptionsNeedingSync() {
    return (select(classExceptions)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark class template as synced
  Future<void> markClassTemplateAsSynced(String id) {
    return (update(classTemplates)..where((t) => t.id.equals(id))).write(
      ClassTemplatesCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark class exception as synced
  Future<void> markClassExceptionAsSynced(String id) {
    return (update(classExceptions)..where((t) => t.id.equals(id))).write(
      ClassExceptionsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple class templates (batch)
  Future<void> insertClassTemplatesBatch(List<ClassTemplatesCompanion> templatesList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(classTemplates, templatesList);
    });
  }

  /// Insert multiple class exceptions (batch)
  Future<void> insertClassExceptionsBatch(List<ClassExceptionsCompanion> exceptionsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(classExceptions, exceptionsList);
    });
  }
}