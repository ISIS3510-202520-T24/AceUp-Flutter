import 'package:flutter/material.dart';
import '../themes/app_typography.dart';

class CounterItem {
  final String? title;
  final String? value;
  final Color? color;

  const CounterItem({
    this.title,
    this.value,
    this.color,
  });
}

class ContentCounter extends StatelessWidget {
  final CounterItem firstItem;
  final CounterItem secondItem;

  const ContentCounter({
    super.key,
    required this.firstItem,
    required this.secondItem,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _buildItem(context, firstItem)),
            Expanded(child: _buildItem(context, secondItem)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, CounterItem item) {
    final colors = Theme.of(context).colorScheme;

    if (item.title != null && item.value != null) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title!,
              style: AppTypography.h4.copyWith(color: colors.onSurface),
            ),
            Text(
              item.value!,
              style: AppTypography.h4.copyWith(
                color: item.color ?? colors.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        item.title ?? item.value ?? '',
        style: AppTypography.h4.copyWith(
          color: item.color ?? colors.onSurface,
        ),
      ),
    );
  }
}
