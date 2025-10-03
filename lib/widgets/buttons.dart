import 'package:flutter/material.dart';

import '../themes/app_typography.dart';


enum ButtonType { primary, secondary }

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    switch (type) {
      case ButtonType.primary:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: AppTypography.actionM
          ),
          child: Text(text),
        );

        case ButtonType.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.primary),
            textStyle: AppTypography.actionM,
          ),
          child: Text(text),
        );
    }
  }
}