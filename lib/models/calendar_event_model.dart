// lib/features/groups/models/calendar_event_model.dart

import 'package:flutter/material.dart';

// Un enum para saber de qué tipo es el evento
enum EventType {
  assignment,
  exam,
  classSession,
  group,
  personal,
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final String ownerId;
  final String ownerName;
  final Color color;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.ownerId,
    required this.ownerName,
    required this.color,
  });
}