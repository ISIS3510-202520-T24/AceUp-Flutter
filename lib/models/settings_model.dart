import 'package:cloud_firestore/cloud_firestore.dart';
import 'helpers/grading_scale_model.dart';

class Settings {
  final int defaultClassDuration; // In minutes
  final List<int> weekdays; // 0=Sunday, 6=Saturday
  final GradingScale gradingScale;
  final String holidayCountry; // ISO country code
  final DateTime updatedAt;

  Settings({
    this.defaultClassDuration = 60,
    this.weekdays = const [1, 2, 3, 4, 5], // Mon-Fri by default
    GradingScale? gradingScale,
    this.holidayCountry = 'CO',
    DateTime? updatedAt,
  })  : gradingScale = gradingScale ?? GradingScale.defaultScale(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Settings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Settings(
      defaultClassDuration: data['defaultClassDuration'] ?? 60,
      weekdays: (data['weekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5],
      gradingScale: data['gradingScale'] != null
          ? GradingScale.fromJson(data['gradingScale'] as Map<String, dynamic>)
          : GradingScale.defaultScale(),
      holidayCountry: data['holidayCountry'] ?? 'CO',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      defaultClassDuration: json['defaultClassDuration'] ?? 60,
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5],
      gradingScale: json['gradingScale'] != null
          ? GradingScale.fromJson(json['gradingScale'] as Map<String, dynamic>)
          : GradingScale.defaultScale(),
      holidayCountry: json['holidayCountry'] ?? 'CO',
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Create default settings
  factory Settings.defaults() {
    return Settings(
      defaultClassDuration: 60,
      weekdays: [1, 2, 3, 4, 5],
      gradingScale: GradingScale.defaultScale(),
      holidayCountry: 'CO',
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'defaultClassDuration': defaultClassDuration,
      'weekdays': weekdays,
      'gradingScale': gradingScale.toJson(),
      'holidayCountry': holidayCountry,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultClassDuration': defaultClassDuration,
      'weekdays': weekdays,
      'gradingScale': gradingScale.toJson(),
      'holidayCountry': holidayCountry,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Settings copyWith({
    int? defaultClassDuration,
    List<int>? weekdays,
    GradingScale? gradingScale,
    String? holidayCountry,
    DateTime? updatedAt,
  }) {
    return Settings(
      defaultClassDuration: defaultClassDuration ?? this.defaultClassDuration,
      weekdays: weekdays ?? this.weekdays,
      gradingScale: gradingScale ?? this.gradingScale,
      holidayCountry: holidayCountry ?? this.holidayCountry,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a day is a weekday (active school day)
  bool isActiveDay(int dayOfWeek) => weekdays.contains(dayOfWeek);

  /// Get day names for active weekdays
  List<String> get activeWeekdayNames {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays.map((d) => names[d]).toList();
  }

  @override
  String toString() {
    return 'Settings(defaultClassDuration: $defaultClassDuration, holidayCountry: $holidayCountry)';
  }
}