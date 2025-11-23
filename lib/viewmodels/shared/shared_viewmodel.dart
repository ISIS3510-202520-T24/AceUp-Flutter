// lib/features/groups/viewmodels/shared_viewmodel.dart

import 'dart:developer' as console;

import 'package:flutter/material.dart';

import '../../models/shared/group_model.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/user_model.dart';
import '../../services/shared/sync_service.dart';
import '../../services/storage/app_preferences.dart';

// El enum de estado que usan ambos ViewModels
enum ViewState { idle, loading, error }

class SharedViewModel extends ChangeNotifier {
  final SharedRepository _repository;
  final ConnectivityManager _connectivity;
  final SyncService? _syncService;
  
  List<AppUser> availableUsers = []; // Nueva lista para el selector
  List<Group> groups = [];
  
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  String? _currentUserId;

  SharedViewModel({
    required SharedRepository repository,
    required ConnectivityManager connectivity,
    SyncService? syncService,
  })  : _repository = repository,
        _connectivity = connectivity,
        _syncService = syncService {
    // 🔹 STREAM: Subscribe a cambios de conectividad
    _connectivity.onConnectivityChanged.listen((isOnline) {
      final wasOffline = !_isOnline;
      _isOnline = isOnline;
      notifyListeners();
      
      // 🔹 FUTURE CON HANDLER: Si recuperamos conexión después de estar offline, verificar preferencia
      if (isOnline && wasOffline) {
        print('🌐 Conexión restaurada en SharedViewModel');
        
        // Verificar si auto-refresh está habilitado
        final autoRefresh = AppPreferences.instance.autoRefreshOnReconnect;
        if (!autoRefresh) {
          print('🚫 Auto-refresh deshabilitado por preferencias - no recargando usuarios');
          return;
        }
        
        print('✅ Auto-refresh habilitado - recargando usuarios');
        fetchAllUsers()
          .then((_) {
            print('✅ Usuarios recargados después de reconexión');
          })
          .catchError((error) {
            print('❌ Error al recargar usuarios: $error');
          });
      }
    });
    
    // 🔹 FUTURE CON HANDLER: Cargar usuarios iniciales
    fetchAllUsers()
      .then((_) => print('✅ Usuarios iniciales cargados'))
      .catchError((error) => print('⚠️ Error cargando usuarios iniciales: $error'));
  }

  // Metodo privado para cambiar el estado y notificar a la UI
  void _setState(ViewState viewState) {
    if (_state == viewState) return;
    _state = viewState;
    Future.microtask(() {
      notifyListeners();
    });
  }

  // --- MÉTODOS EXISTENTES (ACTUALIZADOS PARA OFFLINE-FIRST) ---

  Future<void> fetchGroups(String userId, {bool skipFirestore = false}) async {
    _currentUserId = userId;
    
    print('🔵 [FETCH] fetchGroups called with skipFirestore=$skipFirestore');

    _setState(ViewState.loading);
    try {
      // Usa el repositorio offline-first: intenta cache local primero
      groups = await _repository.getGroupsForUser(userId, skipFirestore: skipFirestore);
      print('📦 [FETCH] Loaded ${groups.length} groups');

      // Cargar miembros de cada grupo
      for (var group in groups) {
        final members = await _repository.getGroupMembers(group.id);
        group.members = members;
      }

      _setState(ViewState.idle);
    } catch (e) {
      console.log('Error fetching groups: $e');
      _setState(ViewState.error);
    }
  }

  // --- NUEVOS MÉTODOS CRUD (ACTUALIZADOS PARA OFFLINE-FIRST) ---

  /// Añade un nuevo grupo - se guarda localmente y se sincroniza en background
  Future<void> addGroup(String name, List<String> memberEmails, {String? imageUrl}) async {
    try {
      final authService = AuthService();
      final currentUserId = authService.currentUser?.uid;
      final currentUserEmail = authService.currentUser?.email;
      
      // Asegurar que el usuario actual esté en la lista de emails
      if (currentUserEmail != null && !memberEmails.any((email) => email.toLowerCase() == currentUserEmail.toLowerCase())) {
        memberEmails.add(currentUserEmail);
      }

      // Ensure users are loaded
      if (availableUsers.isEmpty) {
        await fetchAllUsers();
      }

      // Convert emails to UIDs
      final memberUids = _emailsToUids(memberEmails);
      
      // 🔥 IMPORTANTE: Asegurar que el creador SIEMPRE esté en memberUids
      // Esto evita problemas cuando el usuario actual no está en availableUsers
      if (currentUserId != null && !memberUids.contains(currentUserId)) {
        memberUids.insert(0, currentUserId); // Agregar al inicio
        print('✅ Creador del grupo agregado a memberUids: $currentUserId');
      }
      
      // Validar que haya al menos un miembro
      if (memberUids.isEmpty) {
        print('❌ No se pudo agregar ningún miembro al grupo');
        console.log('Error: No members could be added to the group');
        return;
      }
      
      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        memberUids: memberUids,
        imageUrl: imageUrl,
      );

      print('📝 Creando grupo con ${memberUids.length} miembros: $memberUids');
      await _repository.createGroup(newGroup);
      
      // Trigger immediate sync if online
      if (_syncService != null && _connectivity.isOnline) {
        print('🚀 [CREATE] Triggering immediate sync after group creation');
        _syncService.syncPendingOperations();
      }
      
      // Refresh groups - Force refresh with current user
      if (_currentUserId != null) {
        await fetchGroups(_currentUserId!);
      } else {
        // Si no hay currentUserId, obtenerlo del AuthService
        final userId = authService.currentUser?.uid;
        if (userId != null) {
          await fetchGroups(userId);
        } else {
          console.log('⚠️ Cannot refresh groups: no user ID available');
        }
      }
      
      // Force UI update even if state didn't change
      notifyListeners();
    } catch (e) {
      console.log('Error adding group: $e');
    }
  }

  /// Actualiza un grupo existente - se guarda localmente y se sincroniza en background
  Future<void> updateGroup(String id, String name, List<String> memberEmails, {String? imageUrl}) async {
    try {
      final authService = AuthService();
      final currentUserId = authService.currentUser?.uid;
      
      // Ensure users are loaded
      if (availableUsers.isEmpty) {
        await fetchAllUsers();
      }

      // Convert emails to UIDs
      final memberUids = _emailsToUids(memberEmails);
      
      // 🔥 IMPORTANTE: Asegurar que el usuario actual siempre esté en memberUids
      // (puede que se esté editando el grupo y el creador se removió por error)
      if (currentUserId != null && !memberUids.contains(currentUserId)) {
        memberUids.insert(0, currentUserId);
        print('✅ Usuario actual agregado a memberUids durante actualización: $currentUserId');
      }
      
      // Validar que haya al menos un miembro
      if (memberUids.isEmpty) {
        print('❌ No se pudo actualizar: el grupo quedaría sin miembros');
        console.log('Error: Group must have at least one member');
        return;
      }
      
      final updatedGroup = Group(
        id: id,
        name: name,
        memberUids: memberUids,
        imageUrl: imageUrl,
      );

      print('📝 Actualizando grupo con ${memberUids.length} miembros: $memberUids');
      await _repository.updateGroup(updatedGroup);
      
      // Refresh groups - Skip Firestore and use local data immediately after update
      // This ensures UI shows the latest changes instantly
      print('⚡ [UPDATE] Refreshing with local data only (skipFirestore=true)');
      if (_currentUserId != null) {
        await fetchGroups(_currentUserId!, skipFirestore: true);
      } else {
        // Si no hay currentUserId, obtenerlo del AuthService
        final authService = AuthService();
        final userId = authService.currentUser?.uid;
        if (userId != null) {
          await fetchGroups(userId, skipFirestore: true);
        } else {
          console.log('⚠️ Cannot refresh groups: no user ID available');
        }
      }
      
      // Force UI update even if state didn't change
      notifyListeners();
      
      // Schedule a background refresh from Firestore after 5 seconds (increased delay)
      // This ensures we get synced data without blocking the UI
      // Using Future.delayed without await so it doesn't block
      Future.delayed(const Duration(seconds: 5), () {
        print('⏰ [DELAYED] Background Firestore refresh starting...');
        if (_currentUserId != null) {
          fetchGroups(_currentUserId!, skipFirestore: false);
        }
      });
    } catch (e) {
      console.log('Error updating group: $e');
    }
  }

  /// Elimina un grupo con actualización optimista
  Future<void> deleteGroup(String id) async {
    // 1. Actualización optimista: Borra el grupo de la lista local inmediatamente
    final index = groups.indexWhere((group) => group.id == id);
    if (index == -1) return;
    
    final groupToDelete = groups.removeAt(index);
    notifyListeners();

    // 2. Llama al repositorio para borrar (se sincroniza en background)
    try {
      await _repository.deleteGroup(id);
    } catch (e) {
      console.log('Error deleting group: $e');
      // 3. Si falla, revierte el cambio
      groups.insert(index, groupToDelete);
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      availableUsers = await _repository.getAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  /// Helper to convert emails to UIDs
  List<String> _emailsToUids(List<String> emails) {
    return emails
        .map((email) {
          final user = availableUsers.firstWhere(
            (u) => u.email.toLowerCase() == email.toLowerCase(),
            orElse: () => AppUser(uid: '', nick: '', email: ''),
          );
          return user.uid;
        })
        .where((uid) => uid.isNotEmpty)
        .toList();
  }
}