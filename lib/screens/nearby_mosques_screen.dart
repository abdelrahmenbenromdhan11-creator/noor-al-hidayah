import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../services/prayer_service.dart';
import '../i18n/language_manager.dart';

class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});
  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  Position? _position;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await PrayerService.getLocation();
    setState(() {
      _position = pos;
      _loading = false;
    });
  }

  Future<void> _openMaps({required String query}) async {
    String url;
    if (_position != null) {
      url = 'https://www.google.com/maps/search/$query/@${_position!.latitude},${_position!.longitude},14z';
    } else {
      url = 'https://www.google.com/maps/search/$query';
    }
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  void dispose() {
    _glowController.dispose();
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
                isAr ? 'المساجد القريبة' : 'Nearby Mosques',
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // بطاقة العنوان
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          final glow = _glowController.value;
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2 + 0.3 * glow),
                                  blurRadius: 20 + 10 * glow,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                                        const Color(0xFF8B6914),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(Icons.mosque, color: Color(0xFF0B2B26), size: 40),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isAr ? 'اكتشف المساجد حولك' : 'Discover mosques around you',
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFFD4AF37),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                if (_position != null)
                                  Text(
                                    '📍 ${_position!.latitude.toStringAsFixed(3)}°N, ${_position!.longitude.toStringAsFixed(3)}°E',
                                    style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        isAr ? 'ابحث حسب النوع' : 'Search by Type',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildMapsButton(
                        icon: Icons.mosque,
                        color: const Color(0xFF4ECDC4),
                        titleAr: 'جميع المساجد القريبة',
                        titleEn: 'All Nearby Mosques',
                        onTap: () => _openMaps(query: 'mosques'),
                      ),
                      _buildMapsButton(
                        icon: Icons.star,
                        color: const Color(0xFFD4AF37),
                        titleAr: 'المساجد المميزة',
                        titleEn: 'Top Rated Mosques',
                        onTap: () => _openMaps(query: 'best+mosques'),
                      ),
                      _buildMapsButton(
                        icon: Icons.mosque_outlined,
                        color: const Color(0xFF95E1D3),
                        titleAr: 'المساجد الكبيرة',
                        titleEn: 'Grand Mosques',
                        onTap: () => _openMaps(query: 'grand+mosque'),
                      ),
                      _buildMapsButton(
                        icon: Icons.access_time,
                        color: const Color(0xFFFFA500),
                        titleAr: 'مساجد مفتوحة الآن',
                        titleEn: 'Open Now',
                        onTap: () => _openMaps(query: 'mosques+open+now'),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        isAr ? 'ملاحظة' : 'Note',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFD4AF37),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143B32),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isAr
                                    ? 'سيتم فتح تطبيق Google Maps لعرض المساجد حول موقعك'
                                    : 'Google Maps will open to show mosques near you',
                                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13, height: 1.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMapsButton({
    required IconData icon,
    required Color color,
    required String titleAr,
    required String titleEn,
    required VoidCallback onTap,
  }) {
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  isAr ? titleAr : titleEn,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.open_in_new, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
