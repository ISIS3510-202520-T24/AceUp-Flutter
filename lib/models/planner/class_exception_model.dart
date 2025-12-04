import 'package:cloud_firestore/cloud_firestore.dart';

class ClassException {
  final String id;
  final String classTemplateId;
  final DateTime date;
  final bool isCancelled;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassException({
    required this.id,
    required this.classTemplateId,
    required this.date,
    this.isCancelled = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassException.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClassException(
      id: doc.id,
      classTemplateId: data['classTemplateId'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCancelled: data['isCancelled'] ?? false,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ClassException.fromJson(Map<String, dynamic> json) {
    return ClassException(
      id: json['id'] ?? '',
      classTemplateId: json['classTemplateId'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      isCancelled: json['isCancelled'] ?? false,
      notes: json['notes'],
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
      'classTemplateId': classTemplateId,
      'date': Timestamp.fromDate(date),
      'isCancelled': isCancelled,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classTemplateId': classTemplateId,
      'date': date.toIso8601String(),
      'isCancelled': isCancelled,
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ClassException copyWith({
    String? id,
    String? classTemplateId,
    DateTime? date,
    bool? isCancelled,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassException(
      id: id ?? this.id,
      classTemplateId: classTemplateId ?? this.classTemplateId,
      date: date ?? this.date,
      isCancelled: isCancelled ?? this.isCancelled,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ClassException(id: $id, classTemplateId: $classTemplateId, date: $date, isCancelled: $isCancelled)';
  }
}