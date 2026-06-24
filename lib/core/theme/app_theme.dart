import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundLight,
        error: AppColors.error,
      ),
      // Comprehensive Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.headingXL.copyWith(
          color: AppColors.primaryDark,
        ),
        displayMedium: AppTypography.headingL.copyWith(
          color: AppColors.primaryDark,
        ),
        displaySmall: AppTypography.headingM.copyWith(
          color: AppColors.primaryDark,
        ),
        headlineLarge: AppTypography.headingS.copyWith(
          color: AppColors.primaryDark,
        ),
        headlineMedium: AppTypography.subheadingL.copyWith(
          color: AppColors.primaryDark,
        ),
        headlineSmall: AppTypography.subheadingM.copyWith(
          color: AppColors.primaryDark,
        ),
        titleLarge: AppTypography.subheadingL.copyWith(
          color: AppColors.primaryDark,
        ),
        titleMedium: AppTypography.subheadingM.copyWith(
          color: AppColors.primaryDark,
        ),
        titleSmall: AppTypography.subheadingS.copyWith(
          color: AppColors.primaryDark,
        ),
        bodyLarge: AppTypography.bodyL.copyWith(color: AppColors.textLight),
        bodyMedium: AppTypography.bodyM.copyWith(color: AppColors.textLight),
        bodySmall: AppTypography.bodyS.copyWith(color: AppColors.textGrey600),
        labelLarge: AppTypography.buttonL.copyWith(color: Colors.white),
        labelMedium: AppTypography.buttonM.copyWith(color: Colors.white),
        labelSmall: AppTypography.buttonS.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight,
        labelStyle: AppTypography.subheadingS.copyWith(
          color: AppColors.primary,
        ),
        hintStyle: AppTypography.bodyM.copyWith(color: AppColors.textGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTypography.spacingL,
          vertical: AppTypography.spacingM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingM,
            horizontal: AppTypography.spacingL,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingM,
            horizontal: AppTypography.spacingL,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingS,
            horizontal: AppTypography.spacingM,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingS.copyWith(
          color: AppColors.primaryDark,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardLight,
        labelStyle: AppTypography.bodyS.copyWith(color: AppColors.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusXL),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      // Comprehensive Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.headingXL.copyWith(color: Colors.white),
        displayMedium: AppTypography.headingL.copyWith(color: Colors.white),
        displaySmall: AppTypography.headingM.copyWith(color: Colors.white),
        headlineLarge: AppTypography.headingS.copyWith(color: Colors.white),
        headlineMedium: AppTypography.subheadingL.copyWith(color: Colors.white),
        headlineSmall: AppTypography.subheadingM.copyWith(color: Colors.white),
        titleLarge: AppTypography.subheadingL.copyWith(color: Colors.white),
        titleMedium: AppTypography.subheadingM.copyWith(color: Colors.white),
        titleSmall: AppTypography.subheadingS.copyWith(color: Colors.white),
        bodyLarge: AppTypography.bodyL.copyWith(color: AppColors.textDark),
        bodyMedium: AppTypography.bodyM.copyWith(color: AppColors.textDark),
        bodySmall: AppTypography.bodyS.copyWith(color: Colors.white70),
        labelLarge: AppTypography.buttonL.copyWith(color: Colors.white),
        labelMedium: AppTypography.buttonM.copyWith(color: Colors.white),
        labelSmall: AppTypography.buttonS.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        labelStyle: AppTypography.subheadingS.copyWith(color: Colors.white70),
        hintStyle: AppTypography.bodyM.copyWith(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTypography.spacingL,
          vertical: AppTypography.spacingM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingM,
            horizontal: AppTypography.spacingL,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingM,
            horizontal: AppTypography.spacingL,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTypography.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppTypography.spacingS,
            horizontal: AppTypography.spacingM,
          ),
          textStyle: AppTypography.buttonM,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingS.copyWith(color: Colors.white),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardDark,
        labelStyle: AppTypography.bodyS.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTypography.radiusXL),
        ),
      ),
    );
  }
}
