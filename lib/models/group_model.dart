import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;
  final List<String> members;

  Group({required this.id, required this.name, required this.members});

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Group',
      members: List<String>.from(data['members'] ?? []),
    );
  }
}
