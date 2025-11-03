// lib/widgets/burger_menu.dart

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

    // Escuchar nickname/foto globales en vivo
    final profile = context.watch<ProfileNotifier>();

    final shownNick = (profile.nickname.trim().isNotEmpty)
        ? profile.nickname.trim()
        : (fallbackNick.isNotEmpty ? fallbackNick : email);

    // resolver imagen del avatar
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
          // header user
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              color: colors.surfaceContainerHigh,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colors.primaryContainer,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(
                            shownNick.isNotEmpty
                                ? shownNick[0].toUpperCase()
                                : '?',
                            style: AppTypography.h3.copyWith(
                              color: colors.onPrimary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shownNick,
                          style: AppTypography.h4.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                        Text(
                          email,
                          style: AppTypography.bodyS.copyWith(
                            color: colors.secondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
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
                  route: null,
                  isSelected: false,
                  isComingSoon: true,
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

                const SizedBox(height: 16),
                _sectionHeader(context, "Account"),
                _menuItem(
                  context: context,
                  title: "Settings",
                  icon: AppIcons.settings,
                  route: '/settings',
                  isSelected: currentRoute == '/settings',
                ),
              ],
            ),
          ),

          const _LogoutTile(),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
        color: isSelected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.actionL.copyWith(
                color: isSelected ? colors.primary : colors.onSurface,
              ),
            ),
          ),
          if (isComingSoon)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'soon',
                style: AppTypography.bodyXS.copyWith(
                  color: colors.secondary,
                ),
              ),
            ),
        ],
      ),
      onTap: route == null
          ? null
          : () {
              Navigator.pop(context);
              Navigator.pushNamed(context, route);
            },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.read<AuthService>();

    Future<void> _doLogout() async {
      await auth.signOut();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ListTile(
          leading: Icon(AppIcons.logout, color: colors.primary),
          title: Text(
            'Logout',
            style: AppTypography.actionL.copyWith(
              color: colors.onSurface,
            ),
          ),
          onTap: _doLogout,
        ),
      ),
    );
  }
}
