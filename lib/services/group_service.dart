import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/event_model.dart';

class GroupService {
  final CollectionReference _groupsCollection = FirebaseFirestore.instance.collection('groups');

  // --- CRUD para Grupos ---

  Future<void> addGroup(String name, List<String> members) {
    return _groupsCollection.add({
      'name': name,
      'members': members,
    });
  }

  Future<void> updateGroup(String id, String name, List<String> members) {
    return _groupsCollection.doc(id).update({
      'name': name,
      'members': members,
    });
  }

  Future<void> deleteGroup(String id) {
    // Nota: Para una app en producción, deberías manejar la eliminación de subcolecciones aquí
    // usando una Cloud Function, ya que borrar un documento no borra sus subcolecciones.
    return _groupsCollection.doc(id).delete();
  }

  Future<List<Group>> getGroups() async {
    QuerySnapshot snapshot = await _groupsCollection.get();
    return snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList();
  }

  // --- CRUD para Eventos ---

  Future<void> addEvent(String groupId, String title, Timestamp startTime, Timestamp endTime) {
    return _groupsCollection.doc(groupId).collection('events').add({
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<void> updateEvent(String groupId, String eventId, String title, Timestamp startTime, Timestamp endTime) {
    return _groupsCollection.doc(groupId).collection('events').doc(eventId).update({
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<void> deleteEvent(String groupId, String eventId) {
    return _groupsCollection.doc(groupId).collection('events').doc(eventId).delete();
  }

  Future<List<Event>> getEventsForGroup(String groupId) async {
    QuerySnapshot snapshot = await _groupsCollection.doc(groupId).collection('events').orderBy('startTime').get();
    return snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
  }
}