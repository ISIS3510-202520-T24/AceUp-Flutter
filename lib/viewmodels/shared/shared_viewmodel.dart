// lib/features/groups/viewmodels/shared_viewmodel.dart

import 'dart:developer' as console;

import 'package:flutter/material.dart';

import '../../models/group_model.dart';
import '../../services/auth/auth_service.dart';
import '../../data/repositories/shared_repository.dart';
import '../../core/connectivity/connectivity_manager.dart';
import '../../models/user_model.dart';

// El enum de estado que usan ambos ViewModels
enum ViewState { idle, loading, error }

class SharedViewModel extends ChangeNotifier {
  final SharedRepository _repository;
  final ConnectivityManager _connectivity;
  
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
  })  : _repository = repository,
        _connectivity = connectivity {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((isOnline) {
      _isOnline = isOnline;
      notifyListeners();
    });
    
    // fetchAllUsers(); // TODO: Implement with repository
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

  Future<void> fetchGroups(String userId) async {
    _currentUserId = userId; 

    _setState(ViewState.loading);
    try {
      // Usa el repositorio offline-first: intenta cache local primero
      groups = await _repository.getGroupsForUser(userId);

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
  Future<void> addGroup(String name, List<String> memberEmails) async {
    try {
      final authService = AuthService();
      final currentUserEmail = authService.currentUser?.email;
      if (currentUserEmail != null && !memberEmails.any((email) => email.toLowerCase() == currentUserEmail.toLowerCase())) {
        memberEmails.add(currentUserEmail);
      }

      // TODO: Convert emails to UIDs (requires user lookup)
      // For now, create group with empty members - to be implemented
      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        memberUids: [], // TODO: Resolve emails to UIDs
      );

      await _repository.createGroup(newGroup);
      
      // Refresh groups
      if (_currentUserId != null) {
        await fetchGroups(_currentUserId!);
      }
    } catch (e) {
      console.log('Error adding group: $e');
    }
  }

  /// Actualiza un grupo existente - se guarda localmente y se sincroniza en background
  Future<void> updateGroup(String id, String name, List<String> memberEmails) async {
    try {
      // TODO: Convert emails to UIDs
      final updatedGroup = Group(
        id: id,
        name: name,
        memberUids: [], // TODO: Resolve emails to UIDs
      );

      await _repository.updateGroup(updatedGroup);
      
      if (_currentUserId != null) {
        await fetchGroups(_currentUserId!);
      }
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
    // TODO: Implement with repository/cache
    // For now, this would need a separate service or repository method
    try {
      // availableUsers = await _repository.getAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }
}