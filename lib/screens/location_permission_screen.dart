import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';
import '../widgets/islamic_background.dart';

class LocationPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  const LocationPermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _error;
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() { _loading = true; _error = null; });

    final position = await LocationService.getCurrentLocation(forceRefresh: true);

    if (position != null) {
      if (mounted) {
        widget.onPermissionGranted();
      }
    } else {
      setState(() {
        _loading = false;
        _error = 'لم نتمكن من تحديد موقعك.\nيرجى التأكد من تفعيل GPS والأذونات.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IslamicBackground(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF143B32).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة الموقع
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFD4AF37).withOpacity(0.2),
                                const Color(0xFFD4AF37).withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Color(0xFFD4AF37),
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // العنوان
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFB8860B),
                              Color(0xFFFFE9A8),
                              Color(0xFFD4AF37),
                              Color(0xFFFFE9A8),
                              Color(0xFFB8860B),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'تفعيل الموقع',
                            style: GoogleFonts.amiri(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'لكي نحسب لك أوقات الصلاة بدقة\nواتجاه القبلة نحو الكعبة',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // مميزات
                        _feature(Icons.access_time, 'أوقات صلاة دقيقة حسب مدينتك'),
                        _feature(Icons.explore, 'اتجاه القبلة الحقيقي نحو مكة'),
                        _feature(Icons.notifications_active, 'تنبيهات الأذان في وقتها'),

                        const SizedBox(height: 30),

                        // الخطأ
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // زر التفعيل
                        SizedBox(
                          width: double.infinity,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _loading ? null : _requestLocation,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFE8C766),
                                      Color(0xFFD4AF37),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: _loading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 24, height: 24,
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF0B2B26),
                                            strokeWidth: 2.5,
                                          ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.my_location,
                                              color: Color(0xFF0B2B26), size: 22),
                                          const SizedBox(width: 10),
                                          Text(
                                            'تفعيل الموقع الآن',
                                            style: GoogleFonts.cairo(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0B2B26),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          '🔒 موقعك محفوظ على جهازك فقط',
                          style: GoogleFonts.cairo(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.15),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
