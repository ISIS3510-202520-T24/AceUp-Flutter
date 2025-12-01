import 'package:flutter/material.dart';

import '../../widgets/burger_menu.dart';
import 'schedule_screen.dart';

class ScheduleScreenWrapper extends StatelessWidget {
  const ScheduleScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week View'),
      ),
      drawer: const BurgerMenu(),
      body: const ScheduleScreen(),
    );
  }
}
