import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/time_slot_model.dart';

class WeeklyAvailability {
  final String id;
  final String weekIdentifier; // ISO week format: YYYY-Wnn
  final DateTime weekStartDate; // Monday of this week
  final DateTime weekEndDate; // Sunday of this week
  final DailySlots dailySlots;
  final DateTime calculatedAt;

  WeeklyAvailability({
    required this.id,
    required this.weekIdentifier,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.dailySlots,
    required this.calculatedAt,
  });

  factory WeeklyAvailability.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeeklyAvailability(
      id: doc.id,
      weekIdentifier: data['weekIdentifier'] ?? '',
      weekStartDate: (data['weekStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      weekEndDate: (data['weekEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dailySlots: data['dailySlots'] != null
          ? DailySlots.fromJson(data['dailySlots'] as Map<String, dynamic>)
          : DailySlots(),
      calculatedAt: (data['calculatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory WeeklyAvailability.fromJson(Map<String, dynamic> json) {
    return WeeklyAvailability(
      id: json['id'] ?? '',
      weekIdentifier: json['weekIdentifier'] ?? '',
      weekStartDate: json['weekStartDate'] is Timestamp
          ? (json['weekStartDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['weekStartDate']?.toString() ?? '') ?? DateTime.now(),
      weekEndDate: json['weekEndDate'] is Timestamp
          ? (json['weekEndDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['weekEndDate']?.toString() ?? '') ?? DateTime.now(),
      dailySlots: json['dailySlots'] != null
          ? DailySlots.fromJson(json['dailySlots'] as Map<String, dynamic>)
          : DailySlots(),
      calculatedAt: json['calculatedAt'] is Timestamp
          ? (json['calculatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['calculatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'weekIdentifier': weekIdentifier,
      'weekStartDate': Timestamp.fromDate(weekStartDate),
      'weekEndDate': Timestamp.fromDate(weekEndDate),
      'dailySlots': dailySlots.toJson(),
      'calculatedAt': Timestamp.fromDate(calculatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekIdentifier': weekIdentifier,
      'weekStartDate': weekStartDate.toIso8601String(),
      'weekEndDate': weekEndDate.toIso8601String(),
      'dailySlots': dailySlots.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  WeeklyAvailability copyWith({
    String? id,
    String? weekIdentifier,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    DailySlots? dailySlots,
    DateTime? calculatedAt,
  }) {
    return WeeklyAvailability(
      id: id ?? this.id,
      weekIdentifier: weekIdentifier ?? this.weekIdentifier,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      dailySlots: dailySlots ?? this.dailySlots,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// Generate week identifier from date (YYYY-Wnn format)
  static String generateWeekIdentifier(DateTime date) {
    // Get ISO week number
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }

  /// Get slots for a specific day
  List<TimeSlot> getSlotsForDay(int dayOfWeek) {
    return dailySlots.getSlotsForDay(dayOfWeek);
  }

  @override
  String toString() {
    return 'WeeklyAvailability(id: $id, weekIdentifier: $weekIdentifier)';
  }
}