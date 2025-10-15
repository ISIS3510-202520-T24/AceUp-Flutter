import 'package:flutter/material.dart';
import '../themes/app_typography.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: colors.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 40,
                    color: colors.secondary,
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTypography.h2.copyWith(color: colors.onPrimary),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: AppTypography.bodyM.copyWith(color: colors.onSecondary),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}