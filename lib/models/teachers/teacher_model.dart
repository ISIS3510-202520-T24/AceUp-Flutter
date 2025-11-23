import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/office_hour_model.dart';

class Teacher {
  final String id;
  final String name;
  final String? position;
  final String? department;
  final String? affiliation;
  final String? email;
  final String? phone;
  final String? webPage;
  final List<OfficeHour> officeHours;
  final DateTime createdAt;
  final DateTime updatedAt;

  Teacher({
    required this.id,
    required this.name,
    this.position,
    this.department,
    this.affiliation,
    this.email,
    this.phone,
    this.webPage,
    this.officeHours = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Teacher(
      id: doc.id,
      name: data['name'] ?? '',
      position: data['position'],
      department: data['department'],
      affiliation: data['affiliation'],
      email: data['email'],
      phone: data['phone'],
      webPage: data['webPage'],
      officeHours: (data['officeHours'] as List<dynamic>?)
              ?.map((e) => OfficeHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'],
      department: json['department'],
      affiliation: json['affiliation'],
      email: json['email'],
      phone: json['phone'],
      webPage: json['webPage'],
      officeHours: (json['officeHours'] as List<dynamic>?)
              ?.map((e) => OfficeHour.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      if (position != null) 'position': position,
      if (department != null) 'department': department,
      if (affiliation != null) 'affiliation': affiliation,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (webPage != null) 'webPage': webPage,
      'officeHours': officeHours.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (position != null) 'position': position,
      if (department != null) 'department': department,
      if (affiliation != null) 'affiliation': affiliation,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (webPage != null) 'webPage': webPage,
      'officeHours': officeHours.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Teacher copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    String? affiliation,
    String? email,
    String? phone,
    String? webPage,
    List<OfficeHour>? officeHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      affiliation: affiliation ?? this.affiliation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      webPage: webPage ?? this.webPage,
      officeHours: officeHours ?? this.officeHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display title (name + position if available)
  String get displayTitle {
    if (position != null && position!.isNotEmpty) {
      return '$name - $position';
    }
    return name;
  }

  @override
  String toString() {
    return 'Teacher(id: $id, name: $name, email: $email)';
  }
}