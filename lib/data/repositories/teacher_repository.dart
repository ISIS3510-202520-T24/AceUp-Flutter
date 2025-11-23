import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/teachers/teacher_model.dart';
import '../../models/helpers/office_hour_model.dart';
import '../local/database/app_database.dart';
import '../local/database/tables/tables.dart';

class TeacherRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;
  final ConnectivityManager _connectivity;
  final _uuid = const Uuid();

  TeacherRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
    required ConnectivityManager connectivity,
  })  : _db = database,
        _firestore = firestore,
        _connectivity = connectivity;

  // ==================== READ ====================

  /// Get all teachers for user
  Future<List<Teacher>> getTeachersForUser(String userId) async {
    final entities = await _db.teacherDao.getTeachersForUser(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Watch teachers for user
  Stream<List<Teacher>> watchTeachersForUser(String userId) {
    return _db.teacherDao.watchTeachersForUser(userId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  /// Get teacher by ID
  Future<Teacher?> getTeacherById(String id) async {
    final entity = await _db.teacherDao.getTeacherById(id);
    return entity != null ? _entityToModel(entity) : null;
  }

  /// Search teachers
  Future<List<Teacher>> searchTeachers(String userId, String query) async {
    final entities = await _db.teacherDao.searchTeachers(userId, query);
    return entities.map(_entityToModel).toList();
  }

  // ==================== CREATE/UPDATE ====================

  /// Create teacher
  Future<Teacher> createTeacher({
    required String userId,
    required String name,
    String? position,
    String? department,
    String? affiliation,
    String? email,
    String? phone,
    String? webPage,
    List<OfficeHour> officeHours = const [],
  }) async {
    final now = DateTime.now();
    final teacher = Teacher(
      id: _uuid.v4(),
      name: name,
      position: position,
      department: department,
      affiliation: affiliation,
      email: email,
      phone: phone,
      webPage: webPage,
      officeHours: officeHours,
      createdAt: now,
      updatedAt: now,
    );

    // 1. Save locally
    await _db.teacherDao.insertTeacher(_modelToCompanion(teacher, userId));

    // 2. Queue for sync
    await _queueSync(teacher, userId, 'create');

    // 3. Sync if online
    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, teacher);
    }

    return teacher;
  }

  /// Update teacher
  Future<void> updateTeacher(String userId, Teacher teacher) async {
    final updated = teacher.copyWith(updatedAt: DateTime.now());

    await _db.teacherDao.updateTeacher(_modelToCompanion(updated, userId));
    await _queueSync(updated, userId, 'update');

    if (_connectivity.isOnline) {
      await _syncToFirestore(userId, updated);
    }
  }

  /// Delete teacher
  Future<void> deleteTeacher(String userId, String teacherId) async {
    await _db.teacherDao.deleteTeacher(teacherId);

    await _db.syncDao.queueSync(
      entityType: 'teacher',
      entityId: teacherId,
      operation: 'delete',
      dataJson: '{}',
      documentPath: 'users/$userId/teachers/$teacherId',
    );

    if (_connectivity.isOnline) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('teachers')
          .doc(teacherId)
          .delete();
    }
  }

  // ==================== SYNC ====================

  /// Sync all teachers from Firestore
  Future<void> syncFromFirestore(String userId) async {
    if (!_connectivity.isOnline) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('teachers')
          .get();

      final companions = snapshot.docs.map((doc) {
        final teacher = Teacher.fromFirestore(doc);
        return _modelToCompanion(teacher, userId, synced: true);
      }).toList();

      await _db.teacherDao.insertTeachersBatch(companions);
    } catch (e) {
      print('Error syncing teachers from Firestore: $e');
    }
  }

  // ==================== PRIVATE HELPERS ====================

  Teacher _entityToModel(TeacherEntity entity) {
    return Teacher(
      id: entity.id,
      name: entity.name,
      position: entity.position,
      department: entity.department,
      affiliation: entity.affiliation,
      email: entity.email,
      phone: entity.phone,
      webPage: entity.webPage,
      officeHours: OfficeHour.fromJsonString(entity.officeHoursJson),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TeachersCompanion _modelToCompanion(Teacher teacher, String userId, {bool synced = false}) {
    return TeachersCompanion(
      id: Value(teacher.id),
      userId: Value(userId),
      name: Value(teacher.name),
      position: Value(teacher.position),
      department: Value(teacher.department),
      affiliation: Value(teacher.affiliation),
      email: Value(teacher.email),
      phone: Value(teacher.phone),
      webPage: Value(teacher.webPage),
      officeHoursJson: Value(OfficeHour.toJsonString(teacher.officeHours)),
      createdAt: Value(teacher.createdAt),
      updatedAt: Value(teacher.updatedAt),
      syncStatus: Value(synced ? 'synced' : 'pending'),
      lastSyncedAt: synced ? Value(DateTime.now()) : const Value.absent(),
    );
  }

  Future<void> _queueSync(Teacher teacher, String userId, String operation) async {
    await _db.syncDao.queueSync(
      entityType: 'teacher',
      entityId: teacher.id,
      operation: operation,
      dataJson: jsonEncode(teacher.toJson()),
      documentPath: 'users/$userId/teachers/${teacher.id}',
    );
  }

  Future<void> _syncToFirestore(String userId, Teacher teacher) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('teachers')
          .doc(teacher.id)
          .set(teacher.toFirestore(), SetOptions(merge: true));
      await _db.teacherDao.markAsSynced(teacher.id);
    } catch (e) {
      print('Error syncing teacher to Firestore: $e');
    }
  }
}