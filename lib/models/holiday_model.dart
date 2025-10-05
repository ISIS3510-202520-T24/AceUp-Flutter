class Holiday {
  final String name;
  final String localName;
  final DateTime date;
  final String countryCode;
  final bool fixed;
  final bool global;
  final List<String> types;
  final List<String>? counties;

  Holiday({
    required this.name,
    required this.localName,
    required this.date,
    required this.countryCode,
    required this.fixed,
    required this.global,
    required this.types,
    this.counties,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    // Parse date from YYYY-MM-DD format
    final dateString = json['date'] as String;
    final parsedDate = DateTime.parse(dateString);

    return Holiday(
      name: json['name'] as String? ?? '',
      localName: json['localName'] as String? ?? '',
      date: parsedDate,
      countryCode: json['countryCode'] as String? ?? '',
      fixed: json['fixed'] as bool? ?? false,
      global: json['global'] as bool? ?? true,
      types: json['types'] != null
          ? List<String>.from(json['types'] as List)
          : ['Public'],
      counties: json['counties'] != null
          ? List<String>.from(json['counties'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'localName': localName,
      'date': date.toIso8601String().split('T')[0],
      'countryCode': countryCode,
      'fixed': fixed,
      'global': global,
      'types': types,
      'counties': counties,
    };
  }

  // Helper method to format date for display (e.g., "Jan 1")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // Helper method to get full date format (e.g., "January 1, 2025")
  String get fullDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Helper to get display name (uses local name if available, otherwise default name)
  String get displayName {
    return localName.isNotEmpty ? localName : name;
  }

  // Get the type as a string for display
  String get typeString {
    return types.isEmpty ? 'Public' : types.first;
  }

  // Get weekday name
  String get weekDay {
    const weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekDays[date.weekday - 1];
  }

  // Check if this is a nationwide holiday
  bool get isNationwide {
    return global && (counties == null || counties!.isEmpty);
  }
}