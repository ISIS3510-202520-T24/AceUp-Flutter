import 'package:flutter/material.dart';
import '../models/day.dart';

class GroupDetailViewModel extends ChangeNotifier {
  List<Day> _weekDays = [
    Day(shortName: 'MON', dayNumber: 19),
    Day(shortName: 'TUE', dayNumber: 20),
    Day(shortName: 'WED', dayNumber: 21),
    Day(shortName: 'THU', dayNumber: 22, isSelected: true),
    Day(shortName: 'FRI', dayNumber: 23),
    Day(shortName: 'SAT', dayNumber: 24),
    Day(shortName: 'SUN', dayNumber: 25),
  ];

  List<Day> get weekDays => _weekDays;

  void selectDay(int index) {
    _weekDays = _weekDays.asMap().entries.map((entry) {
      final i = entry.key;
      final day = entry.value;
      return day.copyWith(isSelected: i == index);
    }).toList();
    notifyListeners();
  }
}
