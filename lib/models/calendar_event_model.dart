// lib/models/calendar_event_model.dart

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
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final EventType type;
  final String ownerId;
  final String ownerName;
  final Color color;
  final String? location;
  final bool isAllDay;
  final DateTime? reminderTime;
  final bool isSynced; // Para eventual connectivity
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.ownerId,
    required this.ownerName,
    required this.color,
    this.location,
    this.isAllDay = false,
    this.reminderTime,
    this.isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Serialización para almacenamiento local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type.index,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'color': color.value,
      'location': location,
      'isAllDay': isAllDay ? 1 : 0,
      'reminderTime': reminderTime?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      type: EventType.values[json['type'] as int],
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      color: Color(json['color'] as int),
      location: json['location'] as String?,
      isAllDay: (json['isAllDay'] as int) == 1,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
      isSynced: (json['isSynced'] as int) == 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    EventType? type,
    String? ownerId,
    String? ownerName,
    Color? color,
    String? location,
    bool? isAllDay,
    DateTime? reminderTime,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      color: color ?? this.color,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      reminderTime: reminderTime ?? this.reminderTime,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CalendarEvent(id: $id, title: $title, startTime: $startTime, endTime: $endTime, type: $type, isSynced: $isSynced)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}