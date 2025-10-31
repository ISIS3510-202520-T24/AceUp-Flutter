// lib/data/local/database/app_database.dart

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Importar tablas de Shared (solo las que usamos en la app)
import 'tables/shared_tables.dart';

// Importar DAOs de Shared
import 'dao/group_dao.dart';
import 'dao/event_dao.dart';
import 'dao/user_dao.dart';
import 'dao/sync_dao.dart';
import 'dao/settings_dao.dart';
import 'dao/member_schedule_dao.dart'; // Para cachear horarios de miembros

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
    // Tablas adicionales para calcular free blocks (clases de miembros)
    Terms,
    Subjects,
    ClassTemplates,
  ],
  daos: [
    // DAOs para funcionalidad de Shared
    GroupDao,
    EventDao,
    UserDao,
    SyncDao,
    SettingsDao,
    MemberScheduleDao, // Para cachear/recuperar horarios de miembros
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
  
  static AppDatabase get instance => AppDatabase();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Migraciones futuras aquí
      },
    );
  }

  /// Limpiar todos los datos (útil para desarrollo)
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  /// Resetear instancia (útil para testing)
  static void resetInstance() {
    _instance?.close();
    _instance = null;
  }
}

/// Conexión a la base de datos
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aceup_local.db'));
    
    return NativeDatabase.createInBackground(
      file,
      logStatements: true, // Debug: muestra queries en consola
    );
  });
}
