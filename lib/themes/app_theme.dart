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
      brightness: Brightness.light,
      primary: AppColors.mintLight, // Buttons, FAB, active tab
      onPrimary: AppColors.blueLight, // Icons and texts over primary
      secondary: AppColors.blueDarkest, // Top bar, current day in calendar
      onSecondary: AppColors.blueMedium, // Icons over secondary
      tertiary: AppColors.blueDark, // Sub top bar
      onTertiary: AppColors.blueMedium, // Icons over tertiary
      surface: AppColors.darkDarkest, // Background
      surfaceDim: AppColors.darkDark, // Auth screens, cards, info items
      onSurface: AppColors.lightLightest, // In-view titles
      onSurfaceVariant: AppColors.lightMedium, // Calendar numbers
      onPrimaryContainer: AppColors.lightLight, // List item details, days of week
      inversePrimary: AppColors.lightDarkest,// Unselected tabs, icons on surface
      outline: AppColors.blueMedium, // Form borders, outlines
      outlineVariant: AppColors.darkLight, // Dividers
      shadow: AppColors.darkLightest, // Unavailable items
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

