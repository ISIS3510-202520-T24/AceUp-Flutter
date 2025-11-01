// lib/services/shared/sync_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../data/local/database/app_database.dart';

/// Service that handles background synchronization of local changes to Firestore
class SyncService extends ChangeNotifier {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  int _pendingOperationsCount = 0;

  bool get isSyncing => _isSyncing;
  int get pendingOperationsCount => _pendingOperationsCount;

  SyncService({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity {
    // Initialize pending count
    _updatePendingCount();
  }

  /// Start periodic sync (every 30 seconds when online)
  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    
    _syncTimer = Timer.periodic(interval, (_) {
      if (_connectivity.isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    });

    // Also sync when connectivity is restored
    _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    });
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manually trigger sync of pending operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) return;
    if (!_connectivity.isOnline) {
      print('⚠️  Cannot sync: Device is offline');
      return;
    }

    _isSyncing = true;
    notifyListeners();
    print('🔄 Starting sync...');

    try {
      final pendingItems = await _db.syncDao.getPendingSyncItems();
      
      if (pendingItems.isEmpty) {
        print('✅ No pending items to sync');
        return;
      }

      print('📤 Syncing ${pendingItems.length} items...');
      int successCount = 0;
      int failCount = 0;

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
          await _db.syncDao.removeFromSyncQueue(item.id);
          successCount++;
          _pendingOperationsCount--;
          notifyListeners();
        } catch (e) {
          print('❌ Sync failed for ${item.entityType} ${item.entityId}: $e');
          await _db.syncDao.updateSyncError(item.id, e.toString(), item.retryCount);
          failCount++;
        }
      }

      print('✅ Sync complete: $successCount succeeded, $failCount failed');

      // Clean up items with too many failures
      await _db.syncDao.clearFailedSyncItems();
      
      await _updatePendingCount();
      
    } catch (e) {
      print('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Update pending operations count
  Future<void> _updatePendingCount() async {
    final items = await _db.syncDao.getPendingSyncItems();
    _pendingOperationsCount = items.length;
    notifyListeners();
  }

  /// Sync a single item to Firestore
  Future<void> _syncItem(SyncQueueData item) async {
    final dataMap = item.dataJson != null ? _parseJson(item.dataJson!) : null;

    switch (item.entityType) {
      case 'group':
        await _syncGroup(item.entityId, item.operation, dataMap);
        break;
      case 'group_member':
        await _syncGroupMember(item.entityId, item.operation, dataMap);
        break;
      case 'calendar_event':
        await _syncCalendarEvent(item.entityId, item.operation, dataMap);
        break;
      default:
        print('⚠️  Unknown entity type: ${item.entityType}');
    }
  }

  // ==================== SYNC HANDLERS ====================

  Future<void> _syncGroup(String groupId, String operation, Map<String, dynamic>? data) async {
    final groupRef = _firestore.collection('groups').doc(groupId);

    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await groupRef.set(data, SetOptions(merge: true));
          print('✅ Synced group $groupId');
        }
        break;
      case 'delete':
        await groupRef.delete();
        print('✅ Deleted group $groupId');
        break;
    }
  }

  Future<void> _syncGroupMember(String memberId, String operation, Map<String, dynamic>? data) async {
    if (data == null) return;
    
    final groupId = data['groupId'] as String?;
    if (groupId == null) return;

    final memberRef = _firestore
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(memberId);

    switch (operation) {
      case 'create':
      case 'update':
        await memberRef.set(data, SetOptions(merge: true));
        print('✅ Synced member $memberId');
        break;
      case 'delete':
        await memberRef.delete();
        print('✅ Deleted member $memberId');
        break;
    }
  }

  Future<void> _syncCalendarEvent(String eventId, String operation, Map<String, dynamic>? data) async {
    if (data == null) return;
    
    final ownerId = data['ownerId'] as String?;
    if (ownerId == null) return;

    final eventRef = _firestore
        .collection('users')
        .doc(ownerId)
        .collection('calendar_events')
        .doc(eventId);

    switch (operation) {
      case 'create':
      case 'update':
        await eventRef.set(data, SetOptions(merge: true));
        print('✅ Synced event $eventId');
        break;
      case 'delete':
        await eventRef.delete();
        print('✅ Deleted event $eventId');
        break;
    }
  }

  // ==================== HELPERS ====================

  Map<String, dynamic> _parseJson(String jsonStr) {
    // TODO: Implement proper JSON parsing
    // For now, return empty map
    return {};
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final pendingCount = await _db.syncDao.countPendingItems();
    final itemsByType = await _db.syncDao.countItemsByType();
    
    return {
      'pendingCount': pendingCount,
      'itemsByType': itemsByType,
      'isOnline': _connectivity.isOnline,
      'isSyncing': _isSyncing,
    };
  }

  /// Dispose resources
  @override
  void dispose() {
    stopPeriodicSync();
    super.dispose();
  }
}
