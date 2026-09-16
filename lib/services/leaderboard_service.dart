import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? avatarPath;
  final int points;
  final int level;
  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.avatarPath,
    required this.points,
    required this.level,
  });
}

class LeaderboardService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  // ═══════════════ المستخدم الحالي ═══════════════
  // (نستخدم Firebase UID أو اسم الجهاز)
  static Future<String> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('user_id');
    if (id == null) {
      id = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString('user_id', id);
    }
    return id;
  }

  // ═══════════════ تحديث بيانات المستخدم الحالي في اللوحة ═══════════════
  static Future<void> updateMyScore({
    required String displayName,
    required int points,
    String? avatarPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getCurrentUserId();

    await prefs.setString('lb_${userId}_name', displayName);
    await prefs.setInt('lb_${userId}_points', points);
    if (avatarPath != null) {
      await prefs.setString('lb_${userId}_avatar', avatarPath);
    }
    // سجل أن المستخدم موجود
    final users = prefs.getStringList('lb_users') ?? [];
    if (!users.contains(userId)) {
      users.add(userId);
      await prefs.setStringList('lb_users', users);
    }
    notifier.value++;
  }

  // ═══════════════ جلب اللوحة ═══════════════
  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('lb_users') ?? [];
    final entries = <LeaderboardEntry>[];

    for (final uid in users) {
      final name = prefs.getString('lb_${uid}_name') ?? 'مستخدم';
      final pts = prefs.getInt('lb_${uid}_points') ?? 0;
      final avatar = prefs.getString('lb_${uid}_avatar');
      entries.add(LeaderboardEntry(
        userId: uid,
        displayName: name,
        avatarPath: avatar,
        points: pts,
        level: _levelFromPoints(pts),
      ));
    }

    // رتب تنازليًا حسب النقاط
    entries.sort((a, b) => b.points.compareTo(a.points));
    return entries;
  }

  // ═══════════════ المستوى حسب النقاط ═══════════════
  static int _levelFromPoints(int points) {
    if (points >= 10000) return 5; // ذهبي
    if (points >= 5000) return 4;  // فضي
    if (points >= 2000) return 3;  // برونزي
    if (points >= 500) return 2;   // متوسط
    return 1;                       // مبتدئ
  }

  // ═══════════════ اسم المستوى ═══════════════
  static String getLevelName(int level, bool isAr) {
    switch (level) {
      case 5: return isAr ? 'ذهبي' : 'Gold';
      case 4: return isAr ? 'فضي' : 'Silver';
      case 3: return isAr ? 'برونزي' : 'Bronze';
      case 2: return isAr ? 'متوسط' : 'Intermediate';
      default: return isAr ? 'مبتدئ' : 'Beginner';
    }
  }

  // ═══════════════ لون المستوى ═══════════════
  static Color getLevelColor(int level) {
    switch (level) {
      case 5: return const Color(0xFFD4AF37);
      case 4: return const Color(0xFFBDC3C7);
      case 3: return const Color(0xFFCD7F32);
      case 2: return const Color(0xFF4ECDC4);
      default: return const Color(0xFF95E1D3);
    }
  }

  // ═══════════════ ترتيب المستخدم الحالي ═══════════════
  static Future<int> getMyRank() async {
    final userId = await getCurrentUserId();
    final entries = await getLeaderboard();
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].userId == userId) return i + 1;
    }
    return -1;
  }
}
