// lib/features/groups/viewmodels/group_detail_viewmodel.dart

import 'package:flutter/widgets.dart'; // Para WidgetsBinding
import 'package:flutter/material.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/free_block_model.dart';

enum ViewState { idle, loading, error }

class GroupDetailViewModel extends ChangeNotifier {
  // Bloques de disponibilidad grupal (lunes a viernes, 6am-9pm, 30 min)
  List<FreeBlock> _groupFreeBlocks = [];
  List<FreeBlock> get groupFreeBlocks => _groupFreeBlocks;

  final String groupId;
  final SharedRepository _repository;
  final ConnectivityManager _connectivity;
  
  ViewState _state = ViewState.idle;
  List<CalendarEvent> _allEvents = [];
  List<AppUser> _groupMembers = [];
  String? _errorMessage;
  bool _isOnline = true;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<AppUser> get groupMembers => _groupMembers;
  bool get isOnline => _isOnline;

  GroupDetailViewModel({
    required this.groupId,
    required SharedRepository repository,
    required ConnectivityManager connectivity,
  })  : _repository = repository,
        _connectivity = connectivity {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });
    
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
      // 1. Obtener detalles del grupo usando el repositorio (offline-first)
      final group = await _repository.getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      // 2. Obtener miembros del grupo desde el repositorio
      _groupMembers = await _repository.getGroupMembers(groupId);
      
      // 3. Obtener todos los eventos para el grupo
      await _loadAllEventsForGroup();
      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> _loadAllEventsForGroup() async {
    try {
      // Obtener eventos del grupo desde el repositorio (offline-first)
      _allEvents = await _repository.getEventsForGroup(groupId);
      
      // Calcular bloques de disponibilidad grupal
      await _calculateGroupFreeBlocks();
    } catch (e, stackTrace) {
      print('❌ Error loading events: $e');
      print('❌ Stack trace: $stackTrace');
      throw e;
    }
  }

  Future<void> _calculateGroupFreeBlocks() async {
    // Agrupar eventos por miembro
    final memberEvents = <String, List<CalendarEvent>>{};
    for (final member in _groupMembers) {
      memberEvents[member.nick] = _allEvents
          .where((e) => e.ownerName == member.nick)
          .toList();
    }
    
    // Calcular free blocks usando el método estático del repositorio
    final blocksRaw = SharedRepository.calculateGroupFreeBlocks(
      memberEvents: memberEvents,
      intervalMinutes: 30,
      weekdays: [1, 2, 3, 4, 5], // Lunes a Viernes
      startHour: 6,
      endHour: 21,
    );
    
    // Convertir de Map a FreeBlock
    _groupFreeBlocks = blocksRaw.map((block) {
      // Handle both List and String formats for freeMembers
      final freeMembersData = block['freeMembers'];
      final List<String> freeMembers = freeMembersData is List
          ? freeMembersData.map((e) => e.toString()).toList()
          : (freeMembersData as String).split(',').where((s) => s.isNotEmpty).toList();
      
      return FreeBlock(
        weekday: block['weekday'] as int,
        start: TimeOfDay(
          hour: block['startHour'] as int,
          minute: block['startMinute'] as int,
        ),
        end: TimeOfDay(
          hour: block['endHour'] as int,
          minute: block['endMinute'] as int,
        ),
        freeMembers: freeMembers,
      );
    }).toList();
    
    // Opcional: Cachear los bloques calculados
    if (blocksRaw.isNotEmpty) {
      await _repository.cacheFreeBlocks(groupId, blocksRaw);
    }
  }

  Future<void> refreshData() async {
    await _loadGroupData();
  }
}
