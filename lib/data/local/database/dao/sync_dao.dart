// lib/data/local/database/dao/sync_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'sync_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(AppDatabase db) : super(db);

  // ==================== SYNC QUEUE ====================
  
  /// Agregar item a la cola de sincronización
  Future<int> addToSyncQueue(SyncQueueCompanion item) async {
    return await into(syncQueue).insert(item);
  }
  
  /// Obtener items pendientes de sincronización
  Future<List<SyncQueueData>> getPendingSyncItems() async {
    return (select(syncQueue)
      ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)])
      ..limit(100)) // Limitar a 100 items por batch
      .get();
  }
  
  /// Obtener items pendientes de un tipo específico
  Future<List<SyncQueueData>> getPendingSyncItemsByType(String entityType) async {
    return (select(syncQueue)
      ..where((sq) => sq.entityType.equals(entityType))
      ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]))
      .get();
  }
  
  /// Eliminar item de la cola (después de sincronizar)
  Future<void> removeFromSyncQueue(int id) async {
    await (delete(syncQueue)..where((sq) => sq.id.equals(id))).go();
  }
  
  /// Actualizar error de sincronización
  Future<void> updateSyncError(int id, String error, int currentRetryCount) async {
    await (update(syncQueue)..where((sq) => sq.id.equals(id)))
        .write(SyncQueueCompanion(
          lastError: Value(error),
          retryCount: Value(currentRetryCount + 1),
        ));
  }
  
  /// Eliminar items con muchos errores (más de 5 reintentos)
  Future<void> clearFailedSyncItems() async {
    await (delete(syncQueue)..where((sq) => sq.retryCount.isBiggerThanValue(5))).go();
  }

  /// Limpiar toda la cola de sincronización
  Future<void> clearSyncQueue() async {
    await delete(syncQueue).go();
  }

  // ==================== ESTADÍSTICAS ====================
  
  /// Contar items pendientes
  Future<int> countPendingItems() async {
    final result = await (selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()]))
      .getSingle();
    
    return result.read(syncQueue.id.count())!;
  }

  /// Verificar si una entidad específica tiene operaciones pendientes
  Future<bool> hasPendingSyncForEntity(String entityType, String entityId) async {
    final result = await (select(syncQueue)
      ..where((sq) => sq.entityType.equals(entityType) & sq.entityId.equals(entityId))
      ..limit(1))
      .get();
    
    return result.isNotEmpty;
  }

  /// Contar items por tipo
  Future<Map<String, int>> countItemsByType() async {
    final items = await select(syncQueue).get();
    final counts = <String, int>{};
    
    for (final item in items) {
      counts[item.entityType] = (counts[item.entityType] ?? 0) + 1;
    }
    
    return counts;
  }

  Future<List<SyncQueueData>> getAllPendingOperations() async {
    return await (select(syncQueue)
      ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)])
    ).get();
  }

  // ==================== STREAMS ====================
  
  /// Watch cola de sincronización
  Stream<List<SyncQueueData>> watchSyncQueue() {
    return (select(syncQueue)
      ..orderBy([(sq) => OrderingTerm.asc(sq.createdAt)]))
      .watch();
  }

  /// Watch count de items pendientes
  Stream<int> watchPendingCount() {
    return (selectOnly(syncQueue)
      ..addColumns([syncQueue.id.count()]))
      .watchSingle()
      .map((row) => row.read(syncQueue.id.count())!);
  }
}
