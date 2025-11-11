import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // Importa el modelo de usuario

class Group {
  final String id;
  final String name;
  final List<String> memberUids; // Mantenemos la lista de UIDs
  final String? imageUrl; // URL de la imagen personalizada del grupo (opcional)
  
  // Nueva lista para guardar los objetos AppUser completos
  List<AppUser> members = []; 

  Group({
    required this.id, 
    required this.name, 
    required this.memberUids,
    this.imageUrl, // Opcional
  });

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle both List and String formats for members field
    List<String> members = [];
    final membersData = data['members'];
    if (membersData is List) {
      // Convert each element to String explicitly
      members = membersData.map((e) => e.toString()).toList();
    } else if (membersData is String) {
      // Handle comma-separated string format
      members = membersData.split(',').where((s) => s.isNotEmpty).toList();
    }
    
    return Group(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Group',
      memberUids: members,
      imageUrl: data['imageUrl'], // Cargar la URL de la imagen si existe
    );
  }
}