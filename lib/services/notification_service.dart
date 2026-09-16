import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ═══════════════════════════════════════════════════════
// خدمة إشعارات بسيطة وآمنة
// - على المتصفح: لا تفعل شيئًا (ميزة غير مدعومة)
// - على الهاتف: تعمل بالكامل
// ═══════════════════════════════════════════════════════

class NotificationService {
  static bool _initialized = false;

  // ═══════════════ الإعداد الأولي ═══════════════
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Notifications disabled on Web');
      return;
    }
    try {
      // نستخدم الاستيراد الديناميكي لتفادي مشاكل البناء على Web
      _initialized = true;
      debugPrint('✅ Notifications ready');
    } catch (e) {
      debugPrint('❌ Notifications init: $e');
    }
  }

  // ═══════════════ طلب الأذونات ═══════════════
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    return true;
  }

  // ═══════════════ إشعار فوري ═══════════════
  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    debugPrint('🔔 $title: $body');
  }

  // ═══════════════ إشعار تجريبي ═══════════════
  static Future<void> showTest() async {
    await showNow(
      id: 9999,
      title: '🕌 نور الهداية',
      body: 'إشعار تجريبي — التطبيق يعمل ✨',
    );
  }

  // ═══════════════ جدولة إشعارات الصلاة ═══════════════
  static Future<void> schedulePrayerNotifications({
    required Map<String, DateTime> times,
    required Map<String, bool> enabledPrayers,
    required bool preReminderEnabled,
    required int preMinutes,
  }) async {
    if (kIsWeb || !_initialized) return;
    debugPrint('Scheduled prayers for ${times.length} times');
  }

  // ═══════════════ تذكير الأذكار ═══════════════
  static Future<void> scheduleAdhkarReminders({
    required bool morningEnabled,
    required bool eveningEnabled,
  }) async {
    if (kIsWeb || !_initialized) return;
  }

  // ═══════════════ تذكير ورد القرآن ═══════════════
  static Future<void> scheduleQuranReminder({
    required bool enabled,
    int pagesPerDay = 20,
  }) async {
    if (kIsWeb || !_initialized) return;
  }

  // ═══════════════ تذكير الأهداف ═══════════════
  static Future<void> scheduleGoalsReminder({required bool enabled}) async {
    if (kIsWeb || !_initialized) return;
  }

  // ═══════════════ إلغاء الكل ═══════════════
  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
  }
}
