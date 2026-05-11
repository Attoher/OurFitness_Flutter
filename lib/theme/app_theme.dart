import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFFCBEF43);
  static const Color accentDark = Color(0xFF9BBF1A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFF555555);
  static const Color ringCalories = Color(0xFFCBEF43);
  static const Color ringSteps = Color(0xFF4CD8D8);
  static const Color ringMove = Color(0xFF7B5FDB);
  static const Color heartRate = Color(0xFFFF5C5C);
  static const Color cardio = Color(0xFFCBEF43);
  static const Color strength = Color(0xFF4CD8D8);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: Color(0xFF4CD8D8),
        surface: surface,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: background,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF161616),
        selectedItemColor: accent,
        unselectedItemColor: Color(0xFF555555),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
