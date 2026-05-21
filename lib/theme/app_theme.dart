import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkAccentGold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccentGold,
        secondary: AppColors.darkAccentAmber,
        surface: AppColors.darkSurface,
        error: AppColors.darkBloodRed,
        onPrimary: AppColors.darkBackground,
        onSecondary: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
        onError: AppColors.darkTextPrimary,
      ),
      textTheme: _buildTextTheme(
        baseTheme: ThemeData.dark().textTheme,
        displayColor: AppColors.darkAccentGold,
        bodyColor: AppColors.darkTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bebasNeue(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkAccentGold,
        unselectedItemColor: AppColors.darkTextSecondary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightAccentGold,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccentGold,
        secondary: AppColors.lightAccentAmber,
        surface: AppColors.lightSurface,
        error: AppColors.lightRustyRed,
        onPrimary: AppColors.lightTextPrimary,
        onSecondary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
        onError: AppColors.lightBackground,
      ),
      textTheme: _buildTextTheme(
        baseTheme: ThemeData.light().textTheme,
        displayColor: AppColors.lightTextPrimary,
        bodyColor: AppColors.lightTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bebasNeue(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightAccentGold,
        unselectedItemColor: AppColors.lightTextSecondary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme({
    required TextTheme baseTheme,
    required Color displayColor,
    required Color bodyColor,
  }) {
    return GoogleFonts.interTextTheme(baseTheme).copyWith(
      displayLarge: GoogleFonts.bebasNeue(
        textStyle: baseTheme.displayLarge?.copyWith(
          color: displayColor,
          letterSpacing: 2,
        ),
      ),
      displayMedium: GoogleFonts.bebasNeue(
        textStyle: baseTheme.displayMedium?.copyWith(
          color: displayColor,
          letterSpacing: 1.5,
        ),
      ),
      displaySmall: GoogleFonts.bebasNeue(
        textStyle: baseTheme.displaySmall?.copyWith(
          color: displayColor,
        ),
      ),
      headlineLarge: GoogleFonts.bebasNeue(
        textStyle: baseTheme.headlineLarge?.copyWith(
          color: displayColor,
        ),
      ),
      headlineMedium: GoogleFonts.bebasNeue(
        textStyle: baseTheme.headlineMedium?.copyWith(
          color: displayColor,
        ),
      ),
      headlineSmall: GoogleFonts.bebasNeue(
        textStyle: baseTheme.headlineSmall?.copyWith(
          color: displayColor,
        ),
      ),
      titleLarge: GoogleFonts.bebasNeue(
        textStyle: baseTheme.titleLarge?.copyWith(
          color: displayColor,
          letterSpacing: 1,
        ),
      ),
      bodyLarge: GoogleFonts.inter(
        textStyle: baseTheme.bodyLarge?.copyWith(
          color: bodyColor,
        ),
      ),
      bodyMedium: GoogleFonts.inter(
        textStyle: baseTheme.bodyMedium?.copyWith(
          color: bodyColor,
        ),
      ),
    );
  }
}
