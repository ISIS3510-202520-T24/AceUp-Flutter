import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/database/app_database.dart';
import '../../data/remote/firestore_paths.dart';
import '../../core/connectivity/connectivity_manager.dart';

class SyncService extends ChangeNotifier {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  
  Timer? _periodicSyncTimer;
  bool _isSyncing = false;
  int _pendingOperationsCount = 0;
  StreamSubscription? _connectivitySubscription;

  bool get isSyncing => _isSyncing;
  int get pendingOperationsCount => _pendingOperationsCount;

  SyncService({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  /// Start periodic sync (call this from main.dart)
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    print('🔄 [SyncService] Starting periodic sync service');
    
    // Subscribe to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        print('🌐 [SyncService] Connection restored - triggering sync');
        syncPendingOperations();
      }
    });
    
    // Start periodic timer
    _periodicSyncTimer = Timer.periodic(interval, (_) {
      if (_connectivity.isOnline) {
        syncPendingOperations();
      }
    });
    
    // Initial sync check
    _updatePendingCount();
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    print('🛑 [SyncService] Stopping periodic sync service');
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Process all pending sync operations
  Future<void> syncPendingOperations() async {
    if (_isSyncing) {
      print('⏳ [SyncService] Sync already in progress, skipping');
      return;
    }
    
    if (!_connectivity.isOnline) {
      print('📴 [SyncService] Offline - cannot sync');
      return;
    }
    
    _isSyncing = true;
    notifyListeners();
    
    print('🚀 [SyncService] Starting sync of pending operations');
    final stopwatch = Stopwatch()..start();
    
    try {
      final pendingOps = await _db.syncDao.getPendingOperations();
      print('📋 [SyncService] Found ${pendingOps.length} pending operations');
      
      int successCount = 0;
      int failCount = 0;
      
      for (final op in pendingOps) {
        try {
          await _processSyncOperation(op);
          await _db.syncDao.markOperationComplete(op.id);
          successCount++;
        } catch (e) {
          print('❌ [SyncService] Failed to sync operation ${op.id}: $e');
          await _db.syncDao.incrementRetryCount(op.id);
          failCount++;
        }
      }
      
      stopwatch.stop();
      print('✅ [SyncService] Sync complete: $successCount success, $failCount failed');
      print('⏱️ [SyncService] Total time: ${stopwatch.elapsedMilliseconds}ms');
      
    } catch (e) {
      print('❌ [SyncService] Sync failed: $e');
    } finally {
      _isSyncing = false;
      await _updatePendingCount();
      notifyListeners();
    }
  }

  /// Process a single sync operation
  Future<void> _processSyncOperation(SyncQueueTableData op) async {
    print('🔄 [SyncService] Processing: ${op.operation} ${op.entityType} ${op.entityId}');
    
    final data = op.data != null ? jsonDecode(op.data!) as Map<String, dynamic> : null;
    
    switch (op.entityType) {
      case 'user':
        await _syncUser(op.operation, op.entityId, data);
        break;
      case 'term':
        await _syncTerm(op.operation, op.entityId, data);
        break;
      case 'subject':
        await _syncSubject(op.operation, op.entityId, data);
        break;
      case 'assignment':
        await _syncAssignment(op.operation, op.entityId, data);
        break;
      case 'class_template':
        await _syncClassTemplate(op.operation, op.entityId, data);
        break;
      case 'class_exception':
        await _syncClassException(op.operation, op.entityId, data);
        break;
      case 'exam':
        await _syncExam(op.operation, op.entityId, data);
        break;
      case 'teacher':
        await _syncTeacher(op.operation, op.entityId, data);
        break;
      case 'holiday':
        await _syncHoliday(op.operation, op.entityId, data);
        break;
      case 'settings':
        await _syncSettings(op.operation, op.entityId, data);
        break;
      case 'group':
        await _syncGroup(op.operation, op.entityId, data);
        break;
      case 'group_member':
        await _syncGroupMember(op.operation, op.entityId, data);
        break;
      default:
        print('⚠️ [SyncService] Unknown entity type: ${op.entityType}');
    }
  }

  // ==================== ENTITY SYNC HANDLERS ====================

  Future<void> _syncUser(String operation, String entityId, Map<String, dynamic>? data) async {
    final path = FirestorePaths.user(entityId);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncTerm(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId"
    final parts = entityId.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid term entityId format: $entityId');
    }
    
    final path = FirestorePaths.term(parts[0], parts[1]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncSubject(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId:subjectId"
    final parts = entityId.split(':');
    if (parts.length != 3) {
      throw Exception('Invalid subject entityId format: $entityId');
    }
    
    final path = FirestorePaths.subject(parts[0], parts[1], parts[2]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncAssignment(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId:subjectId:assignmentId"
    final parts = entityId.split(':');
    if (parts.length != 4) {
      throw Exception('Invalid assignment entityId format: $entityId');
    }
    
    final path = FirestorePaths.assignment(parts[0], parts[1], parts[2], parts[3]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncClassTemplate(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId:subjectId:templateId"
    final parts = entityId.split(':');
    if (parts.length != 4) {
      throw Exception('Invalid class template entityId format: $entityId');
    }
    
    final path = FirestorePaths.classTemplate(parts[0], parts[1], parts[2], parts[3]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncClassException(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId:subjectId:exceptionId"
    final parts = entityId.split(':');
    if (parts.length != 4) {
      throw Exception('Invalid class exception entityId format: $entityId');
    }
    
    final path = FirestorePaths.classException(parts[0], parts[1], parts[2], parts[3]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncExam(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:termId:subjectId:examId"
    final parts = entityId.split(':');
    if (parts.length != 4) {
      throw Exception('Invalid exam entityId format: $entityId');
    }
    
    final path = FirestorePaths.exam(parts[0], parts[1], parts[2], parts[3]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncTeacher(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:teacherId"
    final parts = entityId.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid teacher entityId format: $entityId');
    }
    
    final path = FirestorePaths.teacher(parts[0], parts[1]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncHoliday(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "userId:holidayId"
    final parts = entityId.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid holiday entityId format: $entityId');
    }
    
    final path = FirestorePaths.holiday(parts[0], parts[1]);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncSettings(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId is just userId (settings document is always "preferences")
    final path = FirestorePaths.preferences(entityId);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
    }
  }

  Future<void> _syncGroup(String operation, String entityId, Map<String, dynamic>? data) async {
    final path = FirestorePaths.group(entityId);
    
    switch (operation) {
      case 'create':
      case 'update':
        if (data != null) {
          await _firestore.doc(path).set(data, SetOptions(merge: true));
        }
        break;
      case 'delete':
        await _firestore.doc(path).delete();
        break;
    }
  }

  Future<void> _syncGroupMember(String operation, String entityId, Map<String, dynamic>? data) async {
    // entityId format: "groupId:userId"
    final parts = entityId.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid group member entityId format: $entityId');
    }
    
    final groupPath = FirestorePaths.group(parts[0]);
    
    switch (operation) {
      case 'leave':
        // Remove member from group's members array
        final groupDoc = await _firestore.doc(groupPath).get();
        if (groupDoc.exists) {
          final members = List<Map<String, dynamic>>.from(
            groupDoc.data()?['members'] ?? [],
          );
          members.removeWhere((m) => m['userId'] == parts[1]);
          await _firestore.doc(groupPath).update({
            'members': members,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        break;
    }
  }

  // ==================== HELPERS ====================

  Future<void> _updatePendingCount() async {
    final count = await _db.syncDao.getPendingOperationsCount();
    _pendingOperationsCount = count;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPeriodicSync();
    super.dispose();
  }
}