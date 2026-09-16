import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  // ═══════════════ حفظ الاسم ═══════════════
  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? '';
  }

  static Future<void> setName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value);
    notifier.value++;
  }

  // ═══════════════ حفظ البايو ═══════════════
  static Future<String> getBio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_bio') ?? '';
  }

  static Future<void> setBio(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_bio', value);
    notifier.value++;
  }

  // ═══════════════ حفظ صورة الملف الشخصي ═══════════════
  static Future<String?> getAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar');
  }

  static Future<void> setAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', path);
    notifier.value++;
  }

  // ═══════════════ اللغة/البلد (اختياري) ═══════════════
  static Future<String> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_location') ?? '';
  }

  static Future<void> setLocation(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_location', value);
    notifier.value++;
  }

  // ═══════════════ هل الملف مكتمل؟ ═══════════════
  static Future<bool> isComplete() async {
    final name = await getName();
    return name.isNotEmpty;
  }
}
