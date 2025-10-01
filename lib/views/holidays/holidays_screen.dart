// lib/views/holidays/holidays_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/holidays_viewmodel.dart';
import '../../widgets/burger_menu.dart';
import '../../widgets/top_bar.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final holidays = context.watch<HolidaysViewModel>().holidays;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textStyles = theme.textTheme;

    return Scaffold(
      drawer: const BurgerMenu(),
      appBar: TopBar(
        title: "Holidays",
        leftControlType: LeftControlType.menu,
        rightControlType: RightControlType.none,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: holidays.length,
        itemBuilder: (context, index) {
          final holiday = holidays[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFEDEAE4)),
            ),
            child: ListTile(
              title: Text(
                holiday.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF201E1B),
                ),
              ),
              subtitle: Text(
                holiday.dateRange,
                style: const TextStyle(
                  color: Color(0xFF797671),
                ),
              ),
              trailing: const Icon(Icons.edit, size: 18, color: Color(0xFF797671)),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        onPressed: () {},
        child: Icon(Icons.add, size: 28, color: colors.onPrimary),
      ),
    );
  }
}
