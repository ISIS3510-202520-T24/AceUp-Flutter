/// Priority levels for assignments (lowercase as per JSON schema)
enum Priority {
  low,
  medium,
  high;

  String get value => name;

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Priority.medium,
    );
  }
}

/// Recurrence unit types for class templates
enum RecurrenceUnit {
  weeks,
  days,
  workingDays,
  oddDays,
  evenDays,
  oddWorkingDays,
  evenWorkingDays;

  String get value => name;

  static RecurrenceUnit fromString(String value) {
    return RecurrenceUnit.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurrenceUnit.weeks,
    );
  }
}

/// Grading scale types
enum GradingScaleType {
  percentage,
  letter,
  points;

  String get value => name;

  static GradingScaleType fromString(String value) {
    return GradingScaleType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => GradingScaleType.percentage,
    );
  }
}

/// Holiday source types
enum HolidaySource {
  user,
  api;

  String get value => name;

  static HolidaySource fromString(String value) {
    return HolidaySource.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => HolidaySource.user,
    );
  }
}

/// Sync status for offline-first operations
enum SyncStatus {
  synced,
  pending,
  failed;

  String get value => name;

  static SyncStatus fromString(String value) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncStatus.synced,
    );
  }
}

/// Sync operation types
enum SyncOperation {
  create,
  update,
  delete;

  String get value => name;

  static SyncOperation fromString(String value) {
    return SyncOperation.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => SyncOperation.create,
    );
  }
}