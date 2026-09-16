import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProgressService {
  // ═══════════════ حفظ صلاة ═══════════════
  static Future<void> markPrayer({
    required String prayerKey,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setBool('prayer_${today}_$prayerKey', completed);
    notifyListeners();
  }

  // ═══════════════ هل صلاة اليوم مكتملة؟ ═══════════════
  static Future<bool> isPrayerDone(String prayerKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    return prefs.getBool('prayer_${today}_$prayerKey') ?? false;
  }

  // ═══════════════ عدد الصلوات المكتملة اليوم ═══════════════
  static Future<int> getTodayPrayersCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    const prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    int count = 0;
    for (final p in prayers) {
      if (prefs.getBool('prayer_${today}_$p') ?? false) count++;
    }
    return count;
  }

  // ═══════════════ حفظ هدف يومي ═══════════════
  static Future<void> markGoal({
    required String goalKey,
    required bool completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setBool('goal_${today}_$goalKey', completed);
    notifyListeners();
  }

  // ═══════════════ هل هدف اليوم مكتمل؟ ═══════════════
  static Future<bool> isGoalDone(String goalKey) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    return prefs.getBool('goal_${today}_$goalKey') ?? false;
  }

  // ═══════════════ عدد الأهداف المكتملة اليوم ═══════════════
  static Future<int> getTodayGoalsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    const goals = [
      'goal_quran_page', 'goal_5_prayers', 'goal_morning_adhkar',
      'goal_evening_adhkar', 'goal_istighfar_100', 'goal_salawat_10',
      'goal_dua_today',
    ];
    int count = 0;
    for (final g in goals) {
      if (prefs.getBool('goal_${today}_$g') ?? false) count++;
    }
    return count;
  }

  // ═══════════════ عدد الأهداف الكلي ═══════════════
  static int get totalGoals => 7;

  // ═══════════════ Streak (أيام متتالية) ═══════════════
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      const prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      bool allDone = true;
      for (final p in prayers) {
        if (!(prefs.getBool('prayer_${key}_$p') ?? false)) {
          allDone = false;
          break;
        }
      }
      if (allDone) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // ═══════════════ إعادة تعيين ═══════════════
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('prayer_') || k.startsWith('goal_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    notifyListeners();
  }

  // ═══════════════ مفتاح اليوم ═══════════════
  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }

  // ═══════════════ ValueNotifier للتحديث ═══════════════
  static final ValueNotifier<int> _notifier = ValueNotifier(0);
  static ValueNotifier<int> get notifier => _notifier;
  static void notifyListeners() {
    _notifier.value++;
  }
}
