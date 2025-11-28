import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'subject_dao.g.dart';

@DriftAccessor(tables: [Subjects, Terms])
class SubjectDao extends DatabaseAccessor<AppDatabase> with _$SubjectDaoMixin {
  SubjectDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get subject by ID
  Future<SubjectEntity?> getSubjectById(String id) {
    return (select(subjects)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch subject by ID
  Stream<SubjectEntity?> watchSubjectById(String id) {
    return (select(subjects)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all subjects for term
  Future<List<SubjectEntity>> getSubjectsForTerm(String termId) {
    return (select(subjects)
          ..where((t) => t.termId.equals(termId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all subjects for term
  Stream<List<SubjectEntity>> watchSubjectsForTerm(String termId) {
    return (select(subjects)
          ..where((t) => t.termId.equals(termId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Get all subjects for user (across all terms)
  Future<List<SubjectEntity>> getSubjectsForUser(String userId) async {
    final userTerms = await (select(terms)..where((t) => t.userId.equals(userId))).get();
    final termIds = userTerms.map((t) => t.id).toList();
    if (termIds.isEmpty) return [];
    
    return (select(subjects)..where((t) => t.termId.isIn(termIds))).get();
  }

  /// Get subjects for active term
  Future<List<SubjectEntity>> getSubjectsForActiveTerm(String userId) async {
    final activeTerm = await (select(terms)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true)))
        .getSingleOrNull();
    
    if (activeTerm == null) return [];
    
    return getSubjectsForTerm(activeTerm.id);
  }

  /// Watch subjects for active term
  Stream<List<SubjectEntity>> watchSubjectsForActiveTerm(String userId) async* {
    final activeTermStream = (select(terms)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true)))
        .watchSingleOrNull();
    
    await for (final activeTerm in activeTermStream) {
      if (activeTerm == null) {
        yield [];
      } else {
        yield await getSubjectsForTerm(activeTerm.id);
      }
    }
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update subject
  Future<void> upsertSubject(SubjectsCompanion subject) {
    return into(subjects).insertOnConflictUpdate(subject);
  }

  /// Insert subject
  Future<void> insertSubject(SubjectsCompanion subject) {
    return into(subjects).insert(subject, mode: InsertMode.insertOrReplace);
  }

  /// Update subject
  Future<bool> updateSubject(SubjectsCompanion subject) {
    return (update(subjects)..where((t) => t.id.equals(subject.id.value)))
        .write(subject)
        .then((rows) => rows > 0);
  }

  /// Update final grade
  Future<void> updateFinalGrade(String id, double? grade, bool useOverride) {
    return (update(subjects)..where((t) => t.id.equals(id))).write(
      SubjectsCompanion(
        finalGrade: Value(grade),
        useFinalGradeOverride: Value(useOverride),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update weights
  Future<void> updateWeights(String id, String weightsJson) {
    return (update(subjects)..where((t) => t.id.equals(id))).write(
      SubjectsCompanion(
        weightsJson: Value(weightsJson),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(subjects)..where((t) => t.id.equals(id))).write(
      SubjectsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete subject by ID
  Future<int> deleteSubject(String id) {
    return (delete(subjects)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all subjects for term
  Future<int> deleteSubjectsForTerm(String termId) {
    return (delete(subjects)..where((t) => t.termId.equals(termId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get subjects that need sync
  Future<List<SubjectEntity>> getSubjectsNeedingSync() {
    return (select(subjects)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark subject as synced
  Future<void> markAsSynced(String id) {
    return (update(subjects)..where((t) => t.id.equals(id))).write(
      SubjectsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple subjects (batch)
  Future<void> insertSubjectsBatch(List<SubjectsCompanion> subjectsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(subjects, subjectsList);
    });
  }

  // ==================== STATISTICS ====================

  /// Get total credits for term
  Future<int> getTotalCreditsForTerm(String termId) async {
    final termSubjects = await getSubjectsForTerm(termId);
    int totalCredits = 0;
    for (final subject in termSubjects) {
      totalCredits += subject.credits;
    }
    return totalCredits;
  }
}