import 'package:cloud_firestore/cloud_firestore.dart';

/// Holiday model matching Firestore schema
/// Holidays can be user-created or from API
class Holiday {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String source; // 'user' or 'api'
  final DateTime createdAt;
  final DateTime updatedAt;

  Holiday({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory Holiday.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Holiday(
      id: doc.id,
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      source: data['source'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from JSON (for local storage or API response conversion)
  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: json['startDate'] is Timestamp
          ? (json['startDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: json['endDate'] is Timestamp
          ? (json['endDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now(),
      source: json['source'] ?? 'user',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Create from API response (converts API format to our schema)
  factory Holiday.fromApiResponse(Map<String, dynamic> apiJson, String id) {
    // Extract only what we need from the API response
    final dateString = apiJson['date'] as String;
    final date = DateTime.parse(dateString);
    final name = (apiJson['localName'] as String?)?.isNotEmpty == true
        ? apiJson['localName'] as String
        : apiJson['name'] as String;

    final now = DateTime.now();
    return Holiday(
      id: id,
      name: name,
      startDate: date,
      endDate: date, // Single day holiday
      source: 'api',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Copy with new values
  Holiday copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if holiday is user-created
  bool get isUserCreated => source == 'user';

  /// Check if holiday is from API
  bool get isFromApi => source == 'api';

  /// Check if this is a multi-day holiday
  bool get isMultiDay {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !start.isAtSameMomentAs(end);
  }

  /// Get duration in days
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// Helper method to format date for display (e.g., "Jan 1")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (isMultiDay) {
      return '${months[startDate.month - 1]} ${startDate.day} - ${months[endDate.month - 1]} ${endDate.day}';
    }
    return '${months[startDate.month - 1]} ${startDate.day}';
  }

  /// Helper method to get full date format (e.g., "January 1, 2025")
  String get fullDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (isMultiDay) {
      return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year} - ${months[endDate.month - 1]} ${endDate.day}, ${endDate.year}';
    }
    return '${months[startDate.month - 1]} ${startDate.day}, ${startDate.year}';
  }

  /// Get weekday name for start date
  String get weekDay {
    const weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekDays[startDate.weekday - 1];
  }

  /// Check if a date falls within this holiday
  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return (dateOnly.isAtSameMomentAs(start) || dateOnly.isAfter(start)) &&
           (dateOnly.isAtSameMomentAs(end) || dateOnly.isBefore(end));
  }

  @override
  String toString() {
    return 'Holiday(id: $id, name: $name, startDate: $startDate, source: $source)';
  }
}