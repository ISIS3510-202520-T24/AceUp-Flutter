// lib/features/groups/viewmodels/group_detail_view_model.dart

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/calendar_event_model.dart';
import '../models/user_model.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';

enum ViewState { idle, loading, error }

class GroupDetailViewModel extends ChangeNotifier {
  final String groupId;
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  
  ViewState _state = ViewState.idle;
  List<CalendarEvent> _allEvents = [];
  List<AppUser> _groupMembers = [];
  String? _errorMessage;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<AppUser> get groupMembers => _groupMembers;

  GroupDetailViewModel({required this.groupId}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData();
    });
  }

  void _setState(ViewState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> _loadGroupData() async {
    print('🔄 Loading group data for groupId: $groupId');
    _setState(ViewState.loading);
    try {
      // 1. Obtener detalles del grupo y sus miembros
      print('📥 Getting group details...');
      final group = await _groupService.getGroupDetails(groupId);
      print('✅ Group found: ${group.name}, members: ${group.memberUids}');

      _groupMembers = await _getGroupMembers(group.memberUids);
      print('👥 Group members loaded: ${_groupMembers.length}');
      
      // 2. Obtener todos los eventos para los miembros del grupo
      print('📅 Loading events for group...');
      await _loadAllEventsForGroup();
      print('🎉 Total events loaded: ${_allEvents.length}');
      
      _setState(ViewState.idle);
    } catch (e) {
      print('❌ Error loading group data: $e');
      _errorMessage = e.toString();
      _setState(ViewState.error);

    }
  }

  Future<List<AppUser>> _getGroupMembers(List<String> memberUids) async {
    try {
      print('👥 Getting members for UIDs: $memberUids');
      List<AppUser> members = [];
      for (String uid in memberUids) {
        print('🔍 Looking for user: $uid');
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        
        if (userDoc.exists) {
          final user = AppUser.fromFirestore(userDoc);
          members.add(user);
          print('✅ Found user: ${user.nick} (${user.email})');
        } else {
          print('⚠️ User not found for UID: $uid');
        }
      }
      return members;
    } catch (e) {
      print('Error getting group members: $e');
      return [];
    }
  }

  Future<void> _loadAllEventsForGroup() async {
    List<CalendarEvent> allEvents = [];
    
    try {
      // 1. Eventos específicos del grupo
      print('🔄 Loading group events...');
      await _loadGroupEvents(allEvents);
      print('📊 Group events loaded: ${allEvents.length}');

      // 2. Eventos de cada miembro del grupo (assignments, classes, exams)
      for (AppUser member in _groupMembers) {
        print('🔄 Loading events for member: ${member.nick}');
        await _loadMemberEvents(member, allEvents);
      }
      
      print('🎯 Total events after loading all: ${allEvents.length}');
      _allEvents = allEvents;
    } catch (e) {
      print('Error loading events: $e');
      throw e;
    }
  }

  Future<void> _loadGroupEvents(List<CalendarEvent> allEvents) async {
    try {
      // Obtener eventos específicos del grupo
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .get();

      for (var doc in eventsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Buscar el nombre del creador
        final createdBy = data['createdBy'] as String?;
        String ownerName = 'Unknown';
        if (createdBy != null) {
          final creator = _groupMembers.firstWhere(
            (member) => member.uid == createdBy,
            orElse: () => AppUser(uid: createdBy, nick: 'Unknown', email: ''),
          );
          ownerName = creator.nick ?? 'Unknown';
        }

        allEvents.add(CalendarEvent(
          id: doc.id,
          title: data['title'] ?? 'Group Event',
          startTime: (data['startTime'] as Timestamp).toDate(),
          endTime: (data['endTime'] as Timestamp).toDate(),
          type: EventType.group,
          ownerId: createdBy ?? '',
          ownerName: ownerName,
          color: _getColorForEventType(EventType.group),
        ));
      }
    } catch (e) {
      print('Error loading group events: $e');
    }
  }

  Future<void> _loadMemberEvents(AppUser member, List<CalendarEvent> allEvents) async {
    try {
      // Obtener el término actual (puedes ajustar esta lógica)
      final termsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(member.uid)
        .collection('terms');

      QuerySnapshot termsSnapshot = await termsRef.get();
      print('📚 Terms found for ${member.nick}: ${termsSnapshot.docs.length}');
      

    // 2. Iteramos sobre cada documento de término que encontramos
    for (var termDoc in termsSnapshot.docs) {
      print('🔍 Processing term: ${termDoc.id} for ${member.nick}');
      
      // La referencia a 'subjects' ahora viene del documento del término actual
      QuerySnapshot subjectsSnapshot = await termDoc.reference
          .collection('subjects')
          .get();

      print('📖 Subjects found in term ${termDoc.id}: ${subjectsSnapshot.docs.length}');

      for (var subjectDoc in subjectsSnapshot.docs) {
        final subjectData = subjectDoc.data() as Map<String, dynamic>;
        final subjectName = subjectData['name'] ?? 'Unknown Subject';
        
        // La referencia al documento de la materia ahora es correcta
        final subjectRef = subjectDoc.reference;

        // Pasamos la referencia correcta a las funciones de carga
        await _loadClasses(member, subjectName, allEvents, subjectRef);
        await _loadAssignments(member, subjectName, allEvents, subjectRef);
        await _loadExams(member, subjectName, allEvents, subjectRef);
      }
    }
    // ===================================================================

  } catch (e) {
    print('Error loading member events for ${member.nick}: $e');
  }
  }

  Future<void> _loadClasses(AppUser member, String subjectName, 
                           List<CalendarEvent> allEvents, DocumentReference subjectRef) async {
    try {
      QuerySnapshot classesSnapshot = await subjectRef
          .collection('classes')
          .get();

      for (var classDoc in classesSnapshot.docs) {
        final classData = classDoc.data() as Map<String, dynamic>;
        
        // Generar eventos para las próximas semanas basado en dayOfWeek
        final dayOfWeekNum = classData['dayOfWeek'] as int?;
        final startTimeStr = classData['startTime'] as String?;
        final endTimeStr = classData['endTime'] as String?;

        if (dayOfWeekNum != null && startTimeStr != null && endTimeStr != null) {
          const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          final dayOfWeekStr = weekdays[dayOfWeekNum - 1];

          final classEvents = _generateRecurringEvents(
            title: subjectName,
            dayOfWeek: dayOfWeekStr,
            startTimeStr: startTimeStr,
            endTimeStr: endTimeStr,
            type: EventType.classSession,
            ownerId: member.uid,
            ownerName: member.nick ?? 'Unknown',
          );
          allEvents.addAll(classEvents);
        }
      }
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadAssignments(AppUser member, String subjectName,
                               List<CalendarEvent> allEvents, DocumentReference subjectRef) async {
    try {
      QuerySnapshot assignmentsSnapshot = await subjectRef
          .collection('assignments')
          .get();

      for (var assignmentDoc in assignmentsSnapshot.docs) {
        final assignmentData = assignmentDoc.data() as Map<String, dynamic>;
        final dueDate = assignmentData['dueDate'] as Timestamp?;
        
        if (dueDate != null) {
          final eventType = _getEventTypeFromTitle(assignmentData['title'] ?? '');
          
          allEvents.add(CalendarEvent(
            id: assignmentDoc.id,
            title: '${assignmentData['title']} - $subjectName',
            startTime: dueDate.toDate(),
            endTime: dueDate.toDate().add(const Duration(hours: 1)),
            type: eventType,
            ownerId: member.uid,
            ownerName: member.nick ?? 'Unknown',
            color: _getColorForEventType(eventType),
          ));
        }
      }
    } catch (e) {
      print('Error loading assignments: $e');
    }
  }

  Future<void> _loadExams(AppUser member, String subjectName,
                       List<CalendarEvent> allEvents, DocumentReference subjectRef) async {
  try {
    QuerySnapshot examsSnapshot = await subjectRef
        .collection('exams')
        .get();

    for (var examDoc in examsSnapshot.docs) {
      final examData = examDoc.data() as Map<String, dynamic>;
      final startTime = examData['startTime'] as Timestamp?;
      final endTime = examData['endTime'] as Timestamp?;
      
      if (startTime != null && endTime != null) {
        allEvents.add(CalendarEvent(
          id: examDoc.id,
          title: 'Exam: ${examData['title']} - $subjectName',
          startTime: startTime.toDate(),
          endTime: endTime.toDate(),
          type: EventType.exam,
          ownerId: member.uid,
          ownerName: member.nick,
          color: _getColorForEventType(EventType.exam),
        ));
      }
    }
  } catch (e) {
    print('Error loading exams: $e');
  }
}

  List<CalendarEvent> _generateRecurringEvents({
    required String title,
    required String dayOfWeek,
    required String startTimeStr,
    required String endTimeStr,
    required EventType type,
    required String ownerName,
    required String ownerId,
  }) {
    List<CalendarEvent> events = [];
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final targetWeekday = weekdays.indexOf(dayOfWeek) + 1;
    
    if (targetWeekday == 0) return events; // Día no válido

    final startParts = startTimeStr.split(':').map(int.parse).toList();
    final endParts = endTimeStr.split(':').map(int.parse).toList();
    
    // Generamos eventos desde hace 4 semanas hasta dentro de 8 semanas
    for (int i = -28; i < 56; i++) {

      DateTime date = DateUtils.dateOnly(now).add(Duration(days: i));
      if (date.weekday == targetWeekday) {
        final eventStart = DateTime(date.year, date.month, date.day, startParts[0], startParts[1]);
        final eventEnd = DateTime(date.year, date.month, date.day, endParts[0], endParts[1]);
      
        events.add(CalendarEvent(
          id: '${title}_${date.millisecondsSinceEpoch}',
          title: title,
          startTime: eventStart,
          endTime: eventEnd,
          type: type,
          ownerId: ownerId,
          ownerName: ownerName,
          color: _getColorForEventType(type),
      ));
    }
  }
    
    return events;
  }

  EventType _getEventTypeFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('exam') || lowerTitle.contains('examen')) {
      return EventType.exam;
    }
    return EventType.assignment;
  }

  Color _getColorForEventType(EventType type) {
    switch (type) {
      case EventType.assignment:
        return Colors.blue;
      case EventType.exam:
        return Colors.red;
      case EventType.classSession:
        return Colors.green;
      case EventType.group:
        return Colors.orange;
      case EventType.personal:
      default:
        return Colors.grey;
    }
  }

  List<CalendarEvent> getEventsForDay(DateTime date) {
    final targetDate = DateUtils.dateOnly(date);
    return _allEvents.where((event) {
      final eventDate = DateUtils.dateOnly(event.startTime);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  Future<void> addGroupEvent(String title, DateTime startTime, DateTime endTime) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .add({
        'title': title,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'createdBy': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Recargar eventos
      await _loadAllEventsForGroup();
      notifyListeners();
    } catch (e) {
      print('Error adding group event: $e');
      throw e;
    }
  }

  Future<void> refreshData() async {
    await _loadGroupData();
  }
}