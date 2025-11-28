import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'group_dao.g.dart';

@DriftAccessor(tables: [Groups, WeeklyAvailabilities])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(AppDatabase db) : super(db);

  // ==================== GROUPS - READ ====================

  /// Get group by ID
  Future<GroupEntity?> getGroupById(String id) {
    return (select(groups)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Watch group by ID
  Stream<GroupEntity?> watchGroupById(String id) {
    return (select(groups)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// Get all groups for user (where user is owner)
  Future<List<GroupEntity>> getGroupsOwnedByUser(String userId) {
    return (select(groups)
          ..where((t) => t.ownerId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Watch all groups for user (where user is owner)
  Stream<List<GroupEntity>> watchGroupsOwnedByUser(String userId) {
    return (select(groups)
          ..where((t) => t.ownerId.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  /// Get all groups (for user to be filtered by membership in repository)
  Future<List<GroupEntity>> getAllGroups() {
    return (select(groups)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  /// Watch all groups
  Stream<List<GroupEntity>> watchAllGroups() {
    return (select(groups)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  /// Get group by invite code
  Future<GroupEntity?> getGroupByInviteCode(String inviteCode) {
    return (select(groups)..where((t) => t.inviteCode.equals(inviteCode))).getSingleOrNull();
  }

  // ==================== GROUPS - CREATE/UPDATE ====================

  /// Insert or update group
  Future<void> upsertGroup(GroupsCompanion group) {
    return into(groups).insertOnConflictUpdate(group);
  }

  /// Insert group
  Future<void> insertGroup(GroupsCompanion group) {
    return into(groups).insert(group, mode: InsertMode.insertOrReplace);
  }

  /// Update group
  Future<bool> updateGroup(GroupsCompanion group) {
    return (update(groups)..where((t) => t.id.equals(group.id.value)))
        .write(group)
        .then((rows) => rows > 0);
  }

  /// Update group members
  Future<void> updateGroupMembers(String id, String membersJson) {
    return (update(groups)..where((t) => t.id.equals(id))).write(
      GroupsCompanion(
        membersJson: Value(membersJson),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );
  }

  /// Update sync status
  Future<void> updateSyncStatus(String id, String status) {
    return (update(groups)..where((t) => t.id.equals(id))).write(
      GroupsCompanion(
        syncStatus: Value(status),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==================== GROUPS - DELETE ====================

  /// Delete group by ID
  Future<int> deleteGroup(String id) {
    return (delete(groups)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all groups owned by user
  Future<int> deleteGroupsOwnedByUser(String userId) {
    return (delete(groups)..where((t) => t.ownerId.equals(userId))).go();
  }

  // ==================== WEEKLY AVAILABILITY - READ ====================

  /// Get weekly availability by ID
  Future<WeeklyAvailabilityEntity?> getWeeklyAvailabilityById(String id) {
    return (select(weeklyAvailabilities)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Get weekly availability for group and week
  Future<WeeklyAvailabilityEntity?> getWeeklyAvailability(String groupId, String weekIdentifier) {
    return (select(weeklyAvailabilities)
          ..where((t) => t.groupId.equals(groupId) & t.weekIdentifier.equals(weekIdentifier)))
        .getSingleOrNull();
  }

  /// Watch weekly availability for group and week
  Stream<WeeklyAvailabilityEntity?> watchWeeklyAvailability(String groupId, String weekIdentifier) {
    return (select(weeklyAvailabilities)
          ..where((t) => t.groupId.equals(groupId) & t.weekIdentifier.equals(weekIdentifier)))
        .watchSingleOrNull();
  }

  /// Get all weekly availabilities for group
  Future<List<WeeklyAvailabilityEntity>> getWeeklyAvailabilitiesForGroup(String groupId) {
    return (select(weeklyAvailabilities)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.weekStartDate)]))
        .get();
  }

  /// Watch all weekly availabilities for group
  Stream<List<WeeklyAvailabilityEntity>> watchWeeklyAvailabilitiesForGroup(String groupId) {
    return (select(weeklyAvailabilities)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([(t) => OrderingTerm.asc(t.weekStartDate)]))
        .watch();
  }

  // ==================== WEEKLY AVAILABILITY - CREATE/UPDATE ====================

  /// Insert or update weekly availability
  Future<void> upsertWeeklyAvailability(WeeklyAvailabilitiesCompanion availability) {
    return into(weeklyAvailabilities).insertOnConflictUpdate(availability);
  }

  /// Insert weekly availability
  Future<void> insertWeeklyAvailability(WeeklyAvailabilitiesCompanion availability) {
    return into(weeklyAvailabilities).insert(availability, mode: InsertMode.insertOrReplace);
  }

  // ==================== WEEKLY AVAILABILITY - DELETE ====================

  /// Delete weekly availability by ID
  Future<int> deleteWeeklyAvailability(String id) {
    return (delete(weeklyAvailabilities)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all weekly availabilities for group
  Future<int> deleteWeeklyAvailabilitiesForGroup(String groupId) {
    return (delete(weeklyAvailabilities)..where((t) => t.groupId.equals(groupId))).go();
  }

  // ==================== SYNC HELPERS ====================

  /// Get groups that need sync
  Future<List<GroupEntity>> getGroupsNeedingSync() {
    return (select(groups)..where((t) => t.syncStatus.equals('pending'))).get();
  }

  /// Mark group as synced
  Future<void> markGroupAsSynced(String id) {
    return (update(groups)..where((t) => t.id.equals(id))).write(
      GroupsCompanion(
        syncStatus: const Value('synced'),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Insert multiple groups (batch)
  Future<void> insertGroupsBatch(List<GroupsCompanion> groupsList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(groups, groupsList);
    });
  }

  /// Insert multiple weekly availabilities (batch)
  Future<void> insertWeeklyAvailabilitiesBatch(List<WeeklyAvailabilitiesCompanion> availabilitiesList) {
    return batch((b) {
      b.insertAllOnConflictUpdate(weeklyAvailabilities, availabilitiesList);
    });
  }
}