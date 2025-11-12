import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Importar tablas de Shared
import 'tables/shared_tables.dart';
// Importar tablas académicas
import 'tables/academic_tables.dart';

// Importar DAOs de Shared
import 'dao/group_dao.dart';
import 'dao/event_dao.dart';
import 'dao/user_dao.dart';
import 'dao/sync_dao.dart';
import 'dao/settings_dao.dart';
import 'dao/member_schedule_dao.dart';

// Importar DAOs académicos
import 'dao/assignment_dao.dart';
import 'dao/exam_dao.dart';
import 'dao/holiday_dao.dart';
import 'dao/teacher_dao.dart';
import 'dao/academic_dao.dart';

// Esta parte se generará automáticamente
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // Tablas principales de Shared
    Groups,
    GroupMembers,
    CalendarEvents,
    FreeBlocks,
    CachedUsers,
    // Tablas de infraestructura
    SyncQueue,
    AppSettings,
    // Tablas para calcular free blocks (clases de miembros)
    Terms,
    Subjects,
    ClassTemplates,
    // Tablas académicas del usuario
    Assignments,
    Exams,
    Holidays,
    Teachers,
    SubjectDetails,
  ],
  daos: [
    // DAOs para funcionalidad de Shared
    GroupDao,
    EventDao,
    UserDao,
    SyncDao,
    SettingsDao,
    MemberScheduleDao, // Para cachear/recuperar horarios de miembros
    // DAOs para funcionalidad académica
    AssignmentDao,
    ExamDao,
    HolidayDao,
    TeacherDao,
    AcademicDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static AppDatabase? _instance;

  AppDatabase._internal() : super(_openConnection());

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 2; // Incrementar versión por nuevas tablas

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migración de versión 1 a 2: agregar nuevas tablas académicas
          await m.createTable(assignments);
          await m.createTable(exams);
          await m.createTable(holidays);
          await m.createTable(teachers);
          await m.createTable(subjectDetails);
        }
      },
    );
  }

  // Método para limpiar cache antiguo (llamar periódicamente)
  Future<void> cleanOldCache() async {
    const maxAge = Duration(days: 30);

    // Limpiar assignments antiguos
    await assignmentDao.deleteOldCache(maxAge);

    // Limpiar exams antiguos
    await examDao.deleteOldCache(maxAge);

    // Limpiar holidays antiguos
    await holidayDao.deleteOldCache(maxAge);

    // Limpiar teachers antiguos
    await teacherDao.deleteOldCache(maxAge);

    // Limpiar subjects antiguos
    await academicDao.deleteOldSubjectCache(maxAge);

    // Limpiar member schedules antiguos
    await memberScheduleDao.clearOldCache(maxAge);

    print('🧹 Old cache cleaned successfully');
  }

  // Método para sincronizar todos los datos pendientes
  Future<List<Map<String, dynamic>>> getAllPendingSync() async {
    final pendingAssignments = await assignmentDao.getAssignmentsNeedingSync();
    final pendingExams = await examDao.getExamsNeedingSync();
    final pendingHolidays = await holidayDao.getHolidaysNeedingSync();
    final pendingTeachers = await teacherDao.getTeachersNeedingSync();
    final pendingSubjects = await academicDao.getSubjectsNeedingSync();
    final pendingSyncQueue = await syncDao.getAllPendingOperations();

    return [
      ...pendingAssignments.map((a) => {'type': 'assignment', 'data': a}),
      ...pendingExams.map((e) => {'type': 'exam', 'data': e}),
      ...pendingHolidays.map((h) => {'type': 'holiday', 'data': h}),
      ...pendingTeachers.map((t) => {'type': 'teacher', 'data': t}),
      ...pendingSubjects.map((s) => {'type': 'subject', 'data': s}),
      ...pendingSyncQueue.map((sq) => {'type': 'sync_queue', 'data': sq}),
    ];
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aceup.db'));

    print('📂 Database path: ${file.path}');

    return NativeDatabase.createInBackground(file);
  });
}