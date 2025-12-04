// lib/data/local/database/tables/calendar_events_table.dart
// Tabla Drift para almacenamiento local de eventos del calendario (BD Relacional)

import 'package:drift/drift.dart';

@DataClassName('CalendarEventEntity')
class CalendarEventsTable extends Table {
  @override
  String get tableName => 'calendar_events';

  // Primary key
  TextColumn get id => text()();

  // Event details
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  
  // Date and time
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  
  // Event type (stored as integer)
  IntColumn get type => integer()();
  
  // Owner information
  TextColumn get ownerId => text()();
  TextColumn get ownerName => text()();
  
  // Visual
  IntColumn get colorValue => integer()();
  
  // Location
  TextColumn get location => text().nullable()();
  
  // Reminder
  DateTimeColumn get reminderTime => dateTime().nullable()();
  
  // Sync status for eventual connectivity
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(false))();
  
  // Metadata
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>>? get uniqueKeys => null;
}
