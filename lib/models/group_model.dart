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
    
    // Handle both List and String formats for members field
    List<String> members = [];
    final membersData = data['members'];
    if (membersData is List) {
      members = List<String>.from(membersData);
    } else if (membersData is String) {
      // Handle comma-separated string format
      members = membersData.split(',').where((s) => s.isNotEmpty).toList();
    }
    
    return Group(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Group',
      memberUids: members,
    );
  }
}