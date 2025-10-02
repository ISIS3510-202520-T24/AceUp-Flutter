import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.onPrimaryContainer),
            child: Text(
              "AceUp",
              style: TextStyle(
                color: colors.primaryContainer,
                fontSize: 20,
              ),
            ),
          ),
          _buildMenuItem(
            context: context,
            title: "Today",
            route: '/today',
            isSelected: currentRoute == '/today',
            colors: colors,
          ),
          _buildMenuItem(
            context: context,
            title: "Shared",
            route: '/shared',
            isSelected: currentRoute == '/shared',
            colors: colors,
          ),
          _buildMenuItem(
            context: context,
            title: "Holidays",
            route: '/holidays',
            isSelected: currentRoute == '/holidays',
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String route,
    required bool isSelected,
    required ColorScheme colors,
  }) {
    return ListTile(
      title: Text(title),
      selected: isSelected,
      selectedTileColor: colors.primaryContainer.withValues(alpha: 0.1),
      onTap: () {
        Navigator.pop(context);

        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
