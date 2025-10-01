import 'package:flutter/material.dart';
import '../views/today/today_screen.dart';
import '../views/holidays/holidays_screen.dart';

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.onPrimaryContainer),
            child: Text("Menu", style: TextStyle(color: colors.primaryContainer, fontSize: 20)),
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
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/holidays');
            },
          ),
        ],
      ),
    );
  }
}

