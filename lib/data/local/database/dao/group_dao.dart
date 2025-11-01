// lib/data/local/database/dao/group_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [Groups, GroupMembers, FreeBlocks])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(AppDatabase db) : super(db);

  // ==================== CRUD DE GRUPOS ====================
  
  /// Obtener todos los grupos de un usuario
  Future<List<Group>> getGroupsForUser(String userId) async {
    final query = select(groups).join([
      innerJoin(
        groupMembers,
        groupMembers.groupId.equalsExp(groups.id),
      ),
    ])..where(groupMembers.userId.equals(userId));

    final results = await query.get();
    
    // Eliminar duplicados (un grupo puede aparecer múltiples veces si tiene varios miembros)
    final uniqueGroups = <String, Group>{};
    for (final row in results) {
      final group = row.readTable(groups);
      uniqueGroups[group.id] = group;
    }
    
    return uniqueGroups.values.toList();
  }
  
  /// Obtener un grupo por ID
  Future<Group?> getGroupById(String groupId) async {
    return (select(groups)..where((g) => g.id.equals(groupId)))
        .getSingleOrNull();
  }
  
  /// Insertar nuevo grupo
  Future<void> insertGroup(GroupsCompanion group) async {
    await into(groups).insert(
      group,
      mode: InsertMode.insertOrReplace,
    );
  }
  
  /// Actualizar grupo
  Future<void> updateGroup(Group group) async {
    await update(groups).replace(group);
  }
  
  /// Eliminar grupo
  Future<void> deleteGroup(String groupId) async {
    await (delete(groups)..where((g) => g.id.equals(groupId))).go();
  }

  /// Obtener todos los grupos (para backup/debug)
  Future<List<Group>> getAllGroups() async {
    return select(groups).get();
  }

  // ==================== MIEMBROS DE GRUPOS ====================
  
  /// Agregar miembro a grupo
  Future<void> addMember(GroupMembersCompanion member) async {
    await into(groupMembers).insert(
      member,
      mode: InsertMode.insertOrReplace,
    );
  }
  
  /// Obtener miembros de un grupo
  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    return (select(groupMembers)..where((m) => m.groupId.equals(groupId)))
        .get();
  }
  
  /// Obtener UIDs de miembros de un grupo
  Future<List<String>> getGroupMemberUids(String groupId) async {
    final members = await getGroupMembers(groupId);
    return members.map((m) => m.userId).toList();
  }
  
  /// Eliminar miembro de grupo
  Future<void> removeMember(String groupId, String userId) async {
    await (delete(groupMembers)
      ..where((m) => 
        m.groupId.equals(groupId) & m.userId.equals(userId)))
      .go();
  }

  /// Eliminar todos los miembros de un grupo
  Future<void> removeAllMembers(String groupId) async {
    await (delete(groupMembers)..where((m) => m.groupId.equals(groupId))).go();
  }

  /// Verificar si un usuario es miembro de un grupo
  Future<bool> isMember(String groupId, String userId) async {
    final count = await (selectOnly(groupMembers)
      ..addColumns([groupMembers.id.count()])
      ..where(groupMembers.groupId.equals(groupId) & 
              groupMembers.userId.equals(userId)))
      .getSingle();
    
    return count.read(groupMembers.id.count())! > 0;
  }

  // ==================== FREE BLOCKS (CACHÉ) ====================
  
  /// Guardar free blocks calculados
  Future<void> cacheFreeBlocks(String groupId, List<FreeBlocksCompanion> blocks) async {
    await transaction(() async {
      // Eliminar bloques viejos del grupo
      await (delete(freeBlocks)..where((fb) => fb.groupId.equals(groupId))).go();
      
      // Insertar nuevos bloques
      await batch((batch) {
        batch.insertAll(freeBlocks, blocks);
      });
    });
  }
  
  /// Obtener free blocks cacheados
  Future<List<FreeBlock>?> getCachedFreeBlocks(String groupId) async {
    final blocks = await (select(freeBlocks)
      ..where((fb) => fb.groupId.equals(groupId))
      ..orderBy([
        (fb) => OrderingTerm.asc(fb.weekday),
        (fb) => OrderingTerm.asc(fb.startHour),
        (fb) => OrderingTerm.asc(fb.startMinute),
      ]))
      .get();
    
    if (blocks.isEmpty) return null;
    
    // Verificar que no estén expirados (30 minutos)
    final firstBlock = blocks.first;
    final age = DateTime.now().difference(firstBlock.calculatedAt);
    if (age.inMinutes > 30) {
      // Expirado, eliminar caché
      await (delete(freeBlocks)..where((fb) => fb.groupId.equals(groupId))).go();
      return null;
    }
    
    return blocks;
  }

  /// Limpiar free blocks expirados (todos los grupos)
  Future<void> clearExpiredFreeBlocks() async {
    final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
    await (delete(freeBlocks)
      ..where((fb) => fb.calculatedAt.isSmallerThanValue(thirtyMinutesAgo)))
      .go();
  }

  // ==================== STREAMS (REACTIVIDAD) ====================
  
  /// Watch grupos de un usuario (se actualiza automáticamente)
  Stream<List<Group>> watchGroupsForUser(String userId) {
    final query = select(groups).join([
      innerJoin(
        groupMembers,
        groupMembers.groupId.equalsExp(groups.id),
      ),
    ])..where(groupMembers.userId.equals(userId));

    return query.watch().map((rows) {
      final uniqueGroups = <String, Group>{};
      for (final row in rows) {
        final group = row.readTable(groups);
        uniqueGroups[group.id] = group;
      }
      return uniqueGroups.values.toList();
    });
  }
  
  /// Watch miembros de un grupo
  Stream<List<GroupMember>> watchGroupMembers(String groupId) {
    return (select(groupMembers)..where((m) => m.groupId.equals(groupId)))
        .watch();
  }

  /// Watch un grupo específico
  Stream<Group?> watchGroup(String groupId) {
    return (select(groups)..where((g) => g.id.equals(groupId)))
        .watchSingleOrNull();
  }

  // ==================== BÚSQUEDA Y FILTROS ====================
  
  /// Buscar grupos por nombre
  Future<List<Group>> searchGroupsByName(String query, String userId) async {
    final lowerQuery = query.toLowerCase();
    
    final results = await (select(groups).join([
      innerJoin(
        groupMembers,
        groupMembers.groupId.equalsExp(groups.id),
      ),
    ])
      ..where(groupMembers.userId.equals(userId) & 
              groups.name.lower().like('%$lowerQuery%')))
      .get();
    
    final uniqueGroups = <String, Group>{};
    for (final row in results) {
      final group = row.readTable(groups);
      uniqueGroups[group.id] = group;
    }
    
    return uniqueGroups.values.toList();
  }

  /// Contar grupos de un usuario
  Future<int> countUserGroups(String userId) async {
    final query = selectOnly(groups).join([
      innerJoin(
        groupMembers,
        groupMembers.groupId.equalsExp(groups.id),
      ),
    ])
      ..addColumns([groups.id.count(distinct: true)])
      ..where(groupMembers.userId.equals(userId));

    final result = await query.getSingle();
    return result.read(groups.id.count())!;
  }

  /// Obtener grupos creados por un usuario
  Future<List<Group>> getGroupsCreatedBy(String userId) async {
    return (select(groups)..where((g) => g.createdBy.equals(userId))).get();
  }
}
