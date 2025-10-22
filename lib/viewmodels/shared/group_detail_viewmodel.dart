// lib/features/groups/viewmodels/group_detail_viewmodel.dart

import 'package:flutter/widgets.dart'; // Para WidgetsBinding
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../../services/shared/group_service.dart';
import '../../models/free_block_model.dart';

enum ViewState { idle, loading, error }



class GroupDetailViewModel extends ChangeNotifier {
  // Bloques de disponibilidad grupal (lunes a viernes, 6am-9pm, 30 min)
  List<FreeBlock> _groupFreeBlocks = [];
  List<FreeBlock> get groupFreeBlocks => _groupFreeBlocks;

  final String groupId;
  final GroupService _groupService = GroupService();
  
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
    _setState(ViewState.loading);
    try {
      // 1. Obtener detalles del grupo y sus miembros
      final group = await _groupService.getGroupDetails(groupId);

      _groupMembers = await _getGroupMembers(group.memberUids);
      
      // 2. Obtener todos los eventos para los miembros del grupo
      await _loadAllEventsForGroup();
      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);

    }
  }

  Future<List<AppUser>> _getGroupMembers(List<String> memberUids) async {
    try {
      List<AppUser> members = [];
      for (String uid in memberUids) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        
        if (userDoc.exists) {
          final user = AppUser.fromFirestore(userDoc);
          members.add(user);
        } else {
          print('User not found for UID: $uid');
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
      // Cargar eventos de cada miembro del grupo (solo clases)
      for (AppUser member in _groupMembers) {
        await _loadMemberEvents(member, allEvents);
      }
      
      _allEvents = allEvents;
      // Calcular bloques de disponibilidad grupal (lunes a viernes, 6am-9pm)
      final memberEvents = <String, List<CalendarEvent>>{};
      for (final member in _groupMembers) {
        memberEvents[member.nick] = _allEvents.where((e) => e.ownerName == member.nick).toList();
      }
      _groupFreeBlocks = await GroupService.calculateGroupFreeBlocks(
        memberEvents: memberEvents,
        intervalMinutes: 30,
        weekdays: [1,2,3,4,5], // Lunes a Viernes
        startHour: 6,
        endHour: 21,
      );
    } catch (e) {
      print('Error loading events: $e');
      throw e;
    }
  }

  Future<void> _loadMemberEvents(AppUser member, List<CalendarEvent> allEvents) async {
    try {
      // Usar el método optimizado para grupos: solo carga clases (sin personal/assignments/exams)
      // No requiere color porque la vista no muestra colores por usuario
      final memberEvents = await _groupService.getClassEventsOnlyForUser(member);
      allEvents.addAll(memberEvents);
    } catch (e) {
      print('Error loading member events for ${member.nick}: $e');
    }
  }

  Future<void> refreshData() async {
    await _loadGroupData();
  }
}
