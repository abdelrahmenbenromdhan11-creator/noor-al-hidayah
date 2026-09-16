import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhkarProgressService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  // ═══════════════ تسجيل ذكر مكتمل ═══════════════
  static Future<void> markDhikrCompleted({
    required String categoryId,
    required int dhikrIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final key = 'adhkar_${today}_${categoryId}_$dhikrIndex';
    await prefs.setBool(key, true);
    notifier.value++;
  }

  // ═══════════════ هل ذكر مكتمل اليوم؟ ═══════════════
  static Future<bool> isDhikrCompleted({
    required String categoryId,
    required int dhikrIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final key = 'adhkar_${today}_${categoryId}_$dhikrIndex';
    return prefs.getBool(key) ?? false;
  }

  // ═══════════════ عدد الأذكار المكتملة في فئة ═══════════════
  static Future<int> getCompletedCountInCategory({
    required String categoryId,
    required int totalDhikr,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    int count = 0;
    for (int i = 0; i < totalDhikr; i++) {
      final key = 'adhkar_${today}_${categoryId}_$i';
      if (prefs.getBool(key) ?? false) count++;
    }
    return count;
  }

  // ═══════════════ عدد الأذكار المكتملة في جميع الفئات ═══════════════
  static Future<int> getTotalCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    int count = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith('adhkar_${today}_')) {
        if (prefs.getBool(key) ?? false) count++;
      }
    }
    return count;
  }

  // ═══════════════ Streak (أيام متتالية أكمل أذكار الصباح) ═══════════════
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      // نعتبر اليوم مكتملًا إذا أكمل 5 أذكار على الأقل
      int completedCount = 0;
      for (final k in prefs.getKeys()) {
        if (k.startsWith('adhkar_${key}_')) {
          if (prefs.getBool(k) ?? false) completedCount++;
        }
      }
      if (completedCount >= 5) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // ═══════════════ إعادة تعيين اليوم ═══════════════
  static Future<void> resetToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final keys = prefs.getKeys().where((k) => k.startsWith('adhkar_${today}_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    notifier.value++;
  }

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }
}
