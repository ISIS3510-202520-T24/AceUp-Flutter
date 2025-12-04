import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';
import '../helpers/recurrence_model.dart';

class ClassTemplate {
  final String id;
  final String name;
  final String icon; // Icon identifier from preset assets
  final DateTime startDate;
  final DateTime endDate;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final Recurrence recurrence;
  final String? building;
  final String? room;
  final String? teacherId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Navigation fields (not persisted, populated from document path or joins)
  final String? termId;
  final String? subjectId;
  final String? subjectName;
  final String? subjectColor; // Hex color from subject

  ClassTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.recurrence,
    this.building,
    this.room,
    this.teacherId,
    required this.createdAt,
    required this.updatedAt,
    this.termId,
    this.subjectId,
    this.subjectName,
    this.subjectColor,
  });

  factory ClassTemplate.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String? termId;
    String? subjectId;
    try{
      final pathSegments = doc.reference.path.split('/');
      if (pathSegments.length >= 8) {
        termId = pathSegments[3]; // terms/{termId}
        subjectId = pathSegments[5]; // subjects/{subjectId}
      }
    } catch (e) {
      print('Warning: Could not extract parent IDs from path: ${doc.reference.path}');
    }

    return ClassTemplate(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'class_default',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '10:00',
      recurrence: data['recurrence'] != null
          ? Recurrence.fromJson(data['recurrence'] as Map<String, dynamic>)
          : Recurrence(interval: 1, unit: RecurrenceUnit.weeks),
      building: data['building'],
      room: data['room'],
      teacherId: data['teacherId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      termId: termId,
      subjectId: subjectId,
      subjectName: null,
    );
  }

  factory ClassTemplate.fromJson(Map<String, dynamic> json) {
    return ClassTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'class_default',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '10:00',
      recurrence: json['recurrence'] != null
          ? Recurrence.fromJson(json['recurrence'] as Map<String, dynamic>)
          : Recurrence(interval: 1, unit: RecurrenceUnit.weeks),
      building: json['building'],
      room: json['room'],
      teacherId: json['teacherId'],
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
      'icon': icon,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'startTime': startTime,
      'endTime': endTime,
      'recurrence': recurrence.toJson(),
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacherId': teacherId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'recurrence': recurrence.toJson(),
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacherId': teacherId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ClassTemplate copyWith({
    String? id,
    String? name,
    String? icon,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    Recurrence? recurrence,
    String? building,
    String? room,
    String? teacherId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? termId,
    String? subjectId,
    String? subjectName,
    String? subjectColor,
  }) {
    return ClassTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      recurrence: recurrence ?? this.recurrence,
      building: building ?? this.building,
      room: room ?? this.room,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectColor: subjectColor ?? this.subjectColor,
    );
  }

  /// Get location string
  String get location {
    if (building != null && room != null) {
      return '$building - $room';
    } else if (building != null) {
      return building!;
    } else if (room != null) {
      return room!;
    }
    return '';
  }

  @override
  String toString() {
    return 'ClassTemplate(id: $id, name: $name, startTime: $startTime, endTime: $endTime)';
  }
}
