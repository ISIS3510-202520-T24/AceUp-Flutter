import 'dart:convert';

class Alert {
  final String id;
  final int daysBeforeDue;
  final String time; // HH:mm format

  Alert({
    required this.id,
    required this.daysBeforeDue,
    required this.time,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? '',
      daysBeforeDue: json['daysBeforeDue'] ?? 0,
      time: json['time'] ?? '09:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daysBeforeDue': daysBeforeDue,
      'time': time,
    };
  }

  static List<Alert> fromJsonString(String jsonString) {
    if (jsonString.isEmpty || jsonString == '[]') return [];
    final List<dynamic> list = json.decode(jsonString);
    return list.map((e) => Alert.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String toJsonString(List<Alert> alerts) {
    return json.encode(alerts.map((e) => e.toJson()).toList());
  }

  Alert copyWith({
    String? id,
    int? daysBeforeDue,
    String? time,
  }) {
    return Alert(
      id: id ?? this.id,
      daysBeforeDue: daysBeforeDue ?? this.daysBeforeDue,
      time: time ?? this.time,
    );
  }
}