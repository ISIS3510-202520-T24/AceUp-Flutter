import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // Importa el modelo de usuario

class Group {
  final String id;
  final String name;
  final List<String> memberUids; // Mantenemos la lista de UIDs
  
  // Nueva lista para guardar los objetos AppUser completos
  List<AppUser> members = []; 

  Group({required this.id, required this.name, required this.memberUids});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Group',
      memberUids: List<String>.from(data['members'] ?? []),
    );
  }
}