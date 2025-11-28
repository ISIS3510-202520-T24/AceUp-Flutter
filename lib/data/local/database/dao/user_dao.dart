import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // ==================== READ ====================

  /// Get user by UID
  Future<UserEntity?> getUserByUid(String uid) {
    return (select(users)..where((t) => t.uid.equals(uid))).getSingleOrNull();
  }

  /// Watch user by UID
  Stream<UserEntity?> watchUserByUid(String uid) {
    return (select(users)..where((t) => t.uid.equals(uid))).watchSingleOrNull();
  }

  /// Get all users
  Future<List<UserEntity>> getAllUsers() {
    return select(users).get();
  }

  /// Watch all users
  Stream<List<UserEntity>> watchAllUsers() {
    return select(users).watch();
  }

  // ==================== CREATE/UPDATE ====================

  /// Insert or update user
  Future<void> upsertUser(UsersCompanion user) {
    return into(users).insertOnConflictUpdate(user);
  }

  /// Insert user
  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user, mode: InsertMode.insertOrReplace);
  }

  /// Update user
  Future<bool> updateUser(UsersCompanion user) {
    return (update(users)..where((t) => t.uid.equals(user.uid.value)))
        .write(user)
        .then((rows) => rows > 0);
  }

  /// Update last login
  Future<void> updateLastLogin(String uid, DateTime lastLogin) {
    return (update(users)..where((t) => t.uid.equals(uid))).write(
      UsersCompanion(
        lastLogin: Value(lastLogin),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String uid, String status) {
    return (update(users)..where((t) => t.uid.equals(uid))).write(
      UsersCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== DELETE ====================

  /// Delete user by UID
  Future<int> deleteUser(String uid) {
    return (delete(users)..where((t) => t.uid.equals(uid))).go();
  }

  /// Delete all users
  Future<int> deleteAllUsers() {
    return delete(users).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get users that need sync
  Future<List<UserEntity>> getUsersNeedingSync() {
    return (select(users)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark user as synced
  Future<void> markAsSynced(String uid) {
    return (update(users)..where((t) => t.uid.equals(uid))).write(
      UsersCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }
}