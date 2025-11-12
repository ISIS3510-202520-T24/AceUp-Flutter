// lib/features/groups/viewmodels/group_detail_viewmodel.dart

import 'package:flutter/widgets.dart'; // Para WidgetsBinding
import 'package:flutter/material.dart';
import '../../models/calendar_event_model.dart';
import '../../models/user_model.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/free_block_model.dart';
import '../../services/storage/hive_service.dart';
import '../../services/storage/app_preferences.dart';

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
      final group = await _repository.getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      // 2. NUEVO: Registrar visita al grupo en Hive
      await HiveService.instance.recordGroupVisit(
        groupId: groupId,
        groupName: group.name,
        avatarUrl: group.imageUrl,
      );
      print('Visita registrada en Hive: ${group.name}');

      // 3. Obtener miembros del grupo desde el repositorio
      _groupMembers = await _repository.getGroupMembers(groupId);
      
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
      // Obtener eventos del grupo desde el repositorio (offline-first)
      _allEvents = await _repository.getEventsForGroup(groupId);
      
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
    // NUEVO: Verificar preferencia de auto-refresh
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
      
      // 1. Invalidar cache de eventos
      await _repository.invalidateEventsCache(groupId);
      
      // 2. Invalidar cache de FreeBlocks
      await _repository.invalidateFreeBlocksCache(groupId);
      
      // 3. Recargar todo desde Firebase
      await _loadGroupData();
      
      // 4. 🔹 NUEVO: Actualizar timestamp de última sincronización
      await prefs.markSyncedNow();
      
      print('✅ Datos actualizados desde Firebase');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
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

  /// 🔹 FUTURE CON HANDLER + ASYNC/AWAIT (10 puntos)
  /// Método que combina AMBOS patrones en el mismo flujo:
  /// - Usa async/await para operaciones internas
  /// - Retorna Future que puede ser manejado con .then()/.catchError() externamente
  Future<Map<String, dynamic>> loadGroupStatistics() async {
    print('📊 Cargando estadísticas del grupo...');
    
    try {
      // 🔹 ASYNC/AWAIT: Operaciones internas síncronas
      final group = await _repository.getGroupById(groupId);
      if (group == null) {
        throw Exception('Group not found');
      }

      final members = await _repository.getGroupMembers(groupId);
      final events = await _repository.getEventsForGroup(groupId);
      
      // Calcular estadísticas
      final stats = {
        'groupName': group.name,
        'memberCount': members.length,
        'eventCount': events.length,
        'hasImage': group.imageUrl != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      print('✅ Estadísticas calculadas: $stats');
      return stats;
      
    } catch (e) {
      print('❌ Error calculando estadísticas: $e');
      rethrow; // Re-lanzar para que el caller pueda manejarlo con .catchError()
    }
  }
  
  /// 🔹 EJEMPLO DE USO: Este método se puede llamar con handlers desde la UI
  /// Ejemplo en UI:
  /// viewModel.loadGroupStatistics()
  ///   .then((stats) => print('Stats: $stats'))
  ///   .catchError((error) => print('Error: $error'));
}
