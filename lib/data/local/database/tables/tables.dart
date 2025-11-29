import 'package:drift/drift.dart';

// ============================================
// USER TABLE
// ============================================

@DataClassName('UserEntity')
class Users extends Table {
  TextColumn get uid => text()();
  TextColumn get email => text()();
  TextColumn get nickname => text()();
  TextColumn get avatar => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastLogin => dateTime().nullable()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {uid};
}

// ============================================
// TERM TABLE
// ============================================

@DataClassName('TermEntity')
class Terms extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// SUBJECT TABLE
// ============================================

@DataClassName('SubjectEntity')
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get termId => text()();
  TextColumn get name => text()();
  TextColumn get color => text()();
  IntColumn get credits => integer().withDefault(const Constant(0))();
  RealColumn get finalGrade => real().nullable()();
  BoolColumn get useFinalGradeOverride => boolean().withDefault(const Constant(false))();
  TextColumn get weightsJson => text().withDefault(const Constant('[]'))(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// ASSIGNMENT TABLE
// ============================================

@DataClassName('AssignmentEntity')
class Assignments extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get dueTime => text().nullable()(); // HH:mm format
  TextColumn get weightId => text().nullable()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isGraded => boolean().withDefault(const Constant(false))();
  RealColumn get grade => real().nullable()();
  TextColumn get alertsJson => text().withDefault(const Constant('[]'))(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// CLASS TEMPLATE TABLE
// ============================================

@DataClassName('ClassTemplateEntity')
class ClassTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get startTime => text()(); // HH:mm format
  TextColumn get endTime => text()(); // HH:mm format
  TextColumn get recurrenceJson => text()(); // JSON object
  TextColumn get building => text().nullable()();
  TextColumn get room => text().nullable()();
  TextColumn get teacherId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// CLASS EXCEPTION TABLE
// ============================================

@DataClassName('ClassExceptionEntity')
class ClassExceptions extends Table {
  TextColumn get id => text()();
  TextColumn get classTemplateId => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// EXAM TABLE
// ============================================

@DataClassName('ExamEntity')
class Exams extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get name => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get startTime => text()(); // HH:mm format
  TextColumn get endTime => text()(); // HH:mm format
  TextColumn get weightId => text().nullable()();
  TextColumn get building => text().nullable()();
  TextColumn get room => text().nullable()();
  TextColumn get teacherId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isGraded => boolean().withDefault(const Constant(false))();
  RealColumn get grade => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// TEACHER TABLE
// ============================================

@DataClassName('TeacherEntity')
class Teachers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get position => text().nullable()();
  TextColumn get department => text().nullable()();
  TextColumn get affiliation => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get webPage => text().nullable()();
  TextColumn get officeHoursJson => text().withDefault(const Constant('[]'))(); // JSON array
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// HOLIDAY TABLE
// ============================================

@DataClassName('HolidayEntity')
class Holidays extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get source => text()(); // 'user' or 'api'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// SETTINGS TABLE
// ============================================

@DataClassName('SettingsEntity')
class Settings extends Table {
  TextColumn get userId => text()();
  IntColumn get defaultClassDuration => integer().withDefault(const Constant(60))();
  TextColumn get weekdaysJson => text().withDefault(const Constant('[1,2,3,4,5]'))(); // JSON array
  TextColumn get gradingScaleJson => text()(); // JSON object
  TextColumn get holidayCountry => text().withDefault(const Constant('CO'))();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}

// ============================================
// GROUP TABLE
// ============================================

@DataClassName('GroupEntity')
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get color => text()();
  TextColumn get imageUrl => text().nullable()(); // URL to group image in Firebase Storage
  TextColumn get ownerId => text()();
  TextColumn get membersJson => text().withDefault(const Constant('[]'))(); // JSON array
  TextColumn get inviteCode => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// WEEKLY AVAILABILITY TABLE
// ============================================

@DataClassName('WeeklyAvailabilityEntity')
class WeeklyAvailabilities extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get weekIdentifier => text()(); // YYYY-Wnn format
  DateTimeColumn get weekStartDate => dateTime()();
  DateTimeColumn get weekEndDate => dateTime()();
  TextColumn get dailySlotsJson => text()(); // JSON object
  DateTimeColumn get calculatedAt => dateTime()();
  
  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// EVENT TABLE
// ============================================

@DataClassName('UserEventEntity')
class UserEvents extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get eventUrl => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get userNotes => text().nullable()();
  TextColumn get userLocation => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync metadata
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id, userId};
}

// ============================================
// CACHED EVENT TABLE (for offline viewing)
// ============================================

@DataClassName('CachedEventEntity')
class CachedEvents extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get startDateTime => dateTime()();
  DateTimeColumn get endDateTime => dateTime().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get eventUrl => text().nullable()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================
// SYNC QUEUE TABLE
// ============================================

@DataClassName('SyncQueueEntity')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'term', 'subject', 'assignment', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get dataJson => text()(); // Full entity data as JSON
  TextColumn get documentPath => text()(); // Firestore document path
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
}