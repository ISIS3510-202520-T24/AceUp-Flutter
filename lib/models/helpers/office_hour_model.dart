import 'dart:convert';

class OfficeHour {
  final String id;
  final int dayOfWeek; // 0=Sunday, 6=Saturday
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final String? location;

  OfficeHour({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
  });

  factory OfficeHour.fromJson(Map<String, dynamic> json) {
    return OfficeHour(
      id: json['id'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 1,
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '10:00',
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      if (location != null) 'location': location,
    };
  }

  static List<OfficeHour> fromJsonString(String jsonString) {
    if (jsonString.isEmpty || jsonString == '[]') return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => OfficeHour.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonString(List<OfficeHour> officeHours) {
    return json.encode(officeHours.map((e) => e.toJson()).toList());
  }

  OfficeHour copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
  }) {
    return OfficeHour(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
    );
  }
}