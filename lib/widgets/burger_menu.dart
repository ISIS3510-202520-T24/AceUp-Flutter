import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../themes/app_typography.dart';
import '../themes/app_icons.dart';

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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(color: colors.onPrimary),
            child: SafeArea(
              bottom: false,
              child: Text(
                "AceUp",
                style: AppTypography.h1.copyWith(color: colors.tertiary),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "My Schedules",
                    style: AppTypography.h4.copyWith(color: colors.onPrimary),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  title: "Today",
                  icon: AppIcons.calendarDay,
                  route: '/today',
                  isSelected: currentRoute == '/today',
                  colors: colors,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Week View",
                  icon: AppIcons.calendarWeek,
                  route: null,
                  isSelected: false,
                  colors: colors,
                  isComingSoon: true,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Calendar",
                  icon: AppIcons.calendarMonth,
                  route: null,
                  isSelected: false,
                  colors: colors,
                  isComingSoon: true,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Shared",
                  icon: AppIcons.shared,
                  route: '/shared',
                  isSelected: currentRoute == '/shared',
                  colors: colors,
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    "My Data",
                    style: AppTypography.h4.copyWith(color: colors.onPrimary),
                  ),
                ),
                _buildMenuItem(
                  context: context,
                  title: "Planner",
                  icon: AppIcons.planner,
                  route: null,
                  isSelected: false,
                  colors: colors,
                  isComingSoon: true,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Assignments",
                  icon: AppIcons.assignments,
                  route: null,
                  isSelected: false,
                  colors: colors,
                  isComingSoon: true,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Teachers",
                  icon: AppIcons.teacher,
                  route: null,
                  isSelected: false,
                  colors: colors,
                  isComingSoon: true,
                ),
                _buildMenuItem(
                  context: context,
                  title: "Holidays",
                  icon: AppIcons.holidays,
                  route: '/holidays',
                  isSelected: currentRoute == '/holidays',
                  colors: colors,
                ),
              ],
            ),
          ),

          // Logout button pinned at the bottom
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: colors.primary),
              title: Text(
                'Logout',
                style: AppTypography.actionL.copyWith(color: colors.onSurface),
              ),
              onTap: () async {
                await context.read<AuthService>().signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String? route,
    required bool isSelected,
    required ColorScheme colors,
    bool isComingSoon = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isComingSoon ? colors.shadow : colors.primary,
      ),
      title: Text(
        title,
        style: isComingSoon ? AppTypography.actionL.copyWith(color: colors.shadow) : AppTypography.actionL.copyWith(color: colors.onSurface),
      ),
      selected: isSelected,
      selectedTileColor: colors.tertiary,
      onTap: () {
        Navigator.pop(context);

        if (isComingSoon) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title - Coming soon!'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else if (route != null && !isSelected) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}