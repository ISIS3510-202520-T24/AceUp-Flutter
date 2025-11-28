import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'term_dao.g.dart';

@DriftAccessor(tables: [Terms])
class TermDao extends DatabaseAccessor<AppDatabase> with _$TermDaoMixin {
  TermDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get term by ID
  Future<TermEntity?> getTermById(String id) {
    return (select(terms)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch term by ID
  Stream<TermEntity?> watchTermById(String id) {
    return (select(terms)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all terms for user
  Future<List<TermEntity>> getTermsForUser(String userId) {
    return (select(terms)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  /// Watch all terms for user
  Stream<List<TermEntity>> watchTermsForUser(String userId) {
    return (select(terms)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  /// Get active term for user
  Future<TermEntity?> getActiveTermForUser(String userId) {
    return (select(terms)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true)))
        .getSingleOrNull();
  }

  /// Watch active term for user
  Stream<TermEntity?> watchActiveTermForUser(String userId) {
    return (select(terms)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true)))
        .watchSingleOrNull();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update term
  Future<void> upsertTerm(TermsCompanion term) {
    return into(terms).insertOnConflictUpdate(term);
  }

  /// Insert term
  Future<void> insertTerm(TermsCompanion term) {
    return into(terms).insert(term, mode: InsertMode.insertOrReplace);
  }

  /// Update term
  Future<bool> updateTerm(TermsCompanion term) {
    return (update(terms)..where((t) => t.id.equals(term.id.value)))
        .write(term)
        .then((rows) => rows > 0);
  }

  /// Set active term (and deactivate others)
  Future<void> setActiveTerm(String userId, String termId) async {
    await transaction(() async {
      // Deactivate all terms for user
      await (update(terms)..where((t) => t.userId.equals(userId))).write(
        const TermsCompanion(
          isActive: Value(false),
          syncStatus: Value('pending'),
        ),
      );
      // Activate the specified term
      await (update(terms)..where((t) => t.id.equals(termId))).write(
        TermsCompanion(
          isActive: const Value(true),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    });
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(terms)..where((t) => t.id.equals(id))).write(
      TermsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete term by ID
  Future<int> deleteTerm(String id) {
    return (delete(terms)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all terms for user
  Future<int> deleteTermsForUser(String userId) {
    return (delete(terms)..where((t) => t.userId.equals(userId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get terms that need sync
  Future<List<TermEntity>> getTermsNeedingSync() {
    return (select(terms)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark term as synced
  Future<void> markAsSynced(String id) {
    return (update(terms)..where((t) => t.id.equals(id))).write(
      TermsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple terms (batch)
  Future<void> insertTermsBatch(List<TermsCompanion> termsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(terms, termsList);
    });
  }
}