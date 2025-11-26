import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/weight_model.dart';

class Subject {
  final String id;
  final String name;
  final String color; // Hex color code
  final double credits;
  final double? finalGrade;
  final bool useFinalGradeOverride;
  final List<Weight> weights;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Navigation field (not persisted, populated from document path)
  final String? termId;

  Subject({
    required this.id,
    required this.name,
    required this.color,
    required this.credits,
    this.finalGrade,
    this.useFinalGradeOverride = false,
    this.weights = const [],
    required this.createdAt,
    required this.updatedAt,
    this.termId,
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Extract termId from document reference path
    // Path format: users/{userId}/terms/{termId}/subjects/{subjectId}
    String? termId;
    try {
      final pathSegments = doc.reference.path.split('/');
      if (pathSegments.length >= 6) {
        termId = pathSegments[3]; // terms/{termId}
      }
    } catch (e) {
      print('Warning: Could not extract termId from path: ${doc.reference.path}');
    }

    return Subject(
      id: doc.id,
      name: data['name'] ?? '',
      color: data['color'] ?? '#6B7280',
      credits: (data['credits'] ?? 0).toDouble(),
      finalGrade: data['finalGrade']?.toDouble(),
      useFinalGradeOverride: data['useFinalGradeOverride'] ?? false,
      weights: (data['weights'] as List<dynamic>?)
              ?.map((e) => Weight.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      termId: termId,
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#6B7280',
      credits: (json['credits'] ?? 0).toDouble(),
      finalGrade: json['finalGrade']?.toDouble(),
      useFinalGradeOverride: json['useFinalGradeOverride'] ?? false,
      weights: (json['weights'] as List<dynamic>?)
              ?.map((e) => Weight.fromJson(e as Map<String, dynamic>))
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
      'color': color,
      'credits': credits,
      if (finalGrade != null) 'finalGrade': finalGrade,
      'useFinalGradeOverride': useFinalGradeOverride,
      'weights': weights.map((e) => e.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'credits': credits,
      if (finalGrade != null) 'finalGrade': finalGrade,
      'useFinalGradeOverride': useFinalGradeOverride,
      'weights': weights.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? color,
    double? credits,
    double? finalGrade,
    bool? useFinalGradeOverride,
    List<Weight>? weights,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? termId,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      credits: credits ?? this.credits,
      finalGrade: finalGrade ?? this.finalGrade,
      useFinalGradeOverride: useFinalGradeOverride ?? this.useFinalGradeOverride,
      weights: weights ?? this.weights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      termId: termId ?? this.termId,
    );
  }

  /// Get total weight percentage (should be 100)
  double get totalWeightPercentage {
    return weights.fold(0.0, (sum, w) => sum + w.percentage);
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, credits: $credits)';
  }
}