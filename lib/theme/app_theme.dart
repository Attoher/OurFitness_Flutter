import 'package:flutter/material.dart';

class AppTheme {
  // Theme-dynamic colors — updated by ThemeService.applyPreset()
  static Color background = const Color(0xFF0F0F0F);
  static Color surface = const Color(0xFF1E1E1E);
  static Color surfaceLight = const Color(0xFF2A2A2A);
  static Color accent = const Color(0xFFCBEF43);
  static Color accentDark = const Color(0xFF9BBF1A);

  // Fixed colors — never change with theme
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textMuted = Color(0xFF555555);
  static const Color ringSteps = Color(0xFF4CD8D8);
  static const Color ringMove = Color(0xFF7B5FDB);
  static const Color heartRate = Color(0xFFFF5C5C);
  static const Color strength = Color(0xFF4CD8D8);

  // Aliases that follow the accent color
  static Color get ringCalories => accent;
  static Color get cardio => accent;

  static void applyPreset({
    required Color background,
    required Color surface,
    required Color surfaceLight,
    required Color accent,
    required Color accentDark,
  }) {
    AppTheme.background = background;
    AppTheme.surface = surface;
    AppTheme.surfaceLight = surfaceLight;
    AppTheme.accent = accent;
    AppTheme.accentDark = accentDark;
  }
}
