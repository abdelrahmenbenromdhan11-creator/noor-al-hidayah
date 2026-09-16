import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _latKey = 'user_lat';
  static const String _lngKey = 'user_lng';
  static const String _cityKey = 'user_city';

  static Position? _cachedPosition;

  // ═══════════════ الحصول على الموقع ═══════════════
  static Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPosition != null) return _cachedPosition;

    try {
      // 1. تحقق من خدمة الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location service disabled');
        return null;
      }

      // 2. تحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied forever');
        return null;
      }

      // 3. احصل على الموقع
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      _cachedPosition = position;
      await _savePosition(position);
      return position;
    } catch (e) {
      debugPrint('Get location error: $e');
      // جرّب آخر موقع معروف
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          _cachedPosition = last;
          return last;
        }
      } catch (_) {}
      return null;
    }
  }

  // ═══════════════ حفظ الموقع ═══════════════
  static Future<void> _savePosition(Position pos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_latKey, pos.latitude);
      await prefs.setDouble(_lngKey, pos.longitude);
    } catch (e) {
      debugPrint('Save position: $e');
    }
  }

  // ═══════════════ استرجاع آخر موقع محفوظ ═══════════════
  static Future<Map<String, double>?> getSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lng = prefs.getDouble(_lngKey);
      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng};
      }
    } catch (_) {}
    return null;
  }

  // ═══════════════ هل الموقع مُفعّل؟ ═══════════════
  static Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  // ═══════════════ فتح إعدادات التطبيق ═══════════════
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // ═══════════════ فتح إعدادات الموقع ═══════════════
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
