import 'dart:convert';

class TimeSlot {
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final List<String> availableMembers; // User IDs
  final int memberCount;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.availableMembers,
    required this.memberCount,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    final members = (json['availableMembers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return TimeSlot(
      startTime: json['startTime'] ?? '00:00',
      endTime: json['endTime'] ?? '00:00',
      availableMembers: members,
      memberCount: json['memberCount'] ?? members.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'availableMembers': availableMembers,
      'memberCount': memberCount,
    };
  }

  TimeSlot copyWith({
    String? startTime,
    String? endTime,
    List<String>? availableMembers,
    int? memberCount,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      availableMembers: availableMembers ?? this.availableMembers,
      memberCount: memberCount ?? this.memberCount,
    );
  }
}

class DailySlots {
  final List<TimeSlot> monday;
  final List<TimeSlot> tuesday;
  final List<TimeSlot> wednesday;
  final List<TimeSlot> thursday;
  final List<TimeSlot> friday;
  final List<TimeSlot> saturday;
  final List<TimeSlot> sunday;

  DailySlots({
    this.monday = const [],
    this.tuesday = const [],
    this.wednesday = const [],
    this.thursday = const [],
    this.friday = const [],
    this.saturday = const [],
    this.sunday = const [],
  });

  factory DailySlots.fromJson(Map<String, dynamic> json) {
    return DailySlots(
      monday: _parseSlots(json['monday']),
      tuesday: _parseSlots(json['tuesday']),
      wednesday: _parseSlots(json['wednesday']),
      thursday: _parseSlots(json['thursday']),
      friday: _parseSlots(json['friday']),
      saturday: _parseSlots(json['saturday']),
      sunday: _parseSlots(json['sunday']),
    );
  }

  static List<TimeSlot> _parseSlots(dynamic data) {
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday.map((e) => e.toJson()).toList(),
      'tuesday': tuesday.map((e) => e.toJson()).toList(),
      'wednesday': wednesday.map((e) => e.toJson()).toList(),
      'thursday': thursday.map((e) => e.toJson()).toList(),
      'friday': friday.map((e) => e.toJson()).toList(),
      'saturday': saturday.map((e) => e.toJson()).toList(),
      'sunday': sunday.map((e) => e.toJson()).toList(),
    };
  }

  static DailySlots fromJsonString(String jsonString) {
    if (jsonString.isEmpty) return DailySlots();
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return DailySlots.fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  List<TimeSlot> getSlotsForDay(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return sunday;
      case 1:
        return monday;
      case 2:
        return tuesday;
      case 3:
        return wednesday;
      case 4:
        return thursday;
      case 5:
        return friday;
      case 6:
        return saturday;
      default:
        return [];
    }
  }
}