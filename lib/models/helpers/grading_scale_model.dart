import 'dart:convert';
import '../../core/constants/enums.dart';

class GradingScale {
  final GradingScaleType type;
  final List<LetterGrade>? letterGrades;
  final PointsConfig? pointsConfig;

  GradingScale({
    required this.type,
    this.letterGrades,
    this.pointsConfig,
  });

  factory GradingScale.fromJson(Map<String, dynamic> json) {
    return GradingScale(
      type: GradingScaleType.fromString(json['type'] ?? 'percentage'),
      letterGrades: (json['letterGrades'] as List<dynamic>?)
          ?.map((e) => LetterGrade.fromJson(e as Map<String, dynamic>))
          .toList(),
      pointsConfig: json['pointsConfig'] != null
          ? PointsConfig.fromJson(json['pointsConfig'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      if (letterGrades != null)
        'letterGrades': letterGrades!.map((e) => e.toJson()).toList(),
      if (pointsConfig != null) 'pointsConfig': pointsConfig!.toJson(),
    };
  }

  static GradingScale fromJsonString(String jsonString) {
    if (jsonString.isEmpty) {
      return GradingScale(type: GradingScaleType.percentage);
    }
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return GradingScale.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Default grading scale
  factory GradingScale.defaultScale() {
    return GradingScale(type: GradingScaleType.percentage);
  }

  GradingScale copyWith({
    GradingScaleType? type,
    List<LetterGrade>? letterGrades,
    PointsConfig? pointsConfig,
  }) {
    return GradingScale(
      type: type ?? this.type,
      letterGrades: letterGrades ?? this.letterGrades,
      pointsConfig: pointsConfig ?? this.pointsConfig,
    );
  }
}

class LetterGrade {
  final String letter;
  final double minPercentage;
  final double maxPercentage;
  final double gpaValue;

  LetterGrade({
    required this.letter,
    required this.minPercentage,
    required this.maxPercentage,
    required this.gpaValue,
  });

  factory LetterGrade.fromJson(Map<String, dynamic> json) {
    return LetterGrade(
      letter: json['letter'] ?? '',
      minPercentage: (json['minPercentage'] ?? 0).toDouble(),
      maxPercentage: (json['maxPercentage'] ?? 100).toDouble(),
      gpaValue: (json['gpaValue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'minPercentage': minPercentage,
      'maxPercentage': maxPercentage,
      'gpaValue': gpaValue,
    };
  }
}

class PointsConfig {
  final double minPoints;
  final double maxPoints;

  PointsConfig({
    required this.minPoints,
    required this.maxPoints,
  });

  factory PointsConfig.fromJson(Map<String, dynamic> json) {
    return PointsConfig(
      minPoints: (json['minPoints'] ?? 0).toDouble(),
      maxPoints: (json['maxPoints'] ?? 100).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minPoints': minPoints,
      'maxPoints': maxPoints,
    };
  }
}