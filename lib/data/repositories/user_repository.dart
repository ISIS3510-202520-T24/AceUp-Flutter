import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../../models/user_model.dart' as model;
import '../local/database/app_database.dart';

/// Repository for user data management with offline-first pattern
class UserRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  UserRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== OFFLINE-FIRST READ ====================

  /// Get user by UID from local database
  Future<model.User?> getUserByUid(String uid) async {
    final entity = await _db.userDao.getUserByUid(uid);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  /// Watch user by UID (stream)
  Stream<model.User?> watchUserByUid(String uid) {
    return _db.userDao.watchUserByUid(uid).map((entity) {
      if (entity == null) return null;
      return _entityToModel(entity);
    });
  }

  /// Get all users from local database
  Future<List<model.User>> getAllUsers() async {
    final entities = await _db.userDao.getAllUsers();
    return entities.map(_entityToModel).toList();
  }

  // ==================== OFFLINE-FIRST WRITE ====================

  /// Create or update user locally and queue for sync
  Future<void> saveUser(model.User user) async {
    final companion = _modelToCompanion(user);

    // Save to local database
    await _db.userDao.upsertUser(companion);

    // Queue for sync to Firebase
    await _queueSync(
      entityId: user.uid,
      operation: 'update',
      data: user.toFirestore(),
      documentPath: 'users/${user.uid}',
    );
  }

  /// Update last login timestamp
  Future<void> updateLastLogin(String uid) async {
    final now = DateTime.now();
    await _db.userDao.updateLastLogin(uid, now);

    // Queue for sync
    await _queueSync(
      entityId: uid,
      operation: 'update',
      data: {'lastLogin': Timestamp.fromDate(now)},
      documentPath: 'users/$uid',
    );
  }

  /// Delete user locally and queue for sync
  Future<void> deleteUser(String uid) async {
    await _db.userDao.deleteUser(uid);

    // Queue for sync
    await _queueSync(
      entityId: uid,
      operation: 'delete',
      data: {},
      documentPath: 'users/$uid',
    );
  }

  // ==================== FIREBASE SYNC ====================

  /// Fetch user from Firebase and store locally
  Future<model.User?> fetchUserFromFirebase(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final user = model.User.fromFirestore(doc);

      // Store locally
      await _db.userDao.upsertUser(_modelToCompanion(user));

      // Mark as synced
      await _db.userDao.updateSyncStatus(uid, 'synced');

      return user;
    } catch (e) {
      print('Error fetching user from Firebase: $e');
      rethrow;
    }
  }

  /// Push local user to Firebase
  Future<void> pushUserToFirebase(String uid) async {
    final entity = await _db.userDao.getUserByUid(uid);
    if (entity == null) return;

    final user = _entityToModel(entity);

    await _firestore
        .collection('users')
        .doc(uid)
        .set(user.toFirestore(), SetOptions(merge: true));

    await _db.userDao.markAsSynced(uid);
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert entity to model
  model.User _entityToModel(UserEntity entity) {
    return model.User(
      uid: entity.uid,
      email: entity.email,
      nickname: entity.nickname,
      avatar: entity.avatar,
      createdAt: entity.createdAt,
      lastLogin: entity.lastLogin,
    );
  }

  /// Convert model to companion for database operations
  UsersCompanion _modelToCompanion(model.User user) {
    return UsersCompanion(
      uid: Value(user.uid),
      email: Value(user.email),
      nickname: Value(user.nickname),
      avatar: Value(user.avatar),
      createdAt: Value(user.createdAt),
      lastLogin: Value(user.lastLogin),
      syncStatus: const Value('pending'),
      lastSyncedAt: Value(DateTime.now()),
    );
  }

  // ==================== SYNC QUEUE HELPERS ====================

  /// Queue sync operation
  Future<void> _queueSync({
    required String entityId,
    required String operation,
    required Map<String, dynamic> data,
    required String documentPath,
  }) async {
    await _db.syncDao.queueSync(
      entityType: 'user',
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
