// lib/data/local/database/dao/user_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [CachedUsers])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // ==================== CRUD DE USUARIOS ====================
  
  /// Cachear usuario
  Future<void> cacheUser(CachedUsersCompanion user) async {
    await into(cachedUsers).insert(
      user,
      mode: InsertMode.insertOrReplace,
    );
  }
  
  /// Obtener usuario cacheado
  Future<CachedUser?> getCachedUser(String uid) async {
    final user = await (select(cachedUsers)..where((u) => u.uid.equals(uid)))
        .getSingleOrNull();
    
    if (user == null) return null;
    
    // Verificar que no esté expirado (1 hora)
    final age = DateTime.now().difference(user.cachedAt);
    if (age.inHours > 1) {
      await deleteUser(uid);
      return null;
    }
    
    return user;
  }
  
  /// Obtener múltiples usuarios cacheados
  Future<List<CachedUser>> getCachedUsers(List<String> uids) async {
    return (select(cachedUsers)..where((u) => u.uid.isIn(uids))).get();
  }
  
  /// Eliminar usuario del caché
  Future<void> deleteUser(String uid) async {
    await (delete(cachedUsers)..where((u) => u.uid.equals(uid))).go();
  }

  /// Batch cachear usuarios
  Future<void> cacheUsersBatch(List<CachedUsersCompanion> users) async {
    await batch((batch) {
      batch.insertAll(
        cachedUsers,
        users,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== AVATAR (RUTA LOCAL) ====================

  /// Guardar ruta local del avatar para un usuario
  Future<void> setAvatarPath(String uid, String path) async {
    await into(cachedUsers).insert(
      CachedUsersCompanion(
        uid: Value(uid),
        avatarPath: Value(path),
        cachedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Obtener ruta local del avatar si existe
  Future<String?> getAvatarPath(String uid) async {
    final user = await (select(cachedUsers)..where((u) => u.uid.equals(uid))).getSingleOrNull();
    return user?.avatarPath;
  }

  // ==================== CACHÉ ====================
  
  /// Limpiar usuarios expirados
  Future<void> clearExpiredUsers() async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    await (delete(cachedUsers)
      ..where((u) => u.cachedAt.isSmallerThanValue(oneHourAgo)))
      .go();
  }

  /// Limpiar todo el caché de usuarios
  Future<void> clearAllUsers() async {
    await delete(cachedUsers).go();
  }

  // ==================== BÚSQUEDA ====================
  
  /// Buscar usuarios por nick o email
  Future<List<CachedUser>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase();
    return (select(cachedUsers)
      ..where((u) => 
        u.nick.lower().like('%$lowerQuery%') |
        u.email.lower().like('%$lowerQuery%')))
      .get();
  }

  /// Obtener todos los usuarios cacheados
  Future<List<CachedUser>> getAllCachedUsers() async {
    return select(cachedUsers).get();
  }

  // ==================== STREAMS ====================
  
  /// Watch usuario
  Stream<CachedUser?> watchUser(String uid) {
    return (select(cachedUsers)..where((u) => u.uid.equals(uid)))
        .watchSingleOrNull();
  }
}
