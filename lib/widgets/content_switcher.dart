import 'package:flutter/material.dart';

import '../themes/app_typography.dart';

class ContentSwitcher extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ContentSwitcher({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    const EdgeInsets outerPadding = EdgeInsets.all(15);
    const EdgeInsets innerPadding = EdgeInsets.all(4);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double switcherWidth = screenWidth - outerPadding.horizontal;
    final double tabWidth = (switcherWidth - innerPadding.horizontal) / tabs.length;

    return Container(
      margin:outerPadding,
      padding: const EdgeInsets.all(4),
      width: switcherWidth,
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
      ), 
      child: Row(
        spacing: 0.0,
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return _buildTab(
            context,
            colors,
            title: tabs[index],
            isSelected: isSelected,
            onTap: () => onTabSelected(index),
            fixedWidth: tabWidth,
          );
        }),
      ),
    );
  }

  Widget _buildTab(BuildContext context, ColorScheme colors, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required double fixedWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fixedWidth,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: isSelected
              ? AppTypography.h5.copyWith(color: colors.onPrimary)
              : AppTypography.h5.copyWith(color: colors.inversePrimary),
        ),
      ),
    );
  }
}