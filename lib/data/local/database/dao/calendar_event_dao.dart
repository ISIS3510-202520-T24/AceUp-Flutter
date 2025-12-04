// lib/data/local/database/dao/calendar_event_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/calendar_events_table.dart';

part 'calendar_event_dao.g.dart';

@DriftAccessor(tables: [CalendarEventsTable])
class CalendarEventDao extends DatabaseAccessor<AppDatabase>
    with _$CalendarEventDaoMixin {
  CalendarEventDao(AppDatabase db) : super(db);

  Future<List<CalendarEventEntity>> getEventsInRange(
      DateTime start, DateTime end) {
    return (select(calendarEventsTable)
          ..where((t) => t.startTime.isBiggerOrEqualValue(start))
          ..where((t) => t.endTime.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  Future<void> upsert(CalendarEventEntity entity) async {
    await into(calendarEventsTable).insertOnConflictUpdate(entity);
  }

  Future<void> markPendingSync(String id, bool pending) async {
    await (update(calendarEventsTable)
          ..where((t) => t.id.equals(id)))
        .write(CalendarEventsTableCompanion(pendingSync: Value(pending)));
  }

  Future<void> deleteById(String id) async {
    await (delete(calendarEventsTable)..where((t) => t.id.equals(id))).go();
  }
}
