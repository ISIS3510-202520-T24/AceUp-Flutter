import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_icons.dart';
import '../themes/app_typography.dart';

enum FormFieldType { text, email, password, number, multiline }

class AppFormField extends StatefulWidget {
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

  const AppFormField({
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
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPassword = widget.type == FormFieldType.password;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator ?? _defaultValidator,
      maxLength: widget.maxLength,
      maxLines: widget.type == FormFieldType.multiline ? (widget.maxLines ?? 5) : 1,
      obscureText: isPassword && _obscureText,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      keyboardType: _getKeyboardType(),
      inputFormatters: _getInputFormatters(),
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

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case FormFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case FormFieldType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'[(;,<>\")]')),
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];
      case FormFieldType.password:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'[(;,<>\")]')),
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];
      default:
        return [FilteringTextInputFormatter.deny(RegExp(r'[;<>\"]'))];
    }
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';

    switch (widget.type) {
      case FormFieldType.email:
        final emailRegex = RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');
        if (!emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case FormFieldType.number:
        if (double.tryParse(value) == null) return 'Please enter a valid number';
        break;
      default:
        if (value.contains(RegExp(r'[;<>\"]'))) return 'Invalid characters not allowed.';
        break;
    }
    return null;
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