import 'package:cloud_firestore/cloud_firestore.dart';

class Term {
  final String id;
  final String userId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Term({
    required this.id,
    required this.userId,
    required this.name,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Term.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Term(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Term copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Term(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}