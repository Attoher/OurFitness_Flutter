import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AppThemePreset {
  final String name;
  final String emoji;
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color accent;
  final Color accentDark;

  const AppThemePreset({
    required this.name,
    required this.emoji,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.accent,
    required this.accentDark,
  });
}

class ThemeService extends ChangeNotifier {
  static const _prefKey = 'theme_index';

  static const List<AppThemePreset> presets = [
    AppThemePreset(
      name: 'Lime',
      emoji: '🍋',
      background: Color(0xFF0F0F0F),
      surface: Color(0xFF1E1E1E),
      surfaceLight: Color(0xFF2A2A2A),
      accent: Color(0xFFCBEF43),
      accentDark: Color(0xFF9BBF1A),
    ),
    AppThemePreset(
      name: 'Ocean',
      emoji: '🌊',
      background: Color(0xFF050D1A),
      surface: Color(0xFF0D1F30),
      surfaceLight: Color(0xFF162B3F),
      accent: Color(0xFF4FA8F5),
      accentDark: Color(0xFF2E7FCC),
    ),
    AppThemePreset(
      name: 'Violet',
      emoji: '💜',
      background: Color(0xFF0D0A18),
      surface: Color(0xFF1C1628),
      surfaceLight: Color(0xFF2A2040),
      accent: Color(0xFFAB7FF5),
      accentDark: Color(0xFF7C50D0),
    ),
    AppThemePreset(
      name: 'Ember',
      emoji: '🔥',
      background: Color(0xFF140A0A),
      surface: Color(0xFF261414),
      surfaceLight: Color(0xFF361C1C),
      accent: Color(0xFFFF6B35),
      accentDark: Color(0xFFCC4A1A),
    ),
    AppThemePreset(
      name: 'Mint',
      emoji: '🌿',
      background: Color(0xFF081412),
      surface: Color(0xFF102220),
      surfaceLight: Color(0xFF183330),
      accent: Color(0xFF00E5B3),
      accentDark: Color(0xFF00B387),
    ),
  ];

  int _currentIndex = 0;
  SharedPreferences? _prefs;

  ThemeService() {
    _loadSaved();
  }

  int get currentIndex => _currentIndex;
  AppThemePreset get current => presets[_currentIndex];
  Color get accent => current.accent;
  Color get background => current.background;
  Color get surface => current.surface;
  Color get surfaceLight => current.surfaceLight;

  Future<void> _loadSaved() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getInt(_prefKey) ?? 0;
    _currentIndex = saved.clamp(0, presets.length - 1);
    _syncAppTheme();
    notifyListeners();
  }

  void setTheme(int index) {
    if (index < 0 || index >= presets.length || index == _currentIndex) return;
    _currentIndex = index;
    _syncAppTheme();
    _prefs?.setInt(_prefKey, index);
    notifyListeners();
  }

  void _syncAppTheme() {
    final p = current;
    AppTheme.applyPreset(
      background: p.background,
      surface: p.surface,
      surfaceLight: p.surfaceLight,
      accent: p.accent,
      accentDark: p.accentDark,
    );
  }

  ThemeData buildMaterialTheme() {
    final p = current;
    final onAccent = isLightColor(p.accent) ? Colors.black : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: p.background,
      colorScheme: ColorScheme.dark(
        primary: p.accent,
        secondary: p.accentDark,
        surface: p.surface,
        onPrimary: onAccent,
        onSecondary: onAccent,
        onSurface: Colors.white,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
        displaySmall: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Color(0xFF8A8A8A), fontSize: 14),
        bodySmall: TextStyle(color: Color(0xFF555555), fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: onAccent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static bool isLightColor(Color color) => color.computeLuminance() > 0.5;
}
