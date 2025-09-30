// lib/views/holidays/holidays_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/holidays_viewmodel.dart';
import '../../widgets/burger_menu.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final holidays = context.watch<HolidaysViewModel>().holidays;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          "Holidays",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF201E1B),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEAF4FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF201E1B)),
      ),
      drawer: const BurgerMenu(),
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
        backgroundColor: const Color(0xFF50E3C2),
        onPressed: () {
          // TODO: add holiday action
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
