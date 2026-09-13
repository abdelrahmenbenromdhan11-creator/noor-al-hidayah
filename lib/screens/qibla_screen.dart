import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;
  static const double userLat = 25.2048;
  static const double userLng = 55.2708;
  double _qiblaBearing = 0.0;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  void _calculateQibla() {
    final uLat = _toRad(userLat);
    final kLat = _toRad(kaabaLat);
    final dLng = _toRad(kaabaLng - userLng);
    final x = math.sin(dLng);
    final y = math.cos(uLat) * math.tan(kLat) - math.sin(uLat) * math.cos(dLng);
    double bearing = _toDeg(math.atan2(x, y));
    bearing = (bearing + 360) % 360;
    const r = 6371.0;
    final dLat = _toRad(kaabaLat - userLat);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(uLat) * math.cos(kLat) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    setState(() {
      _qiblaBearing = bearing;
      _distance = r * c;
    });
  }

  double _toRad(double d) => d * math.pi / 180.0;
  double _toDeg(double r) => r * 180.0 / math.pi;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('qibla'), style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${LanguageManager.t('distance_to_kaaba')}: ${_distance.toStringAsFixed(0)} ${LanguageManager.t('km_unit')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 30),
              SizedBox(
                width: 280, height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                        gradient: const RadialGradient(colors: [Color(0xFF143B32), Color(0xFF0B2B26)]),
                      ),
                    ),
                    const Positioned(top: 15, child: Text('N', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold))),
                    const Positioned(bottom: 15, child: Text('S', style: TextStyle(color: Colors.white54, fontSize: 20))),
                    const Positioned(left: 15, child: Text('W', style: TextStyle(color: Colors.white54, fontSize: 20))),
                    const Positioned(right: 15, child: Text('E', style: TextStyle(color: Colors.white54, fontSize: 20))),
                    Transform.rotate(
                      angle: _qiblaBearing * math.pi / 180,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 25),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 36),
                              Container(width: 4, height: 85, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(2))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(width: 60, height: 60, decoration: BoxDecoration(color: const Color(0xFF1E4D40), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFD4AF37), width: 2))),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text('${LanguageManager.t('qibla_angle')}: ${_qiblaBearing.toStringAsFixed(1)}°',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
