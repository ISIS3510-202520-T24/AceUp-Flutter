import 'package:flutter/material.dart';
import '../views/today/today_screen.dart';
import '../views/shared/shared_screen.dart';
import '../views/holidays/holidays_screen.dart';

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          ListTile(
            title: const Text("Today"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const TodayScreen()),
              );
            },
          ),
          ListTile(
            title: const Text("Shared"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/shared');
            },
          ),
          ListTile(
            title: const Text("Holidays"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HolidaysScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

