import '../local/database/app_database.dart';

/// Repository for managing sync queue operations
/// Provides abstraction over sync queue DAO
class SyncRepository {
  final AppDatabase _db;

  SyncRepository({required AppDatabase database}) : _db = database;

  /// Get all pending sync items
  Future<List<SyncQueueEntity>> getPendingSyncItems() async {
    return await _db.syncDao.getPendingSyncItems();
  }

  /// Get count of pending sync items
  Future<int> getPendingSyncCount() async {
    return await _db.syncDao.getPendingSyncCount();
  }

  /// Delete a sync item after successful sync
  Future<void> deleteSyncItem(int id) async {
    await _db.syncDao.deleteSyncItem(id);
  }

  /// Increment retry count when sync fails
  Future<void> incrementRetryCount(int id, String errorMessage) async {
    await _db.syncDao.incrementRetryCount(id, errorMessage);
  }

  /// Delete items that have failed too many times
  Future<void> deleteFailedItems({int maxRetries = 3}) async {
    await _db.syncDao.deleteFailedItems(maxRetries: maxRetries);
  }

  /// Queue a sync operation (used by other repositories)
  Future<void> queueSync({
    required String entityType,
    required String entityId,
    required String operation,
    required String dataJson,
    required String documentPath,
  }) async {
    await _db.syncDao.queueSync(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      dataJson: dataJson,
      documentPath: documentPath,
    );
  }

  /// Clear all pending sync items (for testing/debugging)
  Future<void> clearAllPendingItems() async {
    final items = await getPendingSyncItems();
    for (final item in items) {
      await deleteSyncItem(item.id);
    }
  }
}
