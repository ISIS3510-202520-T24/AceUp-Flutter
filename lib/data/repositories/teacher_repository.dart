import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart'; // ignore: uri_does_not_exist
import '../../models/teachers/teacher_model.dart' as model;
import '../../models/helpers/office_hour_model.dart';
import '../local/database/app_database.dart';

/// Repository for teacher data management with offline-first pattern
class TeacherRepository {
  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  TeacherRepository({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  })  : _db = database,
        _firestore = firestore;

  // ==================== OFFLINE-FIRST READ ====================

  /// Get all teachers for user from local database
  Future<List<model.Teacher>> getTeachersForUser(String userId) async {
    final entities = await _db.teacherDao.getTeachersForUser(userId);
    return entities.map(_entityToModel).toList();
  }

  /// Watch teachers for user (stream)
  Stream<List<model.Teacher>> watchTeachersForUser(String userId) {
    return _db.teacherDao.watchTeachersForUser(userId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  /// Get teacher by ID
  Future<model.Teacher?> getTeacherById(String teacherId) async {
    final entity = await _db.teacherDao.getTeacherById(teacherId);
    if (entity == null) return null;
    return _entityToModel(entity);
  }

  /// Watch teacher by ID (stream)
  Stream<model.Teacher?> watchTeacherById(String teacherId) {
    return _db.teacherDao.watchTeacherById(teacherId).map((entity) {
      if (entity == null) return null;
      return _entityToModel(entity);
    });
  }

  // ==================== OFFLINE-FIRST WRITE ====================

  /// Save teacher locally and queue for sync
  Future<void> saveTeacher(model.Teacher teacher, String userId) async {
    final companion = _modelToCompanion(teacher, userId);

    await _db.teacherDao.upsertTeacher(companion);

    await _queueSync(
      entityId: teacher.id,
      operation: 'update',
      data: teacher.toJson(),
      documentPath: 'users/$userId/teachers/${teacher.id}',
    );
  }

  /// Delete teacher
  Future<void> deleteTeacher(String teacherId, String userId) async {
    await _db.teacherDao.deleteTeacher(teacherId);

    await _queueSync(
      entityId: teacherId,
      operation: 'delete',
      data: {},
      documentPath: 'users/$userId/teachers/$teacherId',
    );
  }

  // ==================== FIREBASE SYNC ====================

  /// Fetch all teachers from Firebase for user
  Future<List<model.Teacher>> fetchTeachersFromFirebase(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('teachers')
          .get();

      final teachers = snapshot.docs.map((doc) => model.Teacher.fromFirestore(doc)).toList();

      // Store locally
      for (final teacher in teachers) {
        final companion = _modelToCompanion(teacher, userId);
        await _db.teacherDao.upsertTeacher(companion);
        await _db.teacherDao.markAsSynced(teacher.id);
      }

      return teachers;
    } catch (e) {
      print('Error fetching teachers from Firebase: $e');
      rethrow;
    }
  }

  // ==================== CONVERSION HELPERS ====================

  /// Convert entity to model
  model.Teacher _entityToModel(TeacherEntity entity) {
    final officeHours = OfficeHour.fromJsonString(entity.officeHoursJson);

    return model.Teacher(
      id: entity.id,
      name: entity.name,
      position: entity.position,
      department: entity.department,
      affiliation: entity.affiliation,
      email: entity.email,
      phone: entity.phone,
      webPage: entity.webPage,
      officeHours: officeHours,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to companion
  TeachersCompanion _modelToCompanion(model.Teacher teacher, String userId) {
    return TeachersCompanion(
      id: Value(teacher.id), //ignore: undefined_method
      userId: Value(userId), //ignore: undefined_method
      name: Value(teacher.name), //ignore: undefined_method
      position: Value(teacher.position), //ignore: undefined_method
      department: Value(teacher.department), //ignore: undefined_method
      affiliation: Value(teacher.affiliation), //ignore: undefined_method
      email: Value(teacher.email), //ignore: undefined_method
      phone: Value(teacher.phone), //ignore: undefined_method
      webPage: Value(teacher.webPage), //ignore: undefined_method
      officeHoursJson: Value(OfficeHour.toJsonString(teacher.officeHours)), //ignore: undefined_method
      createdAt: Value(teacher.createdAt), //ignore: undefined_method
      updatedAt: Value(teacher.updatedAt), //ignore: undefined_method
      syncStatus: const Value('pending'), //ignore: creation_with_non_type
      lastSyncedAt: Value(DateTime.now()), //ignore: undefined_method
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
      entityType: 'teacher',
      entityId: entityId,
      operation: operation,
      dataJson: jsonEncode(data),
      documentPath: documentPath,
    );
  }
}
