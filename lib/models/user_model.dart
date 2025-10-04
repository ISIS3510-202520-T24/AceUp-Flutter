// lib/features/groups/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nick;
  final String email;

  AppUser({required this.uid, required this.nick, required this.email});

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id, // El ID del documento es el UID del usuario
      nick: data['nick'] ?? 'No Nickname',
      email: data['email'] ?? 'No Email',
    );
  }
}