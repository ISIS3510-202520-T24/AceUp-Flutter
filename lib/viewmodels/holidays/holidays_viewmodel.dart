import 'dart:developer' as console;

import 'package:flutter/material.dart';
import '../../models/holidays/holiday_model.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/auth/auth_service.dart';
import '../../core/constants/enums.dart';

class HolidaysViewModel extends ChangeNotifier {
  final HolidayRepository _holidayRepository;
  final SettingsRepository _settingsRepository;
  final AuthService _authService = AuthService();

  List<Holiday> _holidays = [];
  List<Holiday> get holidays => _holidays;

  ViewStateWithSuccess _state = ViewStateWithSuccess.idle;
  ViewStateWithSuccess get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _countryCode = 'CO';
  String get countryCode => _countryCode;

  HolidaysViewModel({
    required HolidayRepository holidayRepository,
    required SettingsRepository settingsRepository,
  })  : _holidayRepository = holidayRepository,
        _settingsRepository = settingsRepository {
    // Automatically load holidays when ViewModel is created
    loadHolidays();
  }

  /// Load holidays from local database (offline-first)
  /// If no API holidays found, fetch from API
  Future<void> loadHolidays() async {
    _setState(ViewStateWithSuccess.loading);
    _errorMessage = null;

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _setState(ViewStateWithSuccess.error);
      notifyListeners();
      return;
    }

    try {
      // Get country code from settings
      final settings = await _settingsRepository.getOrCreateSettings(userId);
      _countryCode = settings.holidayCountry;

      // Load holidays from local database (both API and user-created)
      _holidays = await _holidayRepository.getHolidaysForUser(userId);

      // If no API holidays found, fetch from API
      final apiHolidays = _holidays.where((h) => h.isFromApi).toList();
      if (apiHolidays.isEmpty) {
        print('📥 No API holidays found locally, fetching from API...');
        await fetchApiHolidays();
      } else {
        _setState(ViewStateWithSuccess.success);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewStateWithSuccess.error);
      console.log('Error loading holidays: $e');
    }
  }

  /// Fetch API holidays and save to repository
  Future<void> fetchApiHolidays() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _setState(ViewStateWithSuccess.error);
      notifyListeners();
      return;
    }

    try {
      // Get country code from settings
      final settings = await _settingsRepository.getOrCreateSettings(userId);
      _countryCode = settings.holidayCountry;

      // Fetch and save API holidays
      await _holidayRepository.fetchAndSaveApiHolidays(userId, _countryCode);

      // Reload all holidays from database
      _holidays = await _holidayRepository.getHolidaysForUser(userId);
      _setState(ViewStateWithSuccess.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewStateWithSuccess.error);
      console.log('Error fetching API holidays: $e');
    }
  }

  /// Refreshes the holidays list by fetching from API
  Future<void> refreshHolidays() async {
    _setState(ViewStateWithSuccess.loading);
    await fetchApiHolidays();
  }

  /// Gets holidays grouped by year
  Map<int, List<Holiday>> getHolidaysByYear() {
    final Map<int, List<Holiday>> grouped = {};

    for (var holiday in _holidays) {
      final year = holiday.startDate.year;
      if (!grouped.containsKey(year)) {
        grouped[year] = [];
      }
      grouped[year]!.add(holiday);
    }

    return grouped;
  }

  /// Gets upcoming holidays (from today onwards)
  List<Holiday> getUpcomingHolidays() {
    final now = DateTime.now();
    return _holidays
        .where((h) => h.startDate.isAfter(now) || _isSameDay(h.startDate, now))
        .toList();
  }

  /// Gets past holidays
  List<Holiday> getPastHolidays() {
    final now = DateTime.now();
    return _holidays
        .where((h) => h.endDate.isBefore(now) && !_isSameDay(h.endDate, now))
        .toList();
  }

  /// Checks if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if date is in a holiday period
  bool _isDateInHoliday(DateTime date) {
    for (var holiday in _holidays) {
      if (!date.isBefore(holiday.startDate) && !date.isAfter(holiday.endDate)) {
        return true;
      }
    }
    return false;
  }

  /// Gets the count of holidays for a specific year
  int getHolidayCountForYear(int year) {
    return _holidays.where((h) => h.startDate.year == year).length;
  }

  /// Private method to update state and notify listeners
  void _setState(ViewStateWithSuccess newState) {
    _state = newState;
    notifyListeners();
  }

  /// Check if a specific date is a holiday
  bool isHoliday(DateTime date) {
    return _holidays.any((h) => _isDateInHoliday(date));
  }

  /// Get holiday for a specific date (if exists)
  Holiday? getHolidayForDate(DateTime date) {
    try {
      return _holidays.firstWhere((h) => _isDateInHoliday(date));
    } catch (e) {
      return null;
    }
  }

  /// Delete a user-created holiday
  Future<void> deleteHoliday(Holiday holiday) async {
    // Only allow deleting user-created holidays
    if (!holiday.isUserCreated) {
      _errorMessage = 'Cannot delete API holidays';
      _setState(ViewStateWithSuccess.error);
      notifyListeners();
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not logged in';
      _setState(ViewStateWithSuccess.error);
      notifyListeners();
      return;
    }

    try {
      await _holidayRepository.deleteHoliday(holiday.id, userId);
      // Reload from database instead of fetching from API
      await loadHolidays();
    } catch (e) {
      _errorMessage = 'Failed to delete holiday: $e';
      _setState(ViewStateWithSuccess.error);
      notifyListeners();
    }
  }
}