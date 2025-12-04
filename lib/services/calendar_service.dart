// lib/services/calendar_service.dart
// Calendar service combining local DB (Drift), caching (LRU), and async fetch.

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../data/local/database/app_database.dart';
import '../data/local/database/dao/calendar_event_dao.dart';
import '../data/local/database/tables/calendar_events_table.dart';
import '../models/calendar_event_model.dart';
import 'cache/lru_cache.dart';

class CalendarService {
  final AppDatabase db;
  final CalendarEventDao dao;
  final LruCache<List<CalendarEvent>> _cache = LruCache(capacity: 200);

  CalendarService(this.db) : dao = CalendarEventDao(db);

  String _dayKey(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

  Future<List<CalendarEvent>> getEventsForDay(DateTime day) async {
    final key = _dayKey(day);
    final cached = _cache.get(key);
    if (cached != null) return cached;

    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    final rows = await dao.getEventsInRange(start, end);
    final List<CalendarEvent> events = rows.map<CalendarEvent>(_fromEntity).toList();
    _cache.set(key, events);
    return events;
  }

  Future<void> addOrUpdate(CalendarEvent event) async {
    final entity = _toEntity(event);
    await dao.upsert(entity);
    // invalidate cache for that day
    _cache.set(_dayKey(event.startTime), await getEventsForDay(event.startTime));
  }

  Future<void> remove(String id) async {
    await dao.deleteById(id);
    _cache.clear();
  }

  // Example async work off main thread would use isolates; here we simulate with Future.
  Future<List<CalendarEvent>> refreshRange(DateTime start, DateTime end) async {
    final rows = await dao.getEventsInRange(start, end);
    final List<CalendarEvent> events = rows.map<CalendarEvent>(_fromEntity).toList();
    // seed cache per day
    for (final e in events) {
      _cache.set(_dayKey(e.startTime),
          (await getEventsForDay(e.startTime))..add(e));
    }
    return events;
  }

  CalendarEventEntity _toEntity(CalendarEvent e) => CalendarEventEntity(
        id: e.id,
        title: e.title,
        description: e.description,
        startTime: e.startTime,
        endTime: e.endTime,
        isAllDay: e.isAllDay,
        type: e.type.index,
        ownerId: e.ownerId,
        ownerName: e.ownerName,
        colorValue: e.color.value,
        location: e.location,
        reminderTime: e.reminderTime,
        isSynced: e.isSynced,
        pendingSync: !e.isSynced,
        createdAt: e.createdAt,
        updatedAt: DateTime.now(),
      );

  CalendarEvent _fromEntity(CalendarEventEntity r) => CalendarEvent(
        id: r.id,
        title: r.title,
        description: r.description,
        startTime: r.startTime,
        endTime: r.endTime,
        isAllDay: r.isAllDay,
        type: EventType.values[r.type],
        ownerId: r.ownerId,
        ownerName: r.ownerName,
        color: Color(r.colorValue),
        location: r.location,
        reminderTime: r.reminderTime,
        isSynced: r.isSynced,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
}
