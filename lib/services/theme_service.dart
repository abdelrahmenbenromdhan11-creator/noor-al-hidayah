import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  // ═══════════════ الألوان المتاحة ═══════════════
  static const Map<String, Map<String, Color>> themes = {
    'default_gold': {
      'primary': Color(0xFFD4AF37),
      'dark': Color(0xFF0B2B26),
      'card': Color(0xFF143B32),
      'light': Color(0xFF1E4D40),
    },
    'theme_purple': {
      'primary': Color(0xFF9B59B6),
      'dark': Color(0xFF1A0B2E),
      'card': Color(0xFF2D1B4E),
      'light': Color(0xFF4A2C7A),
    },
    'theme_sky': {
      'primary': Color(0xFF3498DB),
      'dark': Color(0xFF0B1E2E),
      'card': Color(0xFF1B3A4E),
      'light': Color(0xFF2C5A7A),
    },
    'theme_emerald': {
      'primary': Color(0xFF2ECC71),
      'dark': Color(0xFF0B2618),
      'card': Color(0xFF143B2A),
      'light': Color(0xFF1E4D3A),
    },
  };

  static String _currentThemeId = 'default_gold';

  // ═══════════════ تحميل الثيم المحفوظ ═══════════════
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currentThemeId = prefs.getString('active_theme') ?? 'default_gold';
    notifier.value++;
  }

  // ═══════════════ تبديل الثيم ═══════════════
  static Future<void> setTheme(String themeId) async {
    if (!themes.containsKey(themeId)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_theme', themeId);
    _currentThemeId = themeId;
    notifier.value++;
  }

  // ═══════════════ الحصول على الألوان الحالية ═══════════════
  static Color get primary =>
      themes[_currentThemeId]!['primary']!;
  static Color get dark =>
      themes[_currentThemeId]!['dark']!;
  static Color get card =>
      themes[_currentThemeId]!['card']!;
  static Color get light =>
      themes[_currentThemeId]!['light']!;

  static String get currentThemeId => _currentThemeId;
}
