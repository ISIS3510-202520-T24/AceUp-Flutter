import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/user_model.dart';
import '../local/database/app_database.dart';
import '../local/database/tables/tables.dart';

class UserRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;

  UserRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== READ ====================

  /// Get user by UID (offline-first)
  Future<User?> getUserByUid(String uid) async {
    // 1. Try local first
    final local = await _db.userDao.getUserByUid(uid);
    if (local != null) {
      return _entityToModel(local);
    }

    // 2. If online, try remote
    if (_connectivity.isOnline) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          final user = User.fromFirestore(doc);
          await _cacheUser(user);
          return user;
        }
      } catch (e) {
        print('Error fetching user from Firestore: $e');
      }
    }

    return null;
  }

  /// Watch user by UID (reactive stream from local)
  Stream<User?> watchUserByUid(String uid) {
    return _db.userDao.watchUserByUid(uid).map((entity) {
      return entity != null ? _entityToModel(entity) : null;
    });
  }

  // ==================== CREATE/UPDATE ====================

  /// Create new user (requires online)
  Future<void> createUser(User user) async {
    // 1. Save to Firestore first (requires online for registration)
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());

    // 2. Cache locally
    await _cacheUser(user);
  }

  /// Update user (offline-first)
  Future<void> updateUser(User user) async {
    final now = DateTime.now();
    final updatedUser = user.copyWith(lastLogin: now);

    // 1. Update local immediately
    await _db.userDao.upsertUser(UsersCompanion(
      uid: Value(updatedUser.uid),
      email: Value(updatedUser.email),
      nickname: Value(updatedUser.nickname),
      avatar: Value(updatedUser.avatar),
      createdAt: Value(updatedUser.createdAt),
      lastLogin: Value(updatedUser.lastLogin),
      syncStatus: const Value('pending'),
    ));

    // 2. Queue for sync
    await _queueSync(updatedUser, 'update');

    // 3. Try immediate sync if online
    if (_connectivity.isOnline) {
      await _syncUser(updatedUser);
    }
  }

  /// Update last login
  Future<void> updateLastLogin(String uid) async {
    final now = DateTime.now();
    
    // 1. Update local
    await _db.userDao.updateLastLogin(uid, now);

    // 2. Sync to Firestore if online
    if (_connectivity.isOnline) {
      try {
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': Timestamp.fromDate(now),
        });
        await _db.userDao.markAsSynced(uid);
      } catch (e) {
        print('Error syncing last login: $e');
      }
    }
  }

  // ==================== DELETE ====================

  /// Delete user data (local only - Firestore deletion should be handled by Auth)
  Future<void> deleteUserData(String uid) async {
    await _db.clearUserData(uid);
  }

  // ==================== SYNC ====================

  /// Sync user from Firestore to local (for login)
  Future<User?> syncUserFromFirestore(String uid) async {
    if (!_connectivity.isOnline) {
      return getUserByUid(uid);
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = User.fromFirestore(doc);
        await _cacheUser(user, synced: true);
        return user;
      }
    } catch (e) {
      print('Error syncing user from Firestore: $e');
    }

    return null;
  }

  /// Process pending sync for users
  Future<void> processPendingSync() async {
    if (!_connectivity.isOnline) return;

    final pendingUsers = await _db.userDao.getUsersNeedingSync();
    for (final entity in pendingUsers) {
      try {
        final user = _entityToModel(entity);
        await _syncUser(user);
      } catch (e) {
        print('Error syncing user ${entity.uid}: $e');
      }
    }
  }

  // ==================== PRIVATE HELPERS ====================

  User _entityToModel(UserEntity entity) {
    return User(
      uid: entity.uid,
      email: entity.email,
      nickname: entity.nickname,
      avatar: entity.avatar,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
    );
  }

  Future<void> _cacheUser(User user, {bool synced = false}) async {
    await _db.userDao.upsertUser(UsersCompanion(
      uid: Value(user.uid),
      email: Value(user.email),
      nickname: Value(user.nickname),
      avatar: Value(user.avatar),
      createdAt: Value(user.createdAt),
      lastLogin: Value(user.lastLogin),
      syncStatus: Value(synced ? 'synced' : 'pending'),
      lastSyncedAt: synced ? Value(DateTime.now()) : const Value.absent(),
    ));
  }

  Future<void> _syncUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(
            user.toFirestore(),
            SetOptions(merge: true),
          );
      await _db.userDao.markAsSynced(user.uid);
    } catch (e) {
      print('Error syncing user to Firestore: $e');
      rethrow;
    }
  }

  Future<void> _queueSync(User user, String operation) async {
    await _db.syncDao.queueSync(
      entityType: 'user',
      entityId: user.uid,
      operation: operation,
      dataJson: jsonEncode(user.toJson()),
      documentPath: 'users/${user.uid}',
    );
  }
}