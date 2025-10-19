import 'package:flutter/material.dart';
import '../themes/app_icons.dart';
import '../themes/app_typography.dart';

enum FormFieldType { text, email, password, number, multiline }

class FormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FormFieldType type;
  final int? maxLength;
  final int? maxLines;
  final Widget? suffix;
  final bool enabled;
  final TextInputAction? textInputAction;

  const FormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.type = FormFieldType.text,
    this.maxLength,
    this.maxLines = 1,
    this.suffix,
    this.enabled = true,
    this.textInputAction,
  });

  @override
  State<FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<FormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPassword = widget.type == FormFieldType.password;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      maxLength: widget.maxLength,
      maxLines: widget.type == FormFieldType.multiline ? (widget.maxLines ?? 5) : 1,
      obscureText: isPassword && _obscureText,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      keyboardType: _getKeyboardType(),
      style: AppTypography.bodyM.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTypography.h5.copyWith(color: colors.onSecondary),
        hintText: widget.hint,
        hintStyle: AppTypography.bodyM.copyWith(color: colors.secondary),
        counterText: '',
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.onError, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.onError, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.shadow),
        ),
        errorStyle: TextStyle(color: colors.onError),
        suffixIcon: isPassword
            ? IconButton(
          onPressed: () => setState(() => _obscureText = !_obscureText),
          icon: Icon(
            _obscureText ? AppIcons.visibilityOff : AppIcons.visibilityOn,
            color: colors.outline,
          ),
        )
            : widget.suffix,
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.number:
        return TextInputType.number;
      case FormFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }
}