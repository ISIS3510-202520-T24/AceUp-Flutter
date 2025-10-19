import 'package:flutter/material.dart';
import '../themes/app_typography.dart';

class ContentSwitcher extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;

  const ContentSwitcher({
    super.key,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    const EdgeInsets outerPadding = EdgeInsets.all(15);
    const EdgeInsets innerPadding = EdgeInsets.all(4);

    final double screenWidth = MediaQuery.of(context).size.width;
    final double switcherWidth = screenWidth - outerPadding.horizontal;

    return Container(
      margin: outerPadding,
      padding: innerPadding,
      width: switcherWidth,
      height: 48,
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colors.onPrimary,
        unselectedLabelColor: colors.inversePrimary,
        labelStyle: AppTypography.h5,
        unselectedLabelStyle: AppTypography.h5,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: tabs.map((label) => Tab(text: label)).toList(),
      ),
    );
  }
}