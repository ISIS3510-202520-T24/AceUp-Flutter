import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String name;
  final DateTime date;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String? weightId;
  final String? building;
  final String? room;
  final String? teacherId;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isGraded;
  final double? grade;
  final DateTime createdAt;
  final DateTime updatedAt;

  Exam({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.weightId,
    this.building,
    this.room,
    this.teacherId,
    this.isCompleted = false,
    this.completedAt,
    this.isGraded = false,
    this.grade,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Exam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Exam(
      id: doc.id,
      name: data['name'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: data['startTime'] ?? '09:00',
      endTime: data['endTime'] ?? '10:00',
      weightId: data['weightId'],
      building: data['building'],
      room: data['room'],
      teacherId: data['teacherId'],
      isCompleted: data['isCompleted'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      isGraded: data['isGraded'] ?? false,
      grade: data['grade']?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '10:00',
      weightId: json['weightId'],
      building: json['building'],
      room: json['room'],
      teacherId: json['teacherId'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      isGraded: json['isGraded'] ?? false,
      grade: json['grade']?.toDouble(),
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
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      if (weightId != null) 'weightId': weightId,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacherId': teacherId,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'isGraded': isGraded,
      if (grade != null) 'grade': grade,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      if (weightId != null) 'weightId': weightId,
      if (building != null) 'building': building,
      if (room != null) 'room': room,
      if (teacherId != null) 'teacherId': teacherId,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'isGraded': isGraded,
      if (grade != null) 'grade': grade,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Exam copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? weightId,
    String? building,
    String? room,
    String? teacherId,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isGraded,
    double? grade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weightId: weightId ?? this.weightId,
      building: building ?? this.building,
      room: room ?? this.room,
      teacherId: teacherId ?? this.teacherId,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isGraded: isGraded ?? this.isGraded,
      grade: grade ?? this.grade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  /// Check if exam is today
  bool isToday(DateTime today) {
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Days until exam (negative if past)
  int get daysUntil {
    final now = DateTime.now();
    final examOnly = DateTime(date.year, date.month, date.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    return examOnly.difference(nowOnly).inDays;
  }

  @override
  String toString() {
    return 'Exam(id: $id, name: $name, date: $date, isCompleted: $isCompleted)';
  }
}