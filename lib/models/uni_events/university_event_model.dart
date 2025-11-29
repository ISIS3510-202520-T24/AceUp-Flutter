import 'package:intl/src/intl/date_format.dart';

/// Model representing a university event from eventos.uniandes.edu.co
class UniversityEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startDateTime;
  final DateTime? endDateTime;
  final String? location;
  final String? imageUrl;
  final String? eventUrl;
  final String? category;
  
  // User customization fields (null if not added to calendar)
  final bool isAddedToCalendar;
  final String? userNotes;
  final String? userLocation;
  final DateTime? addedAt;  // When user added to calendar
  
  // Metadata
  final DateTime? cachedAt;  // For cache expiry

  UniversityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startDateTime,
    this.endDateTime,
    this.location,
    this.eventUrl,
    this.category,
    this.imageUrl,
    this.isAddedToCalendar = false,
    this.userNotes,
    this.userLocation,
    this.addedAt,
    this.cachedAt,
  });

  /// Get effective location (user override or original)
  String? get effectiveLocation => userLocation ?? location;

  /// Check if user has made customizations
  bool get hasCustomizations {
    return userNotes != null || 
           userLocation != null;
  }

  /// Create from JSON
  factory UniversityEvent.fromJson(Map<String, dynamic> json) {
    return UniversityEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: json['endDateTime'] != null
          ? DateTime.parse(json['endDateTime'] as String)
          : null,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
      eventUrl: json['eventUrl'] as String?,
      category: json['category'] as String?,
      isAddedToCalendar: json['isAddedToCalendar'] as bool? ?? false,
      userNotes: json['userNotes'] as String?,
      userLocation: json['userLocation'] as String?,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : null,
      cachedAt: json['cachedAt'] != null
          ? DateTime.parse(json['cachedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
      'eventUrl': eventUrl,
      'category': category,
      'isAddedToCalendar': isAddedToCalendar,
      'userNotes': userNotes,
      'userLocation': userLocation,
      'addedAt': addedAt?.toIso8601String(),
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  /// Copy with method for immutable updates
  UniversityEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? location,
    String? imageUrl,
    String? eventUrl,
    String? category,
    bool? isAddedToCalendar,
    String? userNotes,
    String? userLocation,
    DateTime? addedAt,
    DateTime? cachedAt,
  }) {
    return UniversityEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      eventUrl: eventUrl ?? this.eventUrl,
      category: category ?? this.category,
      isAddedToCalendar: isAddedToCalendar ?? this.isAddedToCalendar,
      userNotes: userNotes ?? this.userNotes,
      userLocation: userLocation ?? this.userLocation,
      addedAt: addedAt ?? this.addedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  /// Format date range for display using effective dates
  String getDateTimeRangeString() {
    final start = startDateTime;
    final end = endDateTime;

    if (end != null && start.day == end.day) {
      return _formatDateTime(start, end);
    } else if (end != null) {
      return '${_formatDateTime(start, null)}/n${_formatDateTime(end, null)}';
    }
    return _formatDateTime(start, null);
  }

  String _formatDateTime(DateTime date, DateTime? end) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final startTime = DateFormat('h:mm a').format(date);

    if (end != null) {
      final endTime = DateFormat('h:mm a').format(end);
      return '${months[date.month - 1]} ${date.day}, ${date.year}, $startTime - $endTime';
    }
    return '${months[date.month - 1]} ${date.day}, ${date.year}, $startTime';
  }

  /// Check if cache is still valid (within 24 hours)
  bool get isCacheValid {
    if (cachedAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(cachedAt!);
    return difference.inHours < 24;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversityEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}