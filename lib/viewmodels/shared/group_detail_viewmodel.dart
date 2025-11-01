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
      
      // TODO: Implementar conversión de bloques del caché
      // Por ahora calculamos los bloques directamente
      await _calculateGroupFreeBlocks();
    } catch (e) {
      print('Error loading events: $e');
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
    
    // TODO: Implement free blocks calculation
    // For now, using empty list - this would need the logic from GroupService
    _groupFreeBlocks = [];
  }

  Future<void> refreshData() async {
    await _loadGroupData();
  }
}
