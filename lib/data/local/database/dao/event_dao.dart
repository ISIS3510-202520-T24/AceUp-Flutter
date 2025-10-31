// lib/data/local/database/dao/event_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [CalendarEvents])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(AppDatabase db) : super(db);

  // ==================== CRUD DE EVENTOS ====================
  
  /// Insertar evento
  Future<void> insertEvent(CalendarEventsCompanion event) async {
    await into(calendarEvents).insert(
      event,
      mode: InsertMode.insertOrReplace,
    );
  }
  
  /// Obtener evento por ID
  Future<CalendarEvent?> getEventById(String eventId) async {
    return (select(calendarEvents)..where((e) => e.id.equals(eventId)))
        .getSingleOrNull();
  }
  
  /// Obtener eventos de un usuario
  Future<List<CalendarEvent>> getEventsForUser(String userId) async {
    return (select(calendarEvents)..where((e) => e.ownerId.equals(userId)))
        .get();
  }
  
  /// Obtener eventos de un grupo
  Future<List<CalendarEvent>> getEventsForGroup(String groupId) async {
    return (select(calendarEvents)
      ..where((e) => e.groupId.equals(groupId)))
      .get();
  }
  
  /// Obtener eventos en un rango de fechas
  Future<List<CalendarEvent>> getEventsBetween(
    DateTime start,
    DateTime end, {
    String? userId,
  }) async {
    final query = select(calendarEvents)
      ..where((e) => 
        e.startTime.isBiggerOrEqualValue(start) & 
        e.startTime.isSmallerThanValue(end));
    
    if (userId != null) {
      query.where((e) => e.ownerId.equals(userId));
    }
    
    return query.get();
  }
  
  /// Eliminar evento
  Future<void> deleteEvent(String eventId) async {
    await (delete(calendarEvents)..where((e) => e.id.equals(eventId))).go();
  }

  /// Eliminar todos los eventos de un usuario
  Future<void> deleteUserEvents(String userId) async {
    await (delete(calendarEvents)..where((e) => e.ownerId.equals(userId))).go();
  }

  /// Batch insert de eventos
  Future<void> insertEventsBatch(List<CalendarEventsCompanion> events) async {
    await batch((batch) {
      batch.insertAll(
        calendarEvents,
        events,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  // ==================== CACHÉ ====================
  
  /// Cachear eventos de múltiples usuarios (para un grupo)
  Future<void> cacheGroupEvents(
    String groupId,
    List<CalendarEventsCompanion> events,
  ) async {
    await transaction(() async {
      // Eliminar eventos viejos del grupo
      await (delete(calendarEvents)
        ..where((e) => e.groupId.equals(groupId)))
        .go();
      
      // Insertar nuevos eventos
      await batch((batch) {
        batch.insertAll(calendarEvents, events);
      });
    });
  }
  
  /// Limpiar eventos expirados (más de 1 hora)
  Future<void> clearExpiredEvents() async {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    await (delete(calendarEvents)
      ..where((e) => e.cachedAt.isSmallerThanValue(oneHourAgo)))
      .go();
  }

  // ==================== STREAMS ====================
  
  /// Watch eventos de un usuario
  Stream<List<CalendarEvent>> watchUserEvents(String userId) {
    return (select(calendarEvents)..where((e) => e.ownerId.equals(userId)))
        .watch();
  }
  
  /// Watch eventos de un grupo
  Stream<List<CalendarEvent>> watchGroupEvents(String groupId) {
    return (select(calendarEvents)
      ..where((e) => e.groupId.equals(groupId)))
      .watch();
  }

  // ==================== ESTADÍSTICAS ====================
  
  /// Contar eventos de un usuario
  Future<int> countUserEvents(String userId) async {
    final result = await (selectOnly(calendarEvents)
      ..addColumns([calendarEvents.id.count()])
      ..where(calendarEvents.ownerId.equals(userId)))
      .getSingle();
    
    return result.read(calendarEvents.id.count())!;
  }

  /// Obtener eventos agrupados por tipo
  Future<Map<String, int>> getEventCountByType(String userId) async {
    final events = await getEventsForUser(userId);
    final counts = <String, int>{};
    
    for (final event in events) {
      counts[event.eventType] = (counts[event.eventType] ?? 0) + 1;
    }
    
    return counts;
  }
}
