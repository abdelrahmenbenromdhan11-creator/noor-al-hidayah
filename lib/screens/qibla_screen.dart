import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../services/prayer_service.dart';
import '../i18n/language_manager.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with TickerProviderStateMixin {
  double _qiblaBearing = 0.0;
  double _distance = 0.0;
  double _userLat = 21.4225;
  double _userLng = 39.8262;
  bool _loading = true;
  String? _error;

  late AnimationController _glowController;
  late AnimationController _compassController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _compassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final pos = await PrayerService.getLocation();
    if (pos == null) {
      setState(() {
        _loading = false;
        _error = LanguageManager.t('location_denied');
      });
      return;
    }
    setState(() {
      _userLat = pos.latitude;
      _userLng = pos.longitude;
      _qiblaBearing = PrayerService.calculateQiblaBearing(pos.latitude, pos.longitude);
      _distance = PrayerService.calculateDistanceToKaaba(pos.latitude, pos.longitude);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _compassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                LanguageManager.t('qibla'),
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : _error != null
                    ? _buildError()
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildDistanceBadge(),
                          const SizedBox(height: 30),
                          _buildCompass(),
                          const SizedBox(height: 30),
                          _buildAngleCard(),
                          const SizedBox(height: 20),
                          _buildLocationCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.location_off, color: Color(0xFFD4AF37), size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              _error!,
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(LanguageManager.t('retry'),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                blurRadius: 15 + 10 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
                child: const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageManager.t('distance_to_kaaba'),
                    style: GoogleFonts.cairo(color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_distance.toStringAsFixed(0)} ${LanguageManager.t('km_unit')}',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompass() {
    return Center(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glow = _glowController.value;
          return SizedBox(
            width: 300, height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ═══════ حلقات خارجية مزخرفة ═══════
                // الحلقة الخارجية المتوهجة
                Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.15 * glow),
                        blurRadius: 30 + 20 * glow,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // الحلقة 1
                Container(
                  width: 295, height: 295,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3 + 0.2 * glow),
                      width: 1,
                    ),
                  ),
                ),
                // الحلقة 2
                Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                      width: 2,
                    ),
                  ),
                ),
                // الحلقة 3
                Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF143B32),
                        Color.lerp(const Color(0xFF0B2B26), const Color(0xFF1E4D40), glow * 0.5)!,
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                ),

                // ═══════ النقاط الأربعة ═══════
                const Positioned(top: 20, child: _CompassLabel(text: 'N', color: Color(0xFFD4AF37), size: 22, bold: true)),
                const Positioned(bottom: 20, child: _CompassLabel(text: 'S', color: Colors.white54, size: 18)),
                const Positioned(left: 20, child: _CompassLabel(text: 'W', color: Colors.white54, size: 18)),
                const Positioned(right: 20, child: _CompassLabel(text: 'E', color: Colors.white54, size: 18)),

                // ═══════ علامات الاتجاهات الصغيرة ═══════
                ...List.generate(60, (i) {
                  final angle = (i * 6) * math.pi / 180;
                  final isMajor = i % 5 == 0;
                  final radius = 135.0;
                  return Transform.translate(
                    offset: Offset(math.cos(angle - math.pi / 2) * radius, math.sin(angle - math.pi / 2) * radius),
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: isMajor ? 2 : 1,
                        height: isMajor ? 12 : 6,
                        color: isMajor
                            ? const Color(0xFFD4AF37).withOpacity(0.7)
                            : const Color(0xFFD4AF37).withOpacity(0.25),
                      ),
                    ),
                  );
                }),

                // ═══════ السهم الذهبي يشير للقبلة ═══════
                Transform.rotate(
                  angle: _qiblaBearing * math.pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // رأس السهم (مسجد)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                                  const Color(0xFF8B6914),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mosque, color: Color(0xFF0B2B26), size: 28),
                          ),
                          // جسم السهم
                          Container(
                            width: 4,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFFFE9A8),
                                  const Color(0xFFD4AF37),
                                  const Color(0xFFD4AF37).withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ═══════ مركز البوصلة ═══════
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                        const Color(0xFF8B6914),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.6),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.navigation, color: Color(0xFF0B2B26), size: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAngleCard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37).withOpacity(0.4), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                ),
                child: const Icon(Icons.explore, color: Color(0xFFD4AF37), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  LanguageManager.t('qibla_angle'),
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37)],
                ).createShader(bounds),
                child: Text(
                  '${_qiblaBearing.toStringAsFixed(1)}°',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_userLat.toStringAsFixed(4)}°N, ${_userLng.toStringAsFixed(4)}°E',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final bool bold;
  const _CompassLabel({required this.text, required this.color, required this.size, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      ),
    );
  }
}
