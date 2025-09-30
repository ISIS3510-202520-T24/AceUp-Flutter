import 'package:flutter/material.dart';

class AppTheme {
  static const Color mint = Color(0xFF2ED5AE);
  static const Color pastelBg = Color(0xFFF5F3ED);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: mint,
      primary: mint,
    ),
    scaffoldBackgroundColor: Color(0xFFF8F6F0),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE3EA)),
      ),
    ),
  );
}
