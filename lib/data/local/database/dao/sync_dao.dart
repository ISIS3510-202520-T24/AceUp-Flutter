import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get sync item by ID
  Future<SyncQueueEntity?> getSyncItemById(int id) {
    return (select(syncQueue)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get all pending sync items
  Future<List<SyncQueueEntity>> getPendingSyncItems() {
    return (select(syncQueue)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  /// Watch all pending sync items
  Stream<List<SyncQueueEntity>> watchPendingSyncItems() {
    return (select(syncQueue)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
  }

  /// Get sync items by entity type
  Future<List<SyncQueueEntity>> getSyncItemsByEntityType(String entityType) {
    return (select(syncQueue)
          ..where((t) => t.entityType.equals(entityType))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get sync items for specific entity
  Future<List<SyncQueueEntity>> getSyncItemsForEntity(String entityType, String entityId) {
    return (select(syncQueue)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get failed sync items (retry count > 0)
  Future<List<SyncQueueEntity>> getFailedSyncItems() {
    return (select(syncQueue)
          ..where((t) => t.retryCount.isBiggerThanValue(0))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get sync items that haven't exceeded max retries
  Future<List<SyncQueueEntity>> getSyncItemsToRetry({int maxRetries = 3}) {
    return (select(syncQueue)
          ..where((t) => t.retryCount.isSmallerThanValue(maxRetries))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get pending sync count
  Future<int> getPendingSyncCount() async {
    final countExp = syncQueue.id.count();
    final query = selectOnly(syncQueue)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Watch pending sync count
  Stream<int> watchPendingSyncCount() {
    final countExp = syncQueue.id.count();
    final query = selectOnly(syncQueue)..addColumns([countExp]);
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  // ==================== CREATE ====================

  /// Add sync item
  Future<int> addSyncItem(SyncQueueCompanion item) {
    return into(syncQueue).insert(item);
  }

  /// Add sync item for entity
  Future<int> queueSync({
    required String entityType,
    required String entityId,
    required String operation,
    required String dataJson,
    required String documentPath,
  }) {
    return addSyncItem(SyncQueueCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      dataJson: Value(dataJson),
      documentPath: Value(documentPath),
      createdAt: Value(DateTime.now()),
    ));
  }

  // ==================== UPDATE ====================

  /// Increment retry count - FIXED: Get current value first, then increment
  Future<void> incrementRetryCount(int id, String? errorMessage) async {
    // First, get the current item to read its retry count
    final item = await getSyncItemById(id);
    if (item == null) return;

    // Increment the retry count
    final newRetryCount = item.retryCount + 1;

    // Update with the new value
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: Value(newRetryCount),
        errorMessage: Value(errorMessage),
      ),
    );
  }

  /// Update error message
  Future<void> updateErrorMessage(int id, String errorMessage) async {
    await (update(syncQueue)..where((t) => t.id.equals(id))).write(
      SyncQueueCompanion(
        errorMessage: Value(errorMessage),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete sync item by ID (after successful sync)
  Future<int> deleteSyncItem(int id) {
    return (delete(syncQueue)..where((t) => t.id.equals(id))).go();
  }

  /// Delete sync items for entity
  Future<int> deleteSyncItemsForEntity(String entityType, String entityId) {
    return (delete(syncQueue)
          ..where((t) => t.entityType.equals(entityType) & t.entityId.equals(entityId)))
        .go();
  }

  /// Delete all sync items (clear queue)
  Future<int> clearSyncQueue() {
    return delete(syncQueue).go();
  }

  /// Delete sync items that exceeded max retries
  Future<int> deleteFailedItems({int maxRetries = 3}) {
    return (delete(syncQueue)..where((t) => t.retryCount.isBiggerOrEqualValue(maxRetries))).go();
  }

  // ==================== BATCH OPERATIONS ====================

  /// Process and delete batch of sync items
  Future<void> markItemsAsSynced(List<int> ids) async {
    await (delete(syncQueue)..where((t) => t.id.isIn(ids))).go();
  }

  /// Remove duplicate sync items for same entity (keep latest)
  Future<void> removeDuplicates() async {
    // This is a simplification - in production, you'd want more sophisticated deduplication
    final items = await getPendingSyncItems();
    final Map<String, SyncQueueEntity> latestItems = {};

    for (final item in items) {
      final key = '${item.entityType}:${item.entityId}';
      if (latestItems.containsKey(key)) {
        // Delete the older duplicate
        await deleteSyncItem(latestItems[key]!.id);
      }
      latestItems[key] = item;
    }
  }
}