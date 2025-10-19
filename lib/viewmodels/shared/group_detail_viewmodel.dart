// lib/features/groups/viewmodels/group_detail_viewmodel.dart

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../../services/shared/group_service.dart';
import '../../services/auth/auth_service.dart';

enum ViewState { idle, loading, error }

class GroupDetailViewModel extends ChangeNotifier {
  /// Valida si el rango de tiempo propuesto para un evento se solapa con clases, exámenes o tareas.
  /// Si es edición, se puede pasar el eventId para ignorar ese evento.
  /// Retorna null si no hay conflicto, o un mensaje de error si hay solapamiento.
  /// Valida si el rango de tiempo propuesto para un evento se solapa con cualquier otro evento.
  /// Si es edición, se puede pasar el eventId para ignorar ese evento.
  /// Retorna null si no hay conflicto, o un mensaje de error si hay solapamiento.
  String? validateEventSlot(DateTime date, DateTime start, DateTime end, {String? ignoreEventId}) {
    final eventsForDay = getEventsForDay(date);
    final conflict = eventsForDay.any((e) {
      if (ignoreEventId != null && e.id == ignoreEventId) return false;
      final eStart = e.startTime;
      final eEnd = e.endTime;
      return start.isBefore(eEnd) && end.isAfter(eStart);
    });
    if (conflict) {
      return 'The event is interfering with another event. Please choose another time slot.';
    }
    return null;
  }
  Future<void> updateGroupEvent(String eventId, String title, DateTime startTime, DateTime endTime) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('events')
          .doc(eventId)
          .update({
        'title': title,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _loadAllEventsForGroup();
      notifyListeners();
    } catch (e) {
      print('Error updating group event: $e');
      throw e;
    }
  }
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
    print('Loading group data for groupId: $groupId');
    _setState(ViewState.loading);
    try {
      // 1. Obtener detalles del grupo y sus miembros
      print('Getting group details...');
      final group = await _groupService.getGroupDetails(groupId);
      print('Group found: ${group.name}, members: ${group.memberUids}');

      _groupMembers = await _getGroupMembers(group.memberUids);
      print('Group members loaded: ${_groupMembers.length}');
      
      // 2. Obtener todos los eventos para los miembros del grupo
      print('Loading events for group...');
      await _loadAllEventsForGroup();
      print('Total events loaded: ${_allEvents.length}');
      
      _setState(ViewState.idle);
    } catch (e) {
      print('Error loading group data: $e');
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
          print('⚠ User not found for UID: $uid');
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
          ownerName = creator.nick;
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
      // Usar el Facade de GroupService para obtener todos los eventos del usuario
      final memberEvents = await _groupService.getCalendarEventsForUser(member, _getColorForEventType(EventType.personal));
      allEvents.addAll(memberEvents);
      print('✅ Loaded ${memberEvents.length} events for member: ${member.nick}');
    } catch (e) {
      print('Error loading member events for ${member.nick}: $e');
    }
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

  Future<void> deleteGroupEvent(String eventId) async {
  // Eliminamos el evento de la lista local para una respuesta de UI instantánea
  _allEvents.removeWhere((event) => event.id == eventId && event.type == EventType.group);
  notifyListeners();
  
  // Llamamos al servicio para borrarlo permanentemente de la base de datos
  try {
    await _groupService.deleteEvent(groupId, eventId);
    // No es estrictamente necesario recargar todo si la UI ya está actualizada,
    // pero lo dejamos como respaldo en caso de error.
  } catch (e) {
    print('Error deleting group event: $e');
    // Si la eliminación en el backend falla, recargamos todo para
    // que el evento eliminado vuelva a aparecer y mantener la consistencia.
    await _loadGroupData();
  }
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
