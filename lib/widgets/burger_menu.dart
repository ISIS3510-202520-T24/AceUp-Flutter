import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/app_typography.dart';
import '../themes/app_icons.dart';

import '../services/auth/auth_service.dart';
import '../services/profile/profile_notifier.dart';

class BurgerMenu extends StatelessWidget {
  const BurgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final auth = context.read<AuthService>();
    final email = auth.currentUser?.email ?? '';
    final fallbackNick = auth.currentUser?.displayName ?? 'Student';

    final profile = context.watch<ProfileNotifier>();

    final shownNick = (profile.nickname.trim().isNotEmpty)
        ? profile.nickname.trim()
        : (fallbackNick.isNotEmpty ? fallbackNick : email);

    ImageProvider? avatarImage;
    final avatarPath = profile.avatarLocalPath;

    if (avatarPath != null && avatarPath.startsWith('asset:')) {
      avatarImage = AssetImage(
        avatarPath.replaceFirst('asset:', ''),
      );
    } else if (avatarPath != null && avatarPath.isNotEmpty) {
      avatarImage = FileImage(File(avatarPath));
    } else {
      // fallback inicial si nunca se guardó nada
      avatarImage = const AssetImage('assets/avatars/avatar_1.png');
    }

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(color: colors.onPrimary),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AceUp",
                    style: AppTypography.logo.copyWith(color: colors.tertiary),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                      shownNick.isNotEmpty
                          ? shownNick[0].toUpperCase()
                          : '?',
                      style: AppTypography.h3.copyWith(
                        color: colors.surface,
                      ),
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical:8),
              children: [
                const SizedBox(height: 8),
                _sectionHeader(context, "Schedule"),
                _menuItem(
                  context: context,
                  title: "Today",
                  icon: AppIcons.calendarDay,
                  route: '/today',
                  isSelected: currentRoute == '/today',
                ),
                _menuItem(
                  context: context,
                  title: "Week View",
                  icon: AppIcons.calendarWeek,
                  route: null,
                  isSelected: false,
                  isComingSoon: true,
                ),
                _menuItem(
                  context: context,
                  title: "Calendar",
                  icon: AppIcons.calendarMonth,
                  route: null,
                  isSelected: false,
                  isComingSoon: true,
                ),
                _menuItem(
                  context: context,
                  title: "Shared",
                  icon: AppIcons.shared,
                  route: '/shared',
                  isSelected: currentRoute == '/shared',
                ),

                const SizedBox(height: 16),
                _sectionHeader(context, "My Data"),
                _menuItem(
                  context: context,
                  title: "Planner",
                  icon: AppIcons.planner,
                  route: '/planner',
                  isSelected: currentRoute == '/planner',
                ),
                _menuItem(
                  context: context,
                  title: "Assignments",
                  icon: AppIcons.assignments,
                  route: '/assignments',
                  isSelected: currentRoute == '/assignments',
                ),
                _menuItem(
                  context: context,
                  title: "Teachers",
                  icon: AppIcons.teacher,
                  route: null,
                  isSelected: false,
                  isComingSoon: true,
                ),
                _menuItem(
                  context: context,
                  title: "Holidays",
                  icon: AppIcons.holidays,
                  route: '/holidays',
                  isSelected: currentRoute == '/holidays',
                ),
                _menuItem(
                  context: context,
                  title: "Storage Stats",
                  icon: Icons.storage,
                  route: '/group-stats',
                  isSelected: currentRoute == '/group-stats',
                ),
              ],
            ),
          ),
          const Spacer(),
          _menuItem(
            context: context,
            title: "Settings",
            icon: AppIcons.settings,
            route: '/settings',
            isSelected: currentRoute == '/settings',
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTypography.h4.copyWith(color: colors.onPrimary),
      ),
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String? route,
    required bool isSelected,
    bool isComingSoon = false,
  }) {
    final colors = Theme.of(context).colorScheme;

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
              duration: const Duration(seconds: 1),
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