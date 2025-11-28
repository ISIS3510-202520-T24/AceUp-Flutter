import 'package:cloud_firestore/cloud_firestore.dart';

class Term {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Term({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Term.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Term(
      id: doc.id,
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Term copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Term(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if the term is currently active based on dates
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  @override
  String toString() {
    return 'Term(id: $id, name: $name, isActive: $isActive)';
  }
}