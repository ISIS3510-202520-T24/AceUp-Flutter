// lib/services/shared/sync_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../data/repositories/sync_repository.dart';
import '../../data/local/database/app_database.dart';

/// Service that handles background synchronization of local changes to Firestore
class SyncService extends ChangeNotifier {
  final SyncRepository _syncRepository;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  int _pendingOperationsCount = 0;

  bool get isSyncing => _isSyncing;
  int get pendingOperationsCount => _pendingOperationsCount;

  SyncService({
    required SyncRepository syncRepository,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _syncRepository = syncRepository,
        _firestore = firestore,
        _connectivity = connectivity {
    // Initialize and check for pending operations
    _initializeSync();
    
    // Listen for connectivity changes and sync when coming back online
    _connectivity.onConnectivityChanged.listen((isOnline) {
      print('📡 Connectivity changed: ${isOnline ? "ONLINE" : "OFFLINE"}');
      if (isOnline) {
        // When connection is restored, wait a bit and then sync
        Future.delayed(const Duration(seconds: 2), () {
          if (_connectivity.isOnline && !_isSyncing) {
            _updatePendingCount().then((_) {
              if (_pendingOperationsCount > 0) {
                print('� Connection restored with $_pendingOperationsCount pending items, triggering sync...');
                syncPendingOperations();
              }
            });
          }
        });
      }
    });
  }

  /// Initialize sync service and check for pending operations
  Future<void> _initializeSync() async {
    await _updatePendingCount();
    
    // Check connectivity status
    await _connectivity.checkConnectivity();
    
    // If we have pending items and we're online, sync immediately
    if (_pendingOperationsCount > 0 && _connectivity.isOnline) {
      print('📦 Found $_pendingOperationsCount pending items on startup, syncing in 2 seconds...');
      // Wait a bit for the app to fully initialize
      await Future.delayed(const Duration(seconds: 2));
      if (_connectivity.isOnline && !_isSyncing) {
        syncPendingOperations();
      }
    }
  }

  /// Start periodic sync (every 30 seconds when online)
  void startPeriodicSync({Duration interval = const Duration(seconds: 30)}) {
    _syncTimer?.cancel();
    
    _syncTimer = Timer.periodic(interval, (_) async {
      // Re-check connectivity status manually before each sync attempt
      await _connectivity.checkConnectivity();
      
      if (_connectivity.isOnline && !_isSyncing && _pendingOperationsCount > 0) {
        print('⏰ Periodic sync triggered (${_pendingOperationsCount} pending)');
        syncPendingOperations();
      }
    });
    
    // Trigger immediate sync if online and have pending items
    if (_connectivity.isOnline && !_isSyncing && _pendingOperationsCount > 0) {
      print('🚀 Starting immediate sync on service start');
      syncPendingOperations();
    }
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manually trigger sync of pending operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      print('⚠️  Sync already in progress, skipping...');
      return;
    }
    
    if (!_connectivity.isOnline) {
      print('⚠️  Cannot sync: Device is offline');
      return;
    }

    _isSyncing = true;
    notifyListeners();
    print('🔄 ========== STARTING SYNC ==========');
    print('🔄 Online: ${_connectivity.isOnline}');

    try {
      final pendingItems = await _syncRepository.getPendingSyncItems();

      if (pendingItems.isEmpty) {
        print('✅ No pending items to sync');
        return;
      }

      print('📤 Syncing ${pendingItems.length} pending items...');
      for (var i = 0; i < pendingItems.length; i++) {
        final item = pendingItems[i];
        print('📤 [$i/${pendingItems.length}] ${item.operation} ${item.entityType} (${item.entityId})');
      }

      int successCount = 0;
      int failCount = 0;

      for (final item in pendingItems) {
        try {
          print('🔄 Syncing ${item.operation} ${item.entityType} ${item.entityId}...');
          await _syncItem(item);
          await _syncRepository.deleteSyncItem(item.id);
          successCount++;
          _pendingOperationsCount--;
          print('✅ Synced ${item.operation} ${item.entityType} ${item.entityId}');
          notifyListeners();
        } catch (e) {
          print('❌ Sync failed for ${item.entityType} ${item.entityId}: $e');
          await _syncRepository.incrementRetryCount(item.id, e.toString());
          failCount++;
        }
      }

      print('✅ ========== SYNC COMPLETE ==========');
      print('✅ Success: $successCount | Failed: $failCount');

      // Clean up items with too many failures (max 3 retries)
      await _syncRepository.deleteFailedItems(maxRetries: 3);
      
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
    final items = await _syncRepository.getPendingSyncItems();
    _pendingOperationsCount = items.length;
    print('📊 [SYNC] Pending operations count: $_pendingOperationsCount');
    if (_pendingOperationsCount > 0) {
      for (final item in items) {
        print('   - ${item.entityType} ${item.entityId} (${item.operation})');
      }
    }
    notifyListeners();
  }

  /// Sync a single item to Firestore
  Future<void> _syncItem(SyncQueueEntity item) async {
    final dataMap = _parseJson(item.dataJson);

    switch (item.entityType) {
      // Academic entities
      case 'term':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'subject':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'assignment':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'exam':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'class_template':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'class_exception':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;

      // User entities
      case 'user':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;
      case 'settings':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;

      // Teacher entities
      case 'teacher':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;

      // Holiday entities
      case 'holiday':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;

      // Group entities (existing)
      case 'group':
        await _syncGroup(item.entityId, item.operation, dataMap);
        break;
      case 'group_member':
        await _syncGroupMember(item.entityId, item.operation, dataMap);
        break;
      case 'weekly_availability':
        await _syncByPath(item.documentPath, item.operation, dataMap);
        break;

      // Calendar events (existing)
      case 'calendar_event':
        await _syncCalendarEvent(item.entityId, item.operation, dataMap);
        break;

      default:
        print('⚠️  Unknown entity type: ${item.entityType}');
    }
  }

  // ==================== SYNC HANDLERS ====================

  /// Generic sync handler that uses document path
  Future<void> _syncByPath(String documentPath, String operation, Map<String, dynamic> data) async {
    // Parse document path to get collection and document references
    final pathParts = documentPath.split('/');

    DocumentReference ref = _firestore.doc(documentPath);

    switch (operation) {
      case 'create':
      case 'update':
        if (data.isNotEmpty) {
          await ref.set(data, SetOptions(merge: true));
          print('✅ Synced $documentPath');
        }
        break;
      case 'delete':
        await ref.delete();
        print('✅ Deleted $documentPath');
        break;
    }
  }

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
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        print('📋 [PARSE] Parsed JSON: $decoded');
        return decoded;
      } else {
        print('⚠️  [PARSE] Decoded JSON is not a Map: $decoded');
        return {};
      }
    } catch (e) {
      print('❌ [PARSE] Error parsing JSON: $e');
      print('   Raw JSON: $jsonStr');
      return {};
    }
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStats() async {
    final pendingCount = await _syncRepository.getPendingSyncCount();

    return {
      'pendingCount': pendingCount,
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
