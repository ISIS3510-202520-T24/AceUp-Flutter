import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tables
import 'tables/tables.dart';

// Import DAOs
import 'dao/user_dao.dart';
import 'dao/term_dao.dart';
import 'dao/subject_dao.dart';
import 'dao/assignment_dao.dart';
import 'dao/class_dao.dart';
import 'dao/exam_dao.dart';
import 'dao/teacher_dao.dart';
import 'dao/holiday_dao.dart';
import 'dao/settings_dao.dart';
import 'dao/group_dao.dart';
import 'dao/sync_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Terms,
    Subjects,
    Assignments,
    ClassTemplates,
    ClassExceptions,
    Exams,
    Teachers,
    Holidays,
    Settings,
    Groups,
    WeeklyAvailabilities,
    SyncQueue,
  ],
  daos: [
    UserDao,
    TermDao,
    SubjectDao,
    AssignmentDao,
    ClassDao,
    ExamDao,
    TeacherDao,
    HolidayDao,
    SettingsDao,
    GroupDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle future migrations here
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  /// Clear all data from the database
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  /// Clear all data for a specific user
  Future<void> clearUserData(String userId) async {
    await transaction(() async {
      // Delete in order to respect foreign key constraints
      await (delete(syncQueue)).go();
      await (delete(weeklyAvailabilities)).go();
      await (delete(groups)..where((t) => t.ownerId.equals(userId))).go();
      await (delete(settings)..where((t) => t.userId.equals(userId))).go();
      await (delete(holidays)..where((t) => t.userId.equals(userId))).go();
      await (delete(teachers)..where((t) => t.userId.equals(userId))).go();
      await (delete(classExceptions)).go();
      await (delete(classTemplates)).go();
      await (delete(exams)).go();
      await (delete(assignments)).go();
      await (delete(subjects)).go();
      await (delete(terms)..where((t) => t.userId.equals(userId))).go();
      await (delete(users)..where((t) => t.uid.equals(userId))).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aceup.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}