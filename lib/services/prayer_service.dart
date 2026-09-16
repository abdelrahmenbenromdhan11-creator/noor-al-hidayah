import 'dart:math' as math;
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class PrayerService {
  static Position? _cachedPosition;

  static Future<Position?> getLocation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPosition != null) return _cachedPosition;
    final pos = await LocationService.getCurrentLocation(forceRefresh: forceRefresh);
    _cachedPosition = pos;
    return pos;
  }

  // ═══════════════ أوقات الصلاة ═══════════════
  static Map<String, DateTime> calculatePrayerTimes(Position pos) {
    final coordinates = Coordinates(pos.latitude, pos.longitude);
    final params = CalculationMethod.umm_al_qura.getParameters();
    params.madhab = Madhab.shafi;
    final date = DateComponents.from(DateTime.now());
    final prayerTimes = PrayerTimes(coordinates, date, params);
    return {
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };
  }

  static String formatTime(DateTime time) {
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }

  static Map<String, dynamic> getNextPrayer(Map<String, DateTime> times) {
    final now = DateTime.now();
    final list = [
      {'key': 'fajr', 'name_ar': 'الفجر', 'name_en': 'Fajr', 'time': times['fajr']!},
      {'key': 'dhuhr', 'name_ar': 'الظهر', 'name_en': 'Dhuhr', 'time': times['dhuhr']!},
      {'key': 'asr', 'name_ar': 'العصر', 'name_en': 'Asr', 'time': times['asr']!},
      {'key': 'maghrib', 'name_ar': 'المغرب', 'name_en': 'Maghrib', 'time': times['maghrib']!},
      {'key': 'isha', 'name_ar': 'العشاء', 'name_en': 'Isha', 'time': times['isha']!},
    ];
    for (final p in list) {
      if ((p['time'] as DateTime).isAfter(now)) return p;
    }
    final fajrTomorrow = times['fajr']!.add(const Duration(days: 1));
    return {
      'key': 'fajr',
      'name_ar': 'الفجر',
      'name_en': 'Fajr',
      'time': fajrTomorrow,
    };
  }

  static String timeRemaining(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return '0m';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  // ═══════════════ القبلة حسب موقع المستخدم ═══════════════
  static double calculateQiblaBearing(double userLat, double userLng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    final uLat = _toRad(userLat);
    final kLat = _toRad(kaabaLat);
    final dLng = _toRad(kaabaLng - userLng);
    final x = math.sin(dLng);
    final y = math.cos(uLat) * math.tan(kLat) - math.sin(uLat) * math.cos(dLng);
    double bearing = _toDeg(math.atan2(x, y));
    return (bearing + 360) % 360;
  }

  // ═══════════════ المسافة إلى الكعبة ═══════════════
  static double calculateDistanceToKaaba(double userLat, double userLng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    const double r = 6371.0;
    final uLat = _toRad(userLat);
    final kLat = _toRad(kaabaLat);
    final dLat = _toRad(kaabaLat - userLat);
    final dLng = _toRad(kaabaLng - userLng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(uLat) * math.cos(kLat) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double d) => d * math.pi / 180.0;
  static double _toDeg(double r) => r * 180.0 / math.pi;
}
