import 'dart:convert';
import '../../core/constants/enums.dart';

class Recurrence {
  final int interval; // 1-6
  final RecurrenceUnit unit;
  final List<int> selectedDays; // 0=Sunday, 6=Saturday (only for 'weeks' unit)

  Recurrence({
    required this.interval,
    required this.unit,
    this.selectedDays = const [],
  });

  factory Recurrence.fromJson(Map<String, dynamic> json) {
    return Recurrence(
      interval: json['interval'] ?? 1,
      unit: RecurrenceUnit.fromString(json['unit'] ?? 'weeks'),
      selectedDays: (json['selectedDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interval': interval,
      'unit': unit.value,
      'selectedDays': selectedDays,
    };
  }

  static Recurrence fromJsonString(String jsonString) {
    if (jsonString.isEmpty) {
      return Recurrence(interval: 1, unit: RecurrenceUnit.weeks);
    }
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Recurrence.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Recurrence copyWith({
    int? interval,
    RecurrenceUnit? unit,
    List<int>? selectedDays,
  }) {
    return Recurrence(
      interval: interval ?? this.interval,
      unit: unit ?? this.unit,
      selectedDays: selectedDays ?? this.selectedDays,
    );
  }
}