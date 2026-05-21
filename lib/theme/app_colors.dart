import 'package:flutter/material.dart';

class AppColors {
  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkAccentGold = Color(0xFFC9A84C);
  static const Color darkAccentAmber = Color(0xFFE8B84B);
  static const Color darkMutedOlive = Color(0xFF4A5240);
  static const Color darkTextPrimary = Color(0xFFF0EDE6);
  static const Color darkTextSecondary = Color(0xFFA09E9B);
  static const Color darkBloodRed = Color(0xFF8B1A1A);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F0E8);
  static const Color lightSurface = Color(0xFFEDE6D6);
  static const Color lightAccentGold = Color(0xFFC9A84C);
  static const Color lightAccentAmber = Color(0xFFE8B84B);
  static const Color lightDarkTeal = Color(0xFF1D4D4F);
  static const Color lightTextPrimary = Color(0xFF1A1509);
  static const Color lightTextSecondary = Color(0xFF5A5549);
  static const Color lightRustyRed = Color(0xFF8B3A2A);

  // Rank / Mood Colors (dari terburuk ke terbaik)
  static const Color moodVeryBad = Color(0xFF8B1A1A); // Red
  static const Color moodBad = Color(0xFFB55D30); // Orange-ish
  static const Color moodMeh = Color(0xFFE8B84B); // Yellow/Amber
  static const Color moodGood = Color(0xFF4A5240); // Olive
  static const Color moodRad = Color(0xFF1D4D4F); // Teal
}
