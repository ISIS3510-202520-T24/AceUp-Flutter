import 'package:flutter/material.dart';
import '../themes/app_typography.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<T> items;
  final String Function(T) getLabel;
  final void Function(T?) onChanged;
  final bool enabled;

  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.h5.copyWith(color: colors.onSecondary),
        filled: true,
        fillColor: colors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.shadow),
        ),
      ),
      style: AppTypography.bodyM.copyWith(color: colors.onSurface),
      dropdownColor: colors.surface,
      items: items.map((T item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            getLabel(item),
            style: AppTypography.bodyM.copyWith(color: colors.onSurface),
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}