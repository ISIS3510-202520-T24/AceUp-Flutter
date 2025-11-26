import 'dart:developer' as console;

import 'package:flutter/material.dart';
import '../../models/holidays/holiday_model.dart';
import '../../services/holidays/holiday_service.dart';

enum HolidayViewState { idle, loading, error, success }

class HolidaysViewModel extends ChangeNotifier {
  final HolidayService _holidayService = HolidayService();

  List<Holiday> _holidays = [];
  List<Holiday> get holidays => _holidays;

  HolidayViewState _state = HolidayViewState.idle;
  HolidayViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // TODO: Make this dynamic based on user preference
  final String _countryCode = 'CO';
  String get countryCode => _countryCode;

  HolidaysViewModel() {
    // Automatically fetch holidays when ViewModel is created
    fetchHolidays();
  }

  /// Fetches holidays for the current year and next year
  Future<void> fetchHolidays() async {
    _setState(HolidayViewState.loading);
    _errorMessage = null;

    try {
      _holidays = await _holidayService.getHolidaysForCurrentAndNextYear(_countryCode);
      _setState(HolidayViewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(HolidayViewState.error);
      console.log('Error fetching holidays: $e');
    }
  }

  /// Refreshes the holidays list
  Future<void> refreshHolidays() async {
    await fetchHolidays();
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
  void _setState(HolidayViewState newState) {
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
}