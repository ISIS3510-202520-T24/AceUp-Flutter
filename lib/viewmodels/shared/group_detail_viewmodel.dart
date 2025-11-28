// lib/features/groups/viewmodels/group_detail_viewmodel.dart

import 'package:flutter/widgets.dart'; // Para WidgetsBinding
import 'package:flutter/material.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../../models/free_block_model.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../services/storage/hive_service.dart';
import '../../services/storage/app_preferences.dart';

enum ViewState { idle, loading, error }

class GroupDetailViewModel extends ChangeNotifier {
  // Bloques de disponibilidad grupal (lunes a viernes, 6am-9pm, 30 min)
  List<FreeBlock> _groupFreeBlocks = [];
  List<FreeBlock> get groupFreeBlocks => _groupFreeBlocks;

  final String groupId;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final ConnectivityManager _connectivity;

  ViewState _state = ViewState.idle;
  List<CalendarEvent> _allEvents = [];
  List<User> _groupMembers = [];
  String? _errorMessage;
  bool _isOnline = true;

  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<User> get groupMembers => _groupMembers;
  bool get isOnline => _isOnline;

  GroupDetailViewModel({
    required this.groupId,
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required ConnectivityManager connectivity,
  })  : _groupRepository = groupRepository,
        _userRepository = userRepository,
        _connectivity = connectivity {
    // 🔹 STREAM: Subscribe a cambios de conectividad
    _connectivity.onConnectivityChanged.listen((isOnline) {
      final wasOffline = !_isOnline;
      _isOnline = isOnline;
      notifyListeners();
      
      // 🔹 FUTURE CON HANDLER: Si recuperamos conexión, verificar preferencia antes de refrescar
      if (isOnline && wasOffline) {
        print('🌐 Conexión restaurada en GroupDetailViewModel');
        
        // Verificar si auto-refresh está habilitado
        final autoRefresh = AppPreferences.instance.autoRefreshOnReconnect;
        if (!autoRefresh) {
          print('🚫 Auto-refresh deshabilitado por preferencias - no refrescando datos');
          return;
        }
        
        print('✅ Auto-refresh habilitado - refrescando datos del grupo');
        refreshData()
          .then((_) {
            print('✅ Datos refrescados después de recuperar conexión');
          })
          .catchError((error) {
            print('❌ Error al refrescar: $error');
            _errorMessage = error.toString();
            _setState(ViewState.error);
          });
      }
    });
    
    // 🔹 FUTURE CON HANDLER: Cargar datos iniciales usando handler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroupData()
        .then((_) => print('✅ Datos iniciales cargados correctamente'))
        .catchError((error) {
          print('❌ Error cargando datos iniciales: $error');
          _errorMessage = error.toString();
          _setState(ViewState.error);
        });
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
      final group = await _groupRepository.getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      // 2. Registrar visita al grupo en Hive
      await HiveService.instance.recordGroupVisit(
        groupId: groupId,
        groupName: group.name,
        avatarUrl: null, // Group model doesn't have imageUrl
      );
      print('Visita registrada en Hive: ${group.name}');

      // 3. Obtener miembros del grupo - convert GroupMember to User
      _groupMembers = [];
      for (final member in group.members) {
        final user = await _userRepository.getUserByUid(member.userId);
        if (user != null) {
          _groupMembers.add(user);
        }
      }

      // 4. Obtener todos los eventos para el grupo
      await _loadAllEventsForGroup();
      _setState(ViewState.idle);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> _loadAllEventsForGroup() async {
    try {
      // TODO: Implement calendar event generation from academic data
      // For now, return empty list
      _allEvents = [];

      // Calcular bloques de disponibilidad grupal
      await _calculateGroupFreeBlocks();
    } catch (e, stackTrace) {
      print('Error loading events: $e');
      print('Stack trace: $stackTrace');
      throw e;
    }
  }

  /// Forzar refresh desde Firebase (ignorar cache local)
  /// Útil cuando sabes que los datos cambiaron en Firebase
  Future<void> forceRefreshFromFirebase() async {
    // Verificar preferencia de auto-refresh
    final prefs = AppPreferences.instance;
    if (!prefs.autoRefreshOnReconnect) {
      print('Auto-refresh deshabilitado por preferencias');
      return;
    }

    if (!_isOnline) {
      _errorMessage = 'No hay conexión a internet';
      _setState(ViewState.error);
      return;
    }

    _setState(ViewState.loading);
    try {
      print('Forzando refresh desde Firebase...');

      // Recargar todo desde Firebase
      await _loadGroupData();

      // Actualizar timestamp de última sincronización
      await prefs.markSyncedNow();

      print('✅ Datos actualizados desde Firebase');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> _calculateGroupFreeBlocks() async {
    // TODO: Implement free block calculation from calendar events
    // For now, return empty list since we don't have events
    _groupFreeBlocks = [];
  }

  Future<void> refreshData() async {
    await _loadGroupData();
  }

  /// Método que combina AMBOS patrones: async/await y Future handlers
  /// - Usa async/await para operaciones internas
  /// - Retorna Future que puede ser manejado con .then()/.catchError() externamente
  Future<Map<String, dynamic>> loadGroupStatistics() async {
    print('📊 Cargando estadísticas del grupo...');

    try {
      final group = await _groupRepository.getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      // Calcular estadísticas
      final stats = {
        'groupName': group.name,
        'memberCount': group.members.length,
        'eventCount': _allEvents.length,
        'hasInviteCode': group.inviteCode.isNotEmpty,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('✅ Estadísticas calculadas: $stats');
      return stats;

    } catch (e) {
      print('❌ Error calculando estadísticas: $e');
      rethrow; // Re-lanzar para que el caller pueda manejarlo con .catchError()
    }
  }

  /// Ejemplo de uso desde la UI:
  /// viewModel.loadGroupStatistics()
  ///   .then((stats) => print('Stats: $stats'))
  ///   .catchError((error) => print('Error: $error'));
}
