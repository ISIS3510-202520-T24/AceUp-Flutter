import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/enums.dart';
import '../helpers/alert_model.dart';

class Assignment {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String? dueTime; // HH:mm format
  final String? weightId; // Reference to weight/subweight
  final Priority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isGraded;
  final double? grade;
  final List<Alert> alerts;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Navigation fields (not persisted, populated from document path or joins)
  final String? termId;
  final String? subjectId;
  final String? subjectName;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.dueTime,
    this.weightId,
    this.priority = Priority.medium,
    this.isCompleted = false,
    this.completedAt,
    this.isGraded = false,
    this.grade,
    this.alerts = const [],
    required this.createdAt,
    required this.updatedAt,
    this.termId,
    this.subjectId,
    this.subjectName,
  });

  factory Assignment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract parent IDs from document reference path
    // Path format: users/{userId}/terms/{termId}/subjects/{subjectId}/assignments/{assignmentId}
    String? termId;
    String? subjectId;
    try {
      final pathSegments = doc.reference.path.split('/');
      if (pathSegments.length >= 8) {
        termId = pathSegments[3]; // terms/{termId}
        subjectId = pathSegments[5]; // subjects/{subjectId}
      }
    } catch (e) {
      print('Warning: Could not extract parent IDs from path: ${doc.reference.path}');
    }

    return Assignment(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueTime: data['dueTime'],
      weightId: data['weightId'],
      priority: Priority.fromString(data['priority'] ?? 'medium'),
      isCompleted: data['isCompleted'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      isGraded: data['isGraded'] ?? false,
      grade: data['grade']?.toDouble(),
      alerts: (data['alerts'] as List<dynamic>?)
              ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      termId: termId,
      subjectId: subjectId,
      subjectName: null, // Must be populated separately via join
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] is Timestamp
          ? (json['dueDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['dueDate']?.toString() ?? '') ?? DateTime.now(),
      dueTime: json['dueTime'],
      weightId: json['weightId'],
      priority: Priority.fromString(json['priority'] ?? 'medium'),
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] is Timestamp
          ? (json['completedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['completedAt']?.toString() ?? ''),
      isGraded: json['isGraded'] ?? false,
      grade: json['grade']?.toDouble(),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => Alert.fromJson(e as Map<String, dynamic>))
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
      'title': title,
      if (description != null) 'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      if (dueTime != null) 'dueTime': dueTime,
      if (weightId != null) 'weightId': weightId,
      'priority': priority.value,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      'isGraded': isGraded,
      if (grade != null) 'grade': grade,
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'dueDate': dueDate.toIso8601String(),
      if (dueTime != null) 'dueTime': dueTime,
      if (weightId != null) 'weightId': weightId,
      'priority': priority.value,
      'isCompleted': isCompleted,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'isGraded': isGraded,
      if (grade != null) 'grade': grade,
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    String? weightId,
    Priority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool? isGraded,
    double? grade,
    List<Alert>? alerts,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? termId,
    String? subjectId,
    String? subjectName,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      weightId: weightId ?? this.weightId,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isGraded: isGraded ?? this.isGraded,
      grade: grade ?? this.grade,
      alerts: alerts ?? this.alerts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
    );
  }

  /// Check if assignment is due today
  bool isDueToday(DateTime today) {
    return dueDate.year == today.year &&
        dueDate.month == today.month &&
        dueDate.day == today.day;
  }

  /// Check if assignment is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// Days until due (negative if overdue)
  int get daysUntilDue {
    final now = DateTime.now();
    final dueOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final nowOnly = DateTime(now.year, now.month, now.day);
    return dueOnly.difference(nowOnly).inDays;
  }

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted)';
  }
}