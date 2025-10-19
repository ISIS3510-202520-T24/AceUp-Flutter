// lib/features/groups/services/group_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../models/calendar_event_model.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- MÉTODOS DE USUARIO ---

  Future<List<AppUser>> getAllUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }

  Future<List<CalendarEvent>> getCalendarEventsForUser(AppUser user, Color color) async {
    List<CalendarEvent> allEvents = [];
    final userId = user.uid;

      // Función de ayuda para una conversión segura de Timestamp
    DateTime _safeTimestampToDate(dynamic timestamp) {
      return (timestamp as Timestamp? ?? Timestamp.now()).toDate();
    }

    try {
    print('🔄 Loading personal events for user: ${user.nick}');
    
    // 1. Cargar eventos personales de users/{userId}/events
    final personalEventsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .get();
    
    print('📅 Personal events found: ${personalEventsSnap.docs.length}');
    
    allEvents.addAll(personalEventsSnap.docs.map((doc) {
      final data = doc.data();
      return CalendarEvent(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        startTime: _safeTimestampToDate(data['startTime']),
        endTime: _safeTimestampToDate(data['endTime']),
        type: EventType.personal,
        ownerId: userId,
        ownerName: user.nick,
        color: color,
      );
    }));

    // 2. Cargar eventos académicos de users/{userId}/terms/{termId}/subjects/{subjectId}/...
    final termsSnap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('terms')
        .get();
    
    print('📚 Terms found: ${termsSnap.docs.length}');

    for (var termDoc in termsSnap.docs) {
      print('🔍 Processing term: ${termDoc.id}');
      
      final subjectsSnap = await termDoc.reference.collection('subjects').get();
      print('📖 Subjects found in term ${termDoc.id}: ${subjectsSnap.docs.length}');
      
      for (var subjectDoc in subjectsSnap.docs) {
        final subjectData = subjectDoc.data();
        final subjectName = subjectData['name'] ?? 'Unknown Subject';
        print('📝 Processing subject: $subjectName');
        
        // 2.1 Cargar exámenes
        final examsSnap = await subjectDoc.reference.collection('exams').get();
        print('🎯 Exams found in $subjectName: ${examsSnap.docs.length}');

        allEvents.addAll(examsSnap.docs.map((doc) {
          final data = doc.data();
          return CalendarEvent(
            id: doc.id,
            title: "Exam: ${data['title'] ?? 'Untitled'} ($subjectName)",
            startTime: _safeTimestampToDate(data['startTime']),
            endTime: _safeTimestampToDate(data['endTime']),
            type: EventType.exam,
            ownerId: userId,
            ownerName: user.nick,
            color: color,
          );
        }));
        
        // 2.2 Cargar assignments (tareas)
        final assignmentsSnap = await subjectDoc.reference.collection('assignments').get();
        print('📋 Assignments found in $subjectName: ${assignmentsSnap.docs.length}');
        
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
            ownerName: user.nick,
            color: color,
          );
        }));

        // 2.3 Cargar clases
        final classesSnap = await subjectDoc.reference.collection('classes').get();
        print('🏫 Classes found in $subjectName: ${classesSnap.docs.length}');
        
        for (var classDoc in classesSnap.docs) {
          final data = classDoc.data();
          
          // Verificar que tenemos los datos necesarios
          if (data['dayOfWeek'] != null && data['startTime'] != null && data['endTime'] != null) {
            final int dayOfWeek = data['dayOfWeek']; // 1 para Lunes, 7 para Domingo
            final String startTimeStr = data['startTime']; // ej. "08:00"
            final String endTimeStr = data['endTime'];   // ej. "09:20"
            
            print('📅 Processing class: $subjectName on day $dayOfWeek from $startTimeStr to $endTimeStr');
            
            // Generar eventos recurrentes para las clases
            final classEvents = _generateRecurringClassEvents(
              subjectName: subjectName,
              dayOfWeek: dayOfWeek,
              startTimeStr: startTimeStr,
              endTimeStr: endTimeStr,
              classId: classDoc.id,
              userId: userId,
              userName: user.nick,
              color: color,
            );
            
            allEvents.addAll(classEvents);
            print('✅ Added ${classEvents.length} class events for $subjectName');
          }
        }
      }
    }

    print('🎉 Total events loaded for ${user.nick}: ${allEvents.length}');
    return allEvents;
    
  } catch (e) {
    print('❌ Error loading events for user ${user.nick}: $e');
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
        print('Warning: User with email $email not found.');
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
    print('Error getting group details: $e');
    throw Exception('Failed to get group details: $e');
  }
}

  Future<List<CalendarEvent>> getEventsForGroup(String groupId, List<AppUser> allUsers, Map<String, Color> userColorMap) async {
    QuerySnapshot snapshot = await _firestore.collection('groups').doc(groupId).collection('events').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final ownerId = data['createdBy'] ?? '';
      final owner = allUsers.firstWhere((u) => u.uid == ownerId, orElse: () => AppUser(uid: '', nick: 'Unknown', email: ''));

      return CalendarEvent(
        id: doc.id,
        title: data['title'],
        startTime: (data['startTime'] as Timestamp).toDate(),
        endTime: (data['endTime'] as Timestamp).toDate(),
        type: EventType.group,
        ownerId: ownerId,
        ownerName: owner.nick,
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
    // Parsear las horas
    final startTimeParts = startTimeStr.split(':');
    final endTimeParts = endTimeStr.split(':');
    
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);
    final endHour = int.parse(endTimeParts[0]);
    final endMinute = int.parse(endTimeParts[1]);
    
    // Generar eventos para las próximas 12 semanas
    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(Duration(days: 30)); // Empezar desde hace un mes
    DateTime endDate = today.add(Duration(days: 90)); // Hasta 3 meses adelante

        for (DateTime current = startDate; current.isBefore(endDate); current = current.add(Duration(days: 1))) {
      // Verificar si el día actual coincide con el día de la semana de la clase
      if (current.weekday == dayOfWeek) {
        final startTime = DateTime(
          current.year,
          current.month,
          current.day,
          startHour,
          startMinute,
        );
        
        final endTime = DateTime(
          current.year,
          current.month,
          current.day,
          endHour,
          endMinute,
        );
        
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
    print('❌ Error generating recurring events for $subjectName: $e');
  }
  
  return events;
}

