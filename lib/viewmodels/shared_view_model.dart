// lib/features/groups/viewmodels/shared_view_model.dart

import 'dart:developer' as console;

import 'package:flutter/material.dart';

import '../models/group_model.dart';
import '../services/group_service.dart';
import '../models/user_model.dart';

// El enum de estado que usan ambos ViewModels
enum ViewState { idle, loading, error }

class SharedViewModel extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  List<AppUser> availableUsers = []; // Nueva lista para el selector
  
  List<Group> groups = [];
  
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  SharedViewModel() {
    fetchGroups();
    fetchAllUsers();
  }

  // Metodo privado para cambiar el estado y notificar a la UI
  void _setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  // --- MÉTODOS EXISTENTES ---

  Future<void> fetchGroups() async {
    _setState(ViewState.loading);
    try {
      groups = await _groupService.getGroups();

      if (availableUsers.isEmpty) {
        await fetchAllUsers();
      }

      for (var group in groups) {
        group.members = availableUsers
            .where((user) => group.memberUids.contains(user.uid))
            .toList();
      }

      _setState(ViewState.idle);
    } catch (e) {
      console.log('Error fetching groups: $e');
      _setState(ViewState.error);
    }
  }

  // --- NUEVOS MÉTODOS CRUD QUE FALTABAN ---

  /// Añade un nuevo grupo a Firestore y luego actualiza la lista local.
  Future<void> addGroup(String name, List<String> members) async {
    try {
      await _groupService.addGroup(name, members);
      await fetchGroups(); // Volvemos a cargar para obtener el nuevo grupo con su ID de Firebase
    } catch (e) {
      console.log('Error adding group: $e');
      // Opcional: podrías establecer un estado de error aquí
    }
  }

  /// Actualiza un grupo existente en Firestore y luego actualiza la lista local.
  Future<void> updateGroup(String id, String name, List<String> members) async {
    try {
      await _groupService.updateGroup(id, name, members);
      await fetchGroups(); // Volvemos a cargar para reflejar los cambios
    } catch (e) {
      console.log('Error updating group: $e');
    }
  }

  /// Elimina un grupo. Usa una actualización "optimista" para la UI.
  Future<void> deleteGroup(String id) async {
    // 1. Actualización optimista: Borra el grupo de la lista local inmediatamente
    //    para que la UI responda al instante.
    final index = groups.indexWhere((group) => group.id == id);
    if (index == -1) return; // No se encontró el grupo
    
    final groupToDelete = groups.removeAt(index);
    notifyListeners();

    // 2. Llama al servicio para borrar el grupo de la base de datos.
    try {
      await _groupService.deleteGroup(id);
    } catch (e) {
      console.log('Error deleting group: $e');
      // 3. Si la eliminación falla, revierte el cambio en la UI para mantener la consistencia.
      groups.insert(index, groupToDelete);
      notifyListeners();
    }
  }

    Future<void> fetchAllUsers() async {
    try {
      availableUsers = await _groupService.getAllUsers();
      notifyListeners();
    } catch (e) {
      print('Error fetching users: $e');
    }
  }
}