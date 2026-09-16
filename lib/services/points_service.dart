import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  // ═══════════════ النقاط ═══════════════
  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_points') ?? 1240;
  }

  static Future<void> setPoints(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', value);
    notifier.value++;
  }

  static Future<void> addPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('user_points') ?? 1240;
    await prefs.setInt('user_points', current + amount);
    notifier.value++;
  }

  static Future<bool> spendPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('user_points') ?? 1240;
    if (current < amount) return false;
    await prefs.setInt('user_points', current - amount);
    notifier.value++;
    return true;
  }

  // ═══════════════ المملوكات ═══════════════
  static Future<Set<String>> getOwned() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('owned_items') ?? []).toSet();
  }

  static Future<void> addOwned(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('owned_items') ?? [];
    if (!list.contains(itemId)) {
      list.add(itemId);
      await prefs.setStringList('owned_items', list);
    }
    notifier.value++;
  }

  // ═══════════════ العنصر المُفعّل ═══════════════
  static Future<String?> getEquipped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_item');
  }

  static Future<void> equip(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('equipped_item', itemId);
    notifier.value++;
  }

  static Future<void> unequip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipped_item');
    notifier.value++;
  }

  // ═══════════════ Promo استخدام ═══════════════
  static Future<bool> isPromoUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('promo_used') ?? false;
  }

  static Future<void> usePromo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('promo_used', true);
  }

  // ═══════════════ عدد الإعلانات المشاهدة ═══════════════
  static Future<int> getAdsWatchedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    return prefs.getInt('ads_$today') ?? 0;
  }

  static Future<int> addAdWatched() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final count = (prefs.getInt('ads_$today') ?? 0) + 1;
    await prefs.setInt('ads_$today', count);
    return count;
  }

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month}-${d.day}';
  }
}
