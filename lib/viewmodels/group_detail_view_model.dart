// lib/features/groups/viewmodels/group_detail_view_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/group_service.dart';
import 'shared_view_model.dart';

class GroupDetailViewModel extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  final String groupId;

  List<Event> _allEvents = []; // Lista privada con TODOS los eventos del grupo
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  GroupDetailViewModel({required this.groupId}) {
    fetchEvents();
  }

  void _setState(ViewState viewState) {
    _state = viewState;
    notifyListeners();
  }

  /// Filtra la lista principal de eventos y devuelve solo los de una fecha específica.
  List<Event> getEventsForDay(DateTime selectedDate) {
    return _allEvents.where((event) {
      final eventDate = event.startTime.toDate();
      return eventDate.year == selectedDate.year &&
             eventDate.month == selectedDate.month &&
             eventDate.day == selectedDate.day;
    }).toList();
  }

  Future<void> fetchEvents() async {
    _setState(ViewState.loading);
    try {
      _allEvents = await _groupService.getEventsForGroup(groupId);
      _setState(ViewState.idle);
    } catch (e) {
      _setState(ViewState.error);
    }
  }
  
  Future<void> addEvent(String title, DateTime startTime, DateTime endTime) async { 
    await _groupService.addEvent(
      groupId, 
      title, 
      Timestamp.fromDate(startTime), 
      Timestamp.fromDate(endTime)
    );
    await fetchEvents();
  }

  Future<void> updateEvent(String eventId, String title, DateTime startTime, DateTime endTime) async {
    await _groupService.updateEvent(
      groupId, 
      eventId, 
      title, 
      Timestamp.fromDate(startTime), 
      Timestamp.fromDate(endTime)
    );
    await fetchEvents();
  }
  
  Future<void> deleteEvent(String eventId) async {
    _allEvents.removeWhere((event) => event.id == eventId);
    notifyListeners();
    try {
      await _groupService.deleteEvent(groupId, eventId);
    } catch (e) {
      await fetchEvents();
    }
  }
}