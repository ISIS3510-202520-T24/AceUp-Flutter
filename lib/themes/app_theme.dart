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
      primary: AppColors.mintDark,
      onPrimary: AppColors.blueDarkest,
      primaryContainer: AppColors.blueLight,
      onPrimaryContainer: AppColors.blueDark,
      secondary: AppColors.blueMedium,
      onSecondary: AppColors.lightLightest,
      secondaryContainer: AppColors.blueLightest,
      surface: AppColors.lightLightest,
      onSurface: AppColors.blueDarkest,
      surfaceDim: AppColors.lightLight,
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

