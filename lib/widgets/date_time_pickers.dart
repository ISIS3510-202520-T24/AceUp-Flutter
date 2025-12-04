import 'package:flutter/material.dart';
import '../themes/app_typography.dart';
import '../themes/app_icons.dart';
import 'package:intl/intl.dart';

/// Reusable Date Picker Field Widget
class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateText = selectedDate != null
        ? DateFormat('MMM d, yyyy').format(selectedDate!)
        : label;

    return InkWell(
      onTap: enabled ? () => _selectDate(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: AppTypography.bodyM.copyWith(
                color: selectedDate != null ? colors.onSurface : colors.secondary,
              ),
            ),
            Icon(
              AppIcons.calendarDay,
              size: 18,
              color: colors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

/// Reusable Time Picker Field Widget
class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool enabled;

  const TimePickerField({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTimeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final timeText = selectedTime != null
        ? selectedTime!.format(context)
        : label;

    return InkWell(
      onTap: enabled ? () => _selectTime(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeText,
              style: AppTypography.bodyM.copyWith(
                color: selectedTime != null ? colors.onSurface : colors.secondary,
              ),
            ),
            Icon(
              AppIcons.clock,
              size: 18,
              color: colors.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }
}
