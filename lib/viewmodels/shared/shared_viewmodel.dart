// lib/features/groups/viewmodels/shared_viewmodel.dart

import 'dart:developer' as console;

import 'package:flutter/material.dart';

import '../../models/shared/group_model.dart';
import '../../models/shared/group_member_model.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/user_model.dart';
import '../../services/shared/sync_service.dart';
import '../../services/storage/app_preferences.dart';
import 'dart:math';

// El enum de estado que usan ambos ViewModels
enum ViewState { idle, loading, error }

class SharedViewModel extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  final ConnectivityManager _connectivity;
  final SyncService? _syncService;

  List<User> availableUsers = []; // Lista de usuarios disponibles
  List<Group> groups = [];
  
  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  SharedViewModel({
    required GroupRepository groupRepository,
    required UserRepository userRepository,
    required ConnectivityManager connectivity,
    SyncService? syncService,
  })  : _groupRepository = groupRepository,
        _userRepository = userRepository,
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
    print('🔵 [FETCH] fetchGroups called');

    _setState(ViewState.loading);
    try {
      // Get groups owned by user and groups where user is a member
      final ownedGroups = await _groupRepository.getGroupsOwnedByUser(userId);
      final memberGroups = await _groupRepository.getGroupsForMember(userId);

      // Combine and remove duplicates
      final allGroupsMap = <String, Group>{};
      for (final group in [...ownedGroups, ...memberGroups]) {
        allGroupsMap[group.id] = group;
      }
      groups = allGroupsMap.values.toList();

      print('📦 [FETCH] Loaded ${groups.length} groups');

      _setState(ViewState.idle);
    } catch (e) {
      console.log('Error fetching groups: $e');
      _setState(ViewState.error);
    }
  }

  // --- NUEVOS MÉTODOS CRUD (ACTUALIZADOS PARA OFFLINE-FIRST) ---

  /// Añade un nuevo grupo - se guarda localmente y se sincroniza en background
  Future<void> addGroup(String name, List<String> memberEmails, {String? description}) async {
    try {
      final authService = AuthService();
      final currentUserId = authService.currentUser?.uid;
      final currentUserEmail = authService.currentUser?.email;

      if (currentUserId == null) {
        console.log('Error: User not logged in');
        return;
      }

      // Asegurar que el usuario actual esté en la lista de emails
      if (currentUserEmail != null && !memberEmails.any((email) => email.toLowerCase() == currentUserEmail.toLowerCase())) {
        memberEmails.add(currentUserEmail);
      }

      // Ensure users are loaded
      if (availableUsers.isEmpty) {
        await fetchAllUsers();
      }

      // Convert emails to GroupMember objects
      final members = <GroupMember>[];
      final now = DateTime.now();

      for (final email in memberEmails) {
        final user = availableUsers.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
          orElse: () => User(uid: '', email: '', nickname: '', createdAt: now),
        );

        if (user.uid.isNotEmpty) {
          members.add(GroupMember(
            userId: user.uid,
            nickname: user.nickname,
            joinedAt: now,
          ));
        }
      }

      // Asegurar que el creador SIEMPRE esté en members
      if (!members.any((m) => m.userId == currentUserId)) {
        final currentUser = availableUsers.firstWhere(
          (u) => u.uid == currentUserId,
          orElse: () => User(uid: currentUserId, email: currentUserEmail ?? '', nickname: 'Me', createdAt: now),
        );
        members.insert(0, GroupMember(
          userId: currentUserId,
          nickname: currentUser.nickname,
          joinedAt: now,
        ));
      }

      // Validar que haya al menos un miembro
      if (members.isEmpty) {
        print('❌ No se pudo agregar ningún miembro al grupo');
        console.log('Error: No members could be added to the group');
        return;
      }

      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        color: _generateRandomColor(),
        ownerId: currentUserId,
        members: members,
        inviteCode: _generateInviteCode(),
        createdAt: now,
        updatedAt: now,
      );

      print('📝 Creando grupo con ${members.length} miembros');
      await _groupRepository.saveGroup(newGroup);

      // Trigger immediate sync if online
      if (_syncService != null && _connectivity.isOnline) {
        print('🚀 [CREATE] Triggering immediate sync after group creation');
        _syncService.syncPendingOperations();
      }

      // Refresh groups
      await fetchGroups(currentUserId);

      // Force UI update
      notifyListeners();
    } catch (e) {
      console.log('Error adding group: $e');
    }
  }

  /// Actualiza un grupo existente - se guarda localmente y se sincroniza en background
  Future<void> updateGroup(String id, String name, List<String> memberEmails, {String? description}) async {
    try {
      final authService = AuthService();
      final currentUserId = authService.currentUser?.uid;

      if (currentUserId == null) {
        console.log('Error: User not logged in');
        return;
      }

      // Get existing group to preserve fields
      final existingGroup = await _groupRepository.getGroupById(id);
      if (existingGroup == null) {
        console.log('Error: Group not found');
        return;
      }

      // Ensure users are loaded
      if (availableUsers.isEmpty) {
        await fetchAllUsers();
      }

      // Convert emails to GroupMember objects
      final members = <GroupMember>[];
      final now = DateTime.now();

      for (final email in memberEmails) {
        final user = availableUsers.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
          orElse: () => User(uid: '', email: '', nickname: '', createdAt: now),
        );

        if (user.uid.isNotEmpty) {
          // Preserve original joinedAt if member already exists
          final existingMember = existingGroup.getMember(user.uid);
          members.add(GroupMember(
            userId: user.uid,
            nickname: user.nickname,
            joinedAt: existingMember?.joinedAt ?? now,
          ));
        }
      }

      // Asegurar que el owner siempre esté en members
      if (!members.any((m) => m.userId == existingGroup.ownerId)) {
        final ownerUser = availableUsers.firstWhere(
          (u) => u.uid == existingGroup.ownerId,
          orElse: () => User(uid: existingGroup.ownerId, email: '', nickname: 'Owner', createdAt: now),
        );
        final existingOwner = existingGroup.getMember(existingGroup.ownerId);
        members.insert(0, GroupMember(
          userId: existingGroup.ownerId,
          nickname: ownerUser.nickname,
          joinedAt: existingOwner?.joinedAt ?? existingGroup.createdAt,
        ));
      }

      // Validar que haya al menos un miembro
      if (members.isEmpty) {
        print('❌ No se pudo actualizar: el grupo quedaría sin miembros');
        console.log('Error: Group must have at least one member');
        return;
      }

      final updatedGroup = existingGroup.copyWith(
        name: name,
        description: description,
        members: members,
        updatedAt: now,
      );

      print('📝 Actualizando grupo con ${members.length} miembros');
      await _groupRepository.saveGroup(updatedGroup);

      // Refresh groups
      await fetchGroups(currentUserId);

      // Force UI update
      notifyListeners();
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
      await _groupRepository.deleteGroup(id);
    } catch (e) {
      console.log('Error deleting group: $e');
      // 3. Si falla, revierte el cambio
      groups.insert(index, groupToDelete);
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      availableUsers = await _userRepository.getAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  /// Generate random color for group
  String _generateRandomColor() {
    final colors = [
      '#EF4444', // Red
      '#F59E0B', // Amber
      '#10B981', // Green
      '#3B82F6', // Blue
      '#8B5CF6', // Purple
      '#EC4899', // Pink
      '#6366F1', // Indigo
      '#14B8A6', // Teal
    ];
    return colors[Random().nextInt(colors.length)];
  }

  /// Generate 6-character invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}