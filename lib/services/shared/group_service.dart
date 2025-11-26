// lib/features/groups/services/group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/shared/group_model.dart';
import '../../models/user_model.dart';
import '../../models/calendar_event_model.dart';
import '../../models/free_block_model.dart';


class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// Calcula los bloques de tiempo libres para todos los miembros de un grupo.
  /// [memberEvents] es un mapa de nombre de miembro a su lista de eventos.
  /// [intervalMinutes] es la duración de cada bloque (ej: 30).
  /// [weekdays] es la lista de días a mostrar (1=Monday, 7=Sunday).
  static Future<List<FreeBlock>> calculateGroupFreeBlocks({
    required Map<String, List<CalendarEvent>> memberEvents,
    int intervalMinutes = 30,
    List<int> weekdays = const [1,2,3,4,5], // Lunes a Viernes
    int startHour = 8,
    int endHour = 17,
  }) async {
    List<FreeBlock> result = [];
    for (int weekday in weekdays) {
      for (int hour = startHour; hour < endHour; hour++) {
        for (int min = 0; min < 60; min += intervalMinutes) {
          final blockStart = TimeOfDay(hour: hour, minute: min);
          final blockEnd = TimeOfDay(hour: hour, minute: min + intervalMinutes > 59 ? 59 : min + intervalMinutes);
          List<String> freeMembers = [];
          memberEvents.forEach((member, events) {
            // Buscar si el miembro tiene algún evento que se cruce con este bloque
            final isBusy = events.any((e) {
              if (e.startTime.weekday != weekday) return false;
              final eventStart = TimeOfDay(hour: e.startTime.hour, minute: e.startTime.minute);
              final eventEnd = TimeOfDay(hour: e.endTime.hour, minute: e.endTime.minute);
              return _overlaps(blockStart, blockEnd, eventStart, eventEnd);
            });
            if (!isBusy) freeMembers.add(member);
          });
          result.add(FreeBlock(
            weekday: weekday,
            start: blockStart,
            end: blockEnd,
            freeMembers: freeMembers,
          ));
        }
      }
    }
    return result;
  }

  // --- MÉTODOS DE USUARIO ---

  Future<List<User>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  /// Versión optimizada para grupos: solo carga clases (sin personal/assignments/exams)
  /// No requiere color porque la vista de grupos no muestra colores por usuario
  Future<List<CalendarEvent>> getClassEventsOnlyForUser(User user) async {
    List<CalendarEvent> allEvents = [];
    final userId = user.uid;

    try {
      
      // Cargar SOLO clases (sin personal, assignments ni exams)
      final termsSnap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('terms')
          .get();
      

      for (var termDoc in termsSnap.docs) {
        
        final subjectsSnap = await termDoc.reference.collection('subjects').get();
        
        for (var subjectDoc in subjectsSnap.docs) {
          final subjectData = subjectDoc.data();
          final subjectName = subjectData['name'] ?? 'Unknown Subject';
          
          // SOLO cargar clases
          final classesSnap = await subjectDoc.reference.collection('classes').get();
          
          for (var classDoc in classesSnap.docs) {
            final data = classDoc.data();
            
            // Verificar que tenemos los datos necesarios
            if (data['dayOfWeek'] != null && data['startTime'] != null && data['endTime'] != null) {
              final int dayOfWeek = data['dayOfWeek']; // 1 para Lunes, 7 para Domingo
              final String startTimeStr = data['startTime']; // ej. "08:00"
              final String endTimeStr = data['endTime'];   // ej. "09:20"
                            
              // Generar eventos recurrentes para las clases
              // Color verde por defecto para clases (no se usa en vista de grupos)
              final classEvents = _generateRecurringClassEvents(
                subjectName: subjectName,
                dayOfWeek: dayOfWeek,
                startTimeStr: startTimeStr,
                endTimeStr: endTimeStr,
                classId: classDoc.id,
                userId: userId,
                userName: user.nickname,
                color: Colors.green,
              );
              
              allEvents.addAll(classEvents);
            }
          }
        }
      }
      return allEvents;
      
    } catch (e) {
      return [];
    }
  }

  Future<List<CalendarEvent>> getCalendarEventsForUser(User user, Color color) async {
    List<CalendarEvent> allEvents = [];
    final userId = user.uid;

      // Función de ayuda para una conversión segura de Timestamp
    DateTime _safeTimestampToDate(dynamic timestamp) {
      return (timestamp as Timestamp? ?? Timestamp.now()).toDate();
    }

    try {
    // 1. Cargar eventos personales de users/{userId}/events
    final personalEventsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();
    
    
    allEvents.addAll(personalEventsSnap.docs.map((doc) {
      final data = doc.data();
      return CalendarEvent(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        startTime: _safeTimestampToDate(data['startTime']),
        endTime: _safeTimestampToDate(data['endTime']),
        type: EventType.personal,
        ownerId: userId,
        ownerName: user.nickname,
        color: color,
      );
    }));

    // 2. Cargar eventos académicos de users/{userId}/terms/{termId}/subjects/{subjectId}/...
    final termsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('terms')
        .get();
    

    for (var termDoc in termsSnap.docs) {
      
      final subjectsSnap = await termDoc.reference.collection('subjects').get();
      
      for (var subjectDoc in subjectsSnap.docs) {
        final subjectData = subjectDoc.data();
        final subjectName = subjectData['name'] ?? 'Unknown Subject';
        
        // 2.1 Cargar exámenes
        final examsSnap = await subjectDoc.reference.collection('exams').get();

        allEvents.addAll(examsSnap.docs.map((doc) {
          final data = doc.data();
          return CalendarEvent(
            id: doc.id,
            title: "Exam: ${data['title'] ?? 'Untitled'} ($subjectName)",
            startTime: _safeTimestampToDate(data['startTime']),
            endTime: _safeTimestampToDate(data['endTime']),
            type: EventType.exam,
            ownerId: userId,
            ownerName: user.nickname,
            color: color,
          );
        }));
        
        // 2.2 Cargar assignments (tareas)
        final assignmentsSnap = await subjectDoc.reference.collection('assignments').get();        
        allEvents.addAll(assignmentsSnap.docs.map((doc) {
          final data = doc.data();
          final dueDate = _safeTimestampToDate(data['dueDate']);
          return CalendarEvent(
            id: doc.id,
            title: "Assignment: ${data['title'] ?? 'Untitled'} ($subjectName)",
            startTime: dueDate,
            endTime: dueDate.add(const Duration(hours: 1)), // Duración de 1 hora para assignments
            type: EventType.assignment,
            ownerId: userId,
            ownerName: user.nickname,
            color: color,
          );
        }));

        // 2.3 Cargar clases
        final classesSnap = await subjectDoc.reference.collection('classes').get();        
        for (var classDoc in classesSnap.docs) {
          final data = classDoc.data();
          
          // Verificar que tenemos los datos necesarios
          if (data['dayOfWeek'] != null && data['startTime'] != null && data['endTime'] != null) {
            final int dayOfWeek = data['dayOfWeek']; // 1 para Lunes, 7 para Domingo
            final String startTimeStr = data['startTime']; // ej. "08:00"
            final String endTimeStr = data['endTime'];   // ej. "09:20"
                        
            // Generar eventos recurrentes para las clases
            final classEvents = _generateRecurringClassEvents(
              subjectName: subjectName,
              dayOfWeek: dayOfWeek,
              startTimeStr: startTimeStr,
              endTimeStr: endTimeStr,
              classId: classDoc.id,
              userId: userId,
              userName: user.nickname,
              color: color,
            );
            
            allEvents.addAll(classEvents);
          }
        }
      }
    }

    return allEvents;
    
  } catch (e) {
    return [];
  }



  }

    Future<List<Group>> getGroupsForUser(String userId) async {
    // Usamos 'array-contains' para encontrar todos los documentos de 'groups'
    // donde el array 'members' contenga el UID del usuario actual.
    QuerySnapshot snapshot = await _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();
        
    return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
    }

  // --- MÉTODOS DE GRUPO ---

  Future<List<Group>> getGroups() async {
    QuerySnapshot snapshot = await _firestore.collection('groups').get();
    return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
  }

  Future<void> addGroup(String name, List<String> memberEmails) async {
    // 1. Convertir la lista de emails a una lista de UIDs
    List<String> memberUids = [];
    for (String email in memberEmails) {
      // Hacemos una consulta para encontrar al usuario con ese email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        // Si encontramos al usuario, añadimos su UID a la lista
        memberUids.add(querySnapshot.docs.first.id);
      } else {
        throw Exception('User with email $email not found.');
      }
    }

    // 2. Creamos el grupo con la lista de UIDs resueltos
    if (memberUids.isNotEmpty) {
      await _firestore.collection('groups').add({
        'name': name,
        'members': memberUids,
      });
    } else {
      throw Exception('No valid members found for the provided emails.');
    }
  }

  Future<void> updateGroup(String id, String name, List<String> memberEmails) async {
    List<String> memberUids = [];
    for (String email in memberEmails) {
      final querySnapshot = await _firestore.collection('users').where('email', isEqualTo: email.trim()).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        memberUids.add(querySnapshot.docs.first.id);
      }
    }

    await _firestore.collection('groups').doc(id).update({
      'name': name,
      'members': memberUids,
    });
  }

  Future<void> deleteGroup(String id) {
    return _firestore.collection('groups').doc(id).delete();
  }

  Future<Group> getGroupDetails(String groupId) async {
  try {
    DocumentSnapshot snapshot = await _firestore.collection('groups').doc(groupId).get();
    
    if (!snapshot.exists) {
      throw Exception('Group not found');
    }
    
    return Group.fromFirestore(snapshot);
  } catch (e) {
    throw Exception('Failed to get group details: $e');
  }
}

  Future<List<CalendarEvent>> getEventsForGroup(String groupId, List<User> allUsers, Map<String, Color> userColorMap) async {
    QuerySnapshot snapshot = await _firestore.collection('groups').doc(groupId).collection('events').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ownerId = data['createdBy'] ?? '';
      final owner = allUsers.firstWhere((u) => u.uid == ownerId, orElse: () => User(uid: '', nickname: 'Unknown', email: '', createdAt: DateTime.now()));

      return CalendarEvent(
        id: doc.id,
        title: data['title'],
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
        type: EventType.group,
        ownerId: ownerId,
        ownerName: owner.nickname,
        color: userColorMap[ownerId] ?? Colors.grey,
      );
    }).toList();
  }

  // ===================================================================
  // == MÉTODOS CRUD PARA EVENTOS DE GRUPO (REINTRODUCIDOS) ==
  // ===================================================================

  Future<void> addEvent(String groupId, String title, Timestamp startTime, Timestamp endTime) {
    // Aquí podrías añadir el UID del usuario actual como 'createdBy'
    return _firestore.collection('groups').doc(groupId).collection('events').add({
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      // 'createdBy': FirebaseAuth.instance.currentUser?.uid, // Ejemplo
    });
  }

  Future<void> updateEvent(String groupId, String eventId, String title, Timestamp startTime, Timestamp endTime) {
    return _firestore.collection('groups').doc(groupId).collection('events').doc(eventId).update({
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<void> deleteEvent(String groupId, String eventId) {
    return _firestore.collection('groups').doc(groupId).collection('events').doc(eventId).delete();
  }
}


// Método helper para generar eventos recurrentes de clases
List<CalendarEvent> _generateRecurringClassEvents({
  required String subjectName,
  required int dayOfWeek,
  required String startTimeStr,
  required String endTimeStr,
  required String classId,
  required String userId,
  required String userName,
  required Color color,
}) {
  List<CalendarEvent> events = [];
  try {
    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1]);
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(Duration(days: 30));
    DateTime endDate = today.add(Duration(days: 90));
    for (DateTime current = startDate; current.isBefore(endDate); current = current.add(Duration(days: 1))) {
      if (current.weekday == dayOfWeek) {
        final startTime = DateTime(current.year, current.month, current.day, startHour, startMinute);
        final endTime = DateTime(current.year, current.month, current.day, endHour, endMinute);
        events.add(CalendarEvent(
          id: '${classId}_${current.millisecondsSinceEpoch}',
          title: "Class: $subjectName",
          startTime: startTime,
          endTime: endTime,
          type: EventType.classSession,
          ownerId: userId,
          ownerName: userName,
          color: color,
        ));
      }
    }
  } catch (e) {
    throw Exception('Error generating recurring events for $subjectName: $e');
  }
  return events;
}

// Helper para verificar solapamientos de bloques de tiempo
bool _overlaps(TimeOfDay aStart, TimeOfDay aEnd, TimeOfDay bStart, TimeOfDay bEnd) {
  final aStartMins = aStart.hour * 60 + aStart.minute;
  final aEndMins = aEnd.hour * 60 + aEnd.minute;
  final bStartMins = bStart.hour * 60 + bStart.minute;
  final bEndMins = bEnd.hour * 60 + bEnd.minute;
  return aStartMins < bEndMins && bStartMins < aEndMins;
}

