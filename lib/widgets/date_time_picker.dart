import 'package:flutter/material.dart';
import '../themes/app_typography.dart';
import '../themes/app_icons.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final bool enabled;
  final IconData icon;

  const DateTimePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateTap,
    required this.onTimeTap,
    this.enabled = true,
    this.icon = Icons.calendar_today,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Icon
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        // Date Button
        Expanded(
          child: GestureDetector(
            onTap: enabled ? onDateTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: enabled ? colors.surface : colors.shadow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enabled ? colors.outline : colors.shadow,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null
                        ? DateFormat('MMM d, yyyy').format(selectedDate!)
                        : 'Due date',
                    style: AppTypography.bodyM.copyWith(
                      color: selectedDate != null
                          ? colors.onSurface
                          : colors.secondary,
                    ),
                  ),
                  Icon(
                    AppIcons.arrowDown,
                    size: 16,
                    color: enabled ? colors.outline : colors.shadow,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Time Button
        Expanded(
          child: GestureDetector(
            onTap: enabled ? onTimeTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: enabled ? colors.surface : colors.shadow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: enabled ? colors.outline : colors.shadow,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Time',
                    style: AppTypography.bodyM.copyWith(
                      color: selectedTime != null
                          ? colors.onSurface
                          : colors.secondary,
                    ),
                  ),
                  Icon(
                    AppIcons.arrowDown,
                    size: 16,
                    color: enabled ? colors.outline : colors.shadow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}