import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_event.dart';

class ScheduleRepository extends ChangeNotifier {
  ScheduleRepository();

  /// Lista en memoria (caché) de los eventos del horario.
  final List<ScheduleEvent> _events = [];

  /// Clave para guardar en SharedPreferences.
  static const String _storageKey = 'schedule_events_v1';

  /// Vista inmodificable de los eventos (para la UI).
  UnmodifiableListView<ScheduleEvent> get events =>
      UnmodifiableListView(_events);

  /// --- LOCAL STORAGE / MULTI-THREADING ---

  /// Cargar el horario desde almacenamiento local.
  ///
  /// Se llama una vez cuando se inicializa el repositorio.
  Future<void> loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) {
        if (kDebugMode) {
          debugPrint('📂 ScheduleRepository: no local data yet');
        }
        return;
      }

      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;

      // 🔹 OJO: aquí asumimos que más adelante implementas fromJson/toJson
      // en ScheduleEvent. Si aún no lo tienes, quita este bloque de load
      // y el _saveToLocal() para que no truene.
      final loaded = list
          .map((e) => ScheduleEvent.fromJson(e as Map<String, dynamic>))
          .toList();

      _events
        ..clear()
        ..addAll(loaded);

      if (kDebugMode) {
        debugPrint(
          '📂 ScheduleRepository: loaded ${_events.length} events from local',
        );
      }
      notifyListeners();
    } catch (e, st) {
      debugPrint('❌ Error loading schedule from local: $e\n$st');
    }
  }

  /// Guardar la lista actual en almacenamiento local.
  ///
  /// Es async/await ⇒ cumple parte de multi-threading.
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _events.map((e) => e.toJson()).toList();
      final raw = jsonEncode(list);
      await prefs.setString(_storageKey, raw);

      if (kDebugMode) {
        debugPrint(
          '💾 ScheduleRepository: saved ${_events.length} events to local',
        );
      }
    } catch (e, st) {
      debugPrint('❌ Error saving schedule to local: $e\n$st');
    }
  }

  /// --- DETECCIÓN DE CONFLICTOS ---

  /// Devuelve las clases existentes que se solapan con las nuevas.
  List<ScheduleEvent> findConflicts(List<ScheduleEvent> newEvents) {
    final conflicts = <ScheduleEvent>[];

    for (final newEvent in newEvents) {
      for (final existing in _events) {
        if (existing.weekday != newEvent.weekday) continue;

        // No hay solapamiento si una termina antes de que la otra empiece
        final noOverlap = newEvent.endMinutes <= existing.startMinutes ||
            newEvent.startMinutes >= existing.endMinutes;

        if (!noOverlap) {
          conflicts.add(existing);
        }
      }
    }

    // Quitar duplicados por id
    final seen = <String>{};
    return conflicts.where((e) {
      if (seen.contains(e.id)) return false;
      seen.add(e.id);
      return true;
    }).toList();
  }

  /// Elimina todas las clases que se solapan con las nuevas y añade las nuevas.
  void replaceConflictingEvents(List<ScheduleEvent> newEvents) {
    for (final newEvent in newEvents) {
      _events.removeWhere((existing) {
        if (existing.weekday != newEvent.weekday) return false;

        final noOverlap = newEvent.endMinutes <= existing.startMinutes ||
            newEvent.startMinutes >= existing.endMinutes;

        return !noOverlap; // true => se borra porque se solapa
      });

      _events.add(newEvent);
    }

    notifyListeners();
    _saveToLocal();
  }

  /// --- OPERACIONES PÚBLICAS ---

  /// Añadir varios eventos (ej: desde el editor manual).
  void addEvents(List<ScheduleEvent> newEvents) {
    _events.addAll(newEvents);
    notifyListeners();
    // Guardado asíncrono en segundo plano.
    _saveToLocal();
  }

  /// Insertar o actualizar un evento individual.
  void upsertEvent(ScheduleEvent event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index == -1) {
      _events.add(event);
    } else {
      _events[index] = event;
    }
    notifyListeners();
    _saveToLocal();
  }

  /// Borrar por id (una sola clase).
  void removeEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveToLocal();
  }

  /// Borrar todas las instancias de una misma clase por título.
  ///
  /// Útil cuando borras “CONSTR. APLIC. MÓVILES (INGLÉS)” completa.
  void deleteEventsByTitle(String title) {
    final normalized = title.toLowerCase().trim();
    _events.removeWhere(
      (e) => e.title.toLowerCase().trim() == normalized,
    );
    notifyListeners();
    _saveToLocal();
  }

  /// Limpiar todo el horario.
  void clear() {
    _events.clear();
    notifyListeners();
    _saveToLocal();
  }
}
