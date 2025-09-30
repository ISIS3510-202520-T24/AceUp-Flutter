import 'package:flutter/material.dart';
import '../views/today/today_screen.dart';
import '../views/shared/shared_screen.dart';
import '../views/holidays/holidays_screen.dart';

class NavigationViewModel {
  final List<Widget> screens = const [
    TodayScreen(),
    SharedScreen(),
    HolidaysScreen(),
  ];
}
