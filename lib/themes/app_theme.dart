import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  /// Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.lightLightest,

    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.mintDark, // Buttons, FAB, active tab
      onPrimary: AppColors.blueDarkest, // Icons and texts over primary
      secondary: AppColors.blueLight, // Top bar, current day in calendar
      onSecondary: AppColors.blueDark, // Icons over secondary
      tertiary: AppColors.blueLightest, // Sub top bar
      onTertiary: AppColors.blueDark, // Icons over tertiary
      surface: AppColors.lightLightest, // Background
      surfaceDim: AppColors.lightLight, // Auth screens, cards, info items
      onSurface: AppColors.darkDarkest, // In-view titles
      onSurfaceVariant: AppColors.darkMedium, // Calendar numbers
      onPrimaryContainer: AppColors.darkLight, // List item details, days of week
      inversePrimary: AppColors.darkLightest,// Unselected tabs, icons on surface
      outline: AppColors.blueMedium, // Form borders, outlines
      outlineVariant: AppColors.lightDark, // Dividers
      shadow: AppColors.lightDarkest, // Unavailable items
      error: AppColors.errorLight,
      onError: AppColors.errorMedium,

    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightLightest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.darkDarkest,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.mintLight,
      onPrimary: AppColors.blueLightest,
      secondary: AppColors.blueLight,
      onSecondary: AppColors.darkDarkest,
      surface: AppColors.darkDarkest,
      onSurface: AppColors.lightLightest,
      surfaceDim: AppColors.darkDark,
      error: AppColors.errorMedium,
      onError: AppColors.errorLight,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkDarkest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

