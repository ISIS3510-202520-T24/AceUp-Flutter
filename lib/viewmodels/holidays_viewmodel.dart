import 'package:flutter/material.dart';
import '../models/holiday.dart';

class HolidaysViewModel extends ChangeNotifier {
  final List<Holiday> _holidays = [
    Holiday(name: "New Year's Day", dateRange: "Jan 1"),
    Holiday(name: "Easter", dateRange: "Apr 20 - Apr 21"),
    Holiday(name: "Labor Day", dateRange: "May 1"),
    Holiday(name: "Independence Day", dateRange: "Jul 20"),
    Holiday(name: "Halloween", dateRange: "Oct 31"),
    Holiday(name: "Christmas", dateRange: "Dec 24 - Dec 25"),
    Holiday(name: "New Year's Eve", dateRange: "Dec 31"),
  ];

  List<Holiday> get holidays => _holidays;

  void addHoliday(Holiday holiday) {
    _holidays.add(holiday);
    notifyListeners();
  }

  void editHoliday(int index, Holiday updatedHoliday) {
    _holidays[index] = updatedHoliday;
    notifyListeners();
  }
}
