import 'package:flutter/material.dart';

/// Fuente del evento: manual, importado por IA, etc.
enum ScheduleSource {
  manual,
  aiImport,
  remote,
}

/// Tipo de evento (por ahora usamos CLASS por defecto).
enum ScheduleKind {
  classEvent,
  work,
  other,
}

/// Representa una clase/evento en el horario semanal.
class ScheduleEvent {
  final String id;
  final String title;

  /// 1 = Monday, 2 = Tuesday, ... 7 = Sunday (como DateTime.weekday)
  final int weekday;

  /// Minutos desde medianoche (ej: 8:00am = 8 * 60 = 480).
  final int startMinutes;
  final int endMinutes;

  final String? location;

  /// 🔹 profesor opcional
  final String? professor;

  final ScheduleSource source;
  final ScheduleKind kind;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.weekday,
    required this.startMinutes,
    required this.endMinutes,
    this.location,
    this.professor, // 🔹 nuevo campo en el constructor
    this.source = ScheduleSource.manual,
    this.kind = ScheduleKind.classEvent,
  });

  /// Helper para crear desde horas/minutos legibles.
  factory ScheduleEvent.fromTime({
    required String id,
    required String title,
    required int weekday,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    String? location,
    String? professor, // 🔹 también disponible aquí
    ScheduleSource source = ScheduleSource.manual,
    ScheduleKind kind = ScheduleKind.classEvent,
  }) {
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    return ScheduleEvent(
      id: id,
      title: title,
      weekday: weekday,
      startMinutes: start,
      endMinutes: end,
      location: location,
      professor: professor, // 🔹 se pasa al constructor
      source: source,
      kind: kind,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔹 SERIALIZACIÓN: para que ScheduleRepository pueda usar fromJson / toJson
  // ---------------------------------------------------------------------------

  /// Crear un ScheduleEvent desde un Map (JSON).
  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    // Recuperamos los enums por nombre; si algo falla, dejamos valores por defecto.
    ScheduleSource parseSource(String? value) {
      if (value == null) return ScheduleSource.manual;
      return ScheduleSource.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ScheduleSource.manual,
      );
    }

    ScheduleKind parseKind(String? value) {
      if (value == null) return ScheduleKind.classEvent;
      return ScheduleKind.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ScheduleKind.classEvent,
      );
    }

    return ScheduleEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      weekday: json['weekday'] as int,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      location: json['location'] as String?,
      professor: json['professor'] as String?,
      source: parseSource(json['source'] as String?),
      kind: parseKind(json['kind'] as String?),
    );
  }

  /// Convertir este ScheduleEvent a Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'weekday': weekday,
      'startMinutes': startMinutes,
      'endMinutes': endMinutes,
      'location': location,
      'professor': professor,
      // Guardamos los enums por nombre para que sea legible
      'source': source.name,
      'kind': kind.name,
    };
  }
}
