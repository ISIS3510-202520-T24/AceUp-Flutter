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
      child: Column(
        children: [
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
          ),

          // Logout button pinned at the bottom
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await context.read<AuthService>().signOut();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
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
