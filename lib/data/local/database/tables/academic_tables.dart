import 'package:drift/drift.dart';

/// Tabla de Assignments (tareas)
class Assignments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // Usuario propietario
  TextColumn get termId => text()(); // Referencia al term
  TextColumn get subjectId => text()(); // Referencia al subject
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get priority => text().withDefault(const Constant('medium'))(); // low, medium, high
  IntColumn get weight => integer().withDefault(const Constant(10))(); // % del grade final
  IntColumn get grade => integer().withDefault(const Constant(0))(); // 0-100
  TextColumn get status => text().withDefault(const Constant('Pending'))(); // Pending, Completed
  BoolColumn get isGraded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Exams (exámenes)
class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // Usuario propietario
  TextColumn get termId => text()(); // Referencia al term
  TextColumn get subjectId => text()(); // Referencia al subject
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get startTime => text().nullable()(); // "HH:mm" format
  TextColumn get endTime => text().nullable()(); // "HH:mm" format
  TextColumn get location => text().nullable()();
  TextColumn get teacherId => text().nullable()(); // Referencia al teacher
  IntColumn get weight => integer().withDefault(const Constant(10))(); // % del grade final
  IntColumn get grade => integer().withDefault(const Constant(0))(); // 0-100
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isGraded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Holidays (días festivos)
class Holidays extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // Usuario propietario
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get source => text().withDefault(const Constant('user'))(); // user, api
  TextColumn get countryCode => text().nullable()(); // Para holidays de API (ej: "US", "CO")
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Teachers (profesores)
class Teachers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()(); // Usuario propietario
  TextColumn get name => text()();
  TextColumn get position => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get affiliation => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get officeLocation => text().nullable()();
  TextColumn get officeHours => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla para cachear la información completa de Subjects (expandida)
/// Esta extiende la tabla básica de Subjects para incluir toda la información académica
class SubjectDetails extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get termId => text()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  TextColumn get color => text().withDefault(const Constant('#4CAF50'))();
  IntColumn get credits => integer().withDefault(const Constant(3))();
  TextColumn get teacherId => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get syllabus => text().nullable()();
  // Grading info
  BoolColumn get useFinalGradeOverride => boolean().withDefault(const Constant(false))();
  RealColumn get finalGrade => real().nullable()();
  TextColumn get weightCategoriesJson => text().nullable()(); // JSON string de categorías con pesos
  // Completeness tracking
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();
  // Sync tracking
  BoolColumn get needsSync => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}