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

// ==================== VIEW STATES ====================

/// Generic view state for screens that only need basic states
enum ViewState {
  idle,
  loading,
  error;

  String get value => name;

  bool get isIdle => this == ViewState.idle;
  bool get isLoading => this == ViewState.loading;
  bool get isError => this == ViewState.error;
}

/// View state for screens with success state (e.g., after saving)
enum ViewStateWithSuccess {
  idle,
  loading,
  success,
  error;

  String get value => name;

  bool get isIdle => this == ViewStateWithSuccess.idle;
  bool get isLoading => this == ViewStateWithSuccess.loading;
  bool get isSuccess => this == ViewStateWithSuccess.success;
  bool get isError => this == ViewStateWithSuccess.error;
}

/// View state for edit/form screens with saving state
enum EditViewState {
  idle,
  loading,
  saving,
  error;

  String get value => name;

  bool get isIdle => this == EditViewState.idle;
  bool get isLoading => this == EditViewState.loading;
  bool get isSaving => this == EditViewState.saving;
  bool get isError => this == EditViewState.error;
}

/// View state for screens with offline capability
enum OfflineViewState {
  idle,
  loading,
  success,
  error,
  offline;

  String get value => name;

  bool get isIdle => this == OfflineViewState.idle;
  bool get isLoading => this == OfflineViewState.loading;
  bool get isSuccess => this == OfflineViewState.success;
  bool get isError => this == OfflineViewState.error;
  bool get isOffline => this == OfflineViewState.offline;
}

/// View state for edit screens with image upload
enum EditViewStateWithUpload {
  idle,
  loading,
  saving,
  uploadingImage,
  error;

  String get value => name;

  bool get isIdle => this == EditViewStateWithUpload.idle;
  bool get isLoading => this == EditViewStateWithUpload.loading;
  bool get isSaving => this == EditViewStateWithUpload.saving;
  bool get isUploadingImage => this == EditViewStateWithUpload.uploadingImage;
  bool get isError => this == EditViewStateWithUpload.error;
}