// lib/data/local/database/tables/shared_tables.dart

import 'package:drift/drift.dart';

/// Tabla de Grupos compartidos
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get memberUids => text()(); // CSV: "uid1,uid2,uid3"
  // URL de la imagen del grupo (opcional). Guardamos localmente para mostrarla
  // inmediatamente aunque la sincronización con Firestore esté pendiente.
  TextColumn get imageUrl => text().nullable()();
  TextColumn get createdBy => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Miembros de Grupos (many-to-many)
class GroupMembers extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text()();
  TextColumn get userNick => text()(); // Denormalizado para rapidez
  TextColumn get userEmail => text()(); // Denormalizado
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {groupId, userId}, // Un usuario no puede estar duplicado en un grupo
  ];
}

/// Tabla de Eventos del Calendario (caché)
class CalendarEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  TextColumn get eventType => text()(); // "assignment", "exam", "class", "personal"
  TextColumn get ownerId => text()();
  TextColumn get ownerName => text()();
  IntColumn get colorValue => integer()(); // Color.value
  TextColumn get groupId => text().nullable()(); // Si pertenece a un grupo
  DateTimeColumn get cachedAt => dateTime()(); // Para expiración de caché

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Free Blocks calculados (caché)
class FreeBlocks extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  IntColumn get weekday => integer()(); // 1-7
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get freeMembers => text()(); // CSV: "name1,name2,name3"
  DateTimeColumn get calculatedAt => dateTime()(); // Para expiración

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Usuarios cacheados
class CachedUsers extends Table {
  TextColumn get uid => text()();
  TextColumn get nick => text()();
  TextColumn get email => text()();
  TextColumn get photoUrl => text().nullable()();
  // Local avatar file path (cached on device). Use this to display local image if available.
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

/// Tabla de Metadata de Sincronización
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // "group", "member", etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // "create", "update", "delete"
  TextColumn get dataJson => text().nullable()(); // JSON serializado
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Tabla de Settings/Preferences
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

// ========== TABLAS ADICIONALES PARA CALCULAR FREE BLOCKS ==========
// Estas tablas cachean las clases de los miembros del grupo, necesarias
// para generar eventos recurrentes y calcular disponibilidad offline.

/// Terms (períodos académicos) - cachean los terms de los miembros
class Terms extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // Usuario propietario (miembro del grupo)
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Subjects (materias) - cachean las materias de los miembros
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get termId => text().references(Terms, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text()(); // Usuario propietario
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// ClassTemplates (horarios de clases) - usadas para generar eventos recurrentes
class ClassTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().references(Subjects, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text()(); // Usuario propietario
  IntColumn get dayOfWeek => integer()(); // 1=Monday, 7=Sunday
  TextColumn get startTime => text()(); // "HH:mm" format
  TextColumn get endTime => text()(); // "HH:mm" format
  TextColumn get location => text().nullable()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
