import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int grade;
  final String priority; // "High", "Medium", "Low"
  final String status; // "Pending", "Completed"
  final int weight;
  final String subjectName;
  final String? termId;
  final String? subjectId;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.grade,
    required this.priority,
    required this.status,
    required this.weight,
    required this.subjectName,
    this.termId,
    this.subjectId,
  });

  factory Assignment.fromFirestore(
    DocumentSnapshot doc,
    String subjectName, {
    String? termId,
    String? subjectId,
  }) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Assignment(
      id: doc.id,
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      grade: data['grade'] ?? 0,
      priority: data['priority'] ?? 'Medium',
      status: data['status'] ?? 'Pending',
      weight: data['weight'] ?? 0,
      subjectName: subjectName,
      termId: termId,
      subjectId: subjectId,
    );
  }

  Assignment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? grade,
    String? priority,
    String? status,
    int? weight,
    String? subjectName,
    String? termId,
    String? subjectId,
  }) {
    return Assignment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      grade: grade ?? this.grade,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      weight: weight ?? this.weight,
      subjectName: subjectName ?? this.subjectName,
      termId: termId ?? this.termId,
      subjectId: subjectId ?? this.subjectId,
    );
  }

  bool get isPending => status == 'Pending';
  bool get isCompleted => status == 'Completed';

  bool isDueToday(DateTime today) {
    return dueDate.year == today.year &&
        dueDate.month == today.month &&
        dueDate.day == today.day;
  }
}