import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import 'qibla_screen.dart';
import 'zakat_screen.dart';
import 'quran_plan_screen.dart';
import 'fasting_screen.dart';
import 'noor_data.dart';
import 'prayer_tracker_screen.dart';
import 'daily_goals_screen.dart';
import 'hijri_calendar_screen.dart';
import 'guidance_list_screen.dart';
import 'islamic_guidance_data.dart';
import 'hadith_screen.dart';
import 'asmaa_allah_screen.dart';
import 'nearby_mosques_screen.dart';
import '../services/prayer_service.dart';
import '../services/user_progress_service.dart';
import '../i18n/language_manager.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});
  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  Map<String, DateTime>? _times;
  Position? _position;
  bool _loading = true;
  String? _error;

  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _load();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final pos = await PrayerService.getLocation(forceRefresh: true);
    if (pos == null) {
      setState(() {
        _loading = false;
        _error = LanguageManager.t('location_denied');
      });
      return;
    }
    final times = PrayerService.calculatePrayerTimes(pos);
    setState(() {
      _position = pos;
      _times = times;
      _loading = false;
    });
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        if (_loading) return _buildLoading();
        if (_error != null) return _buildError();

        return RefreshIndicator(
          onRefresh: _load,
          color: const Color(0xFFD4AF37),
          backgroundColor: const Color(0xFF143B32),
          child: FadeTransition(
            opacity: _fadeIn,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNextPrayerBar(),
                const SizedBox(height: 18),
                _buildPrayerTimesCard(),
                const SizedBox(height: 22),
                _buildAllCircles(),
                const SizedBox(height: 22),
                _buildPrayerTrackerCircle(),
                const SizedBox(height: 14),
                _buildDailyGoalsCircle(),
                const SizedBox(height: 22),
                _buildHijriCard(),
                const SizedBox(height: 22),
                _buildNoorCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80, height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 80, height: 80,
                  child: CircularProgressIndicator(
                    color: Color(0xFFD4AF37),
                    strokeWidth: 3,
                    backgroundColor: Color(0xFF143B32),
                  ),
                ),
                Container(
                  width: 55, height: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                  ),
                  child: const Icon(Icons.mosque, color: Color(0xFFD4AF37), size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            LanguageManager.currentLanguage.value == 'ar'
                ? 'جاري تحديد موقعك...'
                : 'Detecting your location...',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
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
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16, height: 1.6),
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

  // ═══════════ شريط الصلاة القادمة ═══════════
  Widget _buildNextPrayerBar() {
    final next = PrayerService.getNextPrayer(_times!);
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    final nextName = isAr ? next['name_ar'] : next['name_en'];

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFD4AF37).withOpacity(0.5),
                const Color(0xFFFFE9A8),
                glow,
              )!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2 + 0.5 * glow),
                blurRadius: 20 + 15 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                      const Color(0xFFB8860B),
                    ],
                  ),
                ),
                child: const Icon(Icons.mosque, color: Color(0xFF0B2B26), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LanguageManager.t('next_prayer'),
                      style: GoogleFonts.cairo(
                          color: Colors.white60, fontSize: 11, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextName,
                      style: GoogleFonts.amiri(
                        color: const Color(0xFFD4AF37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PrayerService.formatTime(next['time']),
                    style: GoogleFonts.cairo(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined,
                          color: Color(0xFFD4AF37), size: 11),
                      const SizedBox(width: 4),
                      Text(
                        PrayerService.timeRemaining(next['time']),
                        style: GoogleFonts.cairo(
                            color: const Color(0xFFD4AF37),
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ مربع أوقات الصلاة ═══════════
  Widget _buildPrayerTimesCard() {
    final next = PrayerService.getNextPrayer(_times!);
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFD4AF37).withOpacity(0.3),
                const Color(0xFFFFE9A8).withOpacity(0.7),
                glow,
              )!,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                      ),
                      child: const Icon(Icons.schedule, color: Color(0xFFD4AF37), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LanguageManager.t('prayer_times_today'),
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _prayerRow('fajr', LanguageManager.t('fajr'), _times!['fajr']!,
                    Icons.wb_twilight, next['key'] == 'fajr', glow),
                const SizedBox(height: 8),
                _prayerRow('dhuhr', LanguageManager.t('dhuhr'), _times!['dhuhr']!,
                    Icons.wb_sunny, next['key'] == 'dhuhr', glow),
                const SizedBox(height: 8),
                _prayerRow('asr', LanguageManager.t('asr'), _times!['asr']!,
                    Icons.wb_cloudy, next['key'] == 'asr', glow),
                const SizedBox(height: 8),
                _prayerRow('maghrib', LanguageManager.t('maghrib'), _times!['maghrib']!,
                    Icons.wb_twilight, next['key'] == 'maghrib', glow),
                const SizedBox(height: 8),
                _prayerRow('isha', LanguageManager.t('isha'), _times!['isha']!,
                    Icons.nights_stay, next['key'] == 'isha', glow),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _prayerRow(String key, String name, DateTime time, IconData icon,
      bool isNext, double glow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isNext
            ? const Color(0xFFD4AF37).withOpacity(0.1)
            : const Color(0xFF0B2B26).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: isNext
            ? Border.all(
                color: Color.lerp(
                  const Color(0xFFD4AF37).withOpacity(0.5),
                  const Color(0xFFFFE9A8),
                  glow,
                )!,
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isNext
                  ? const Color(0xFFD4AF37).withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
            ),
            child: Icon(icon,
                color: isNext ? const Color(0xFFD4AF37) : Colors.white54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.cairo(
                color: isNext ? const Color(0xFFD4AF37) : Colors.white,
                fontSize: 15,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            PrayerService.formatTime(time),
            style: GoogleFonts.cairo(
              color: isNext ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.notifications_active,
              color: isNext ? const Color(0xFFD4AF37) : Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildOrnateCircle({
    required IconData icon,
    required String label,
    required Widget page,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          child: Column(
            children: [
              SizedBox(
                width: 72, height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: color.withOpacity(0.4 + 0.4 * glow), width: 1),
                      ),
                    ),
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.15 + 0.15 * glow),
                            Colors.transparent
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: color, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3 + 0.3 * glow),
                            blurRadius: 10 + 8 * glow,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.cairo(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ كل الدوائر (صفان × 5) ═══════════
  Widget _buildAllCircles() {
    final isAr = LanguageManager.currentLanguage.value == 'ar';

    // الصف الأول
    final row1 = [
      _circle(Icons.explore, LanguageManager.t('qibla'), const QiblaScreen(), const Color(0xFFD4AF37)),
      _circle(Icons.calculate, LanguageManager.t('zakat'), const ZakatScreen(), const Color(0xFF4ECDC4)),
      _circle(Icons.menu_book, LanguageManager.t('quran_plan'), const QuranPlanScreen(), const Color(0xFF95E1D3)),
      _circle(Icons.nightlight, LanguageManager.t('fasting'), const FastingScreen(), const Color(0xFFFFA500)),
      _circle(Icons.auto_awesome, isAr ? 'أسماء الله' : 'Names', const AsmaaAllahScreen(), const Color(0xFFD4AF37)),
    ];

    // الصف الثاني
    final row2 = [
      _circle(Icons.auto_stories, isAr ? 'أحاديث' : 'Hadiths', const HadithScreen(), const Color(0xFF4ECDC4)),
      _circle(Icons.block, isAr ? 'محرمات' : 'Haram',
        GuidanceListScreen(titleAr: 'المحرمات', titleEn: 'Forbidden', icon: Icons.block, color: const Color(0xFFFF6B6B), items: haramList),
        const Color(0xFFFF6B6B)),
      _circle(Icons.warning_amber, isAr ? 'مكروهات' : 'Makruh',
        GuidanceListScreen(titleAr: 'المكروهات', titleEn: 'Disliked', icon: Icons.warning_amber, color: const Color(0xFFFFA500), items: makruhList),
        const Color(0xFFFFA500)),
      _circle(Icons.do_not_disturb_on, isAr ? 'لا يجوز' : 'Not Allowed',
        GuidanceListScreen(titleAr: 'لا يجوز فعلها', titleEn: 'Not Permitted', icon: Icons.do_not_disturb_on, color: const Color(0xFF9B59B6), items: forbiddenList),
        const Color(0xFF9B59B6)),
      _circle(Icons.location_on, isAr ? 'مساجد' : 'Mosques', const NearbyMosquesScreen(), const Color(0xFF2ECC71)),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row1.map((w) => Expanded(child: Center(child: w))).toList(),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row2.map((w) => Expanded(child: Center(child: w))).toList(),
        ),
      ],
    );
  }

  Widget _circle(IconData icon, String label, Widget page, Color color) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          child: Column(
            children: [
              SizedBox(
                width: 58, height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.3 + 0.4 * glow), width: 1),
                      ),
                    ),
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.15 + 0.15 * glow), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: color, width: 1.3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3 + 0.3 * glow),
                            blurRadius: 8 + 6 * glow,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ تتبع الصلوات (بيانات حقيقية) ═══════════
  Widget _buildPrayerTrackerCircle() {
    return ValueListenableBuilder<int>(
      valueListenable: UserProgressService.notifier,
      builder: (context, _, __) {
        return FutureBuilder<int>(
          future: UserProgressService.getTodayPrayersCount(),
          builder: (context, snapshot) {
            final done = snapshot.data ?? 0;
            const total = 5;
            final progress = done / total;

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrayerTrackerScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      width: 1.5),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70, height: 70,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70, height: 70,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFD4AF37)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$done',
                                  style: GoogleFonts.cairo(
                                      color: const Color(0xFFD4AF37),
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1)),
                              Text('/ $total',
                                  style: GoogleFonts.cairo(
                                      color: Colors.white54, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LanguageManager.t('prayer_tracker_title'),
                            style: GoogleFonts.cairo(
                              color: const Color(0xFFD4AF37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            LanguageManager.currentLanguage.value == 'ar'
                                ? 'تتبع صلواتك اليومية'
                                : 'Track your daily prayers',
                            style: GoogleFonts.cairo(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFFD4AF37), size: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════ الأهداف اليومية (بيانات حقيقية) ═══════════
  Widget _buildDailyGoalsCircle() {
    return ValueListenableBuilder<int>(
      valueListenable: UserProgressService.notifier,
      builder: (context, _, __) {
        return FutureBuilder<int>(
          future: UserProgressService.getTodayGoalsCount(),
          builder: (context, snapshot) {
            final done = snapshot.data ?? 0;
            final total = UserProgressService.totalGoals;
            final progress = done / total;
            final isComplete = done >= total;

            return AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = _glowController.value;
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DailyGoalsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isComplete
                            ? [const Color(0xFF1E4D40), const Color(0xFF0B2B26)]
                            : [
                                Color.lerp(const Color(0xFF143B32),
                                    const Color(0xFF2B6E5C), glow * 0.6)!,
                                const Color(0xFF0B2B26),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isComplete
                            ? Colors.green.withOpacity(0.6)
                            : Color.lerp(
                                const Color(0xFFD4AF37).withOpacity(0.4),
                                const Color(0xFFFFE9A8),
                                glow,
                              )!,
                        width: 2,
                      ),
                      boxShadow: isComplete
                          ? []
                          : [
                              BoxShadow(
                                color: const Color(0xFFD4AF37)
                                    .withOpacity(0.15 + 0.4 * glow),
                                blurRadius: 15 + 15 * glow,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70, height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70, height: 70,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isComplete
                                        ? Colors.green
                                        : Color.lerp(
                                            const Color(0xFFD4AF37),
                                            const Color(0xFFFFE9A8),
                                            glow)!,
                                  ),
                                ),
                              ),
                              Icon(
                                isComplete ? Icons.check_circle : Icons.flag,
                                color: isComplete
                                    ? Colors.green
                                    : Color.lerp(const Color(0xFFD4AF37),
                                        const Color(0xFFFFE9A8), glow),
                                size: 32,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageManager.t('daily_goals_title'),
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFFD4AF37),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isComplete
                                    ? (LanguageManager.currentLanguage.value ==
                                            'ar'
                                        ? 'أكملت جميع الأهداف! 🎉'
                                        : 'All goals completed! 🎉')
                                    : (LanguageManager.currentLanguage.value ==
                                            'ar'
                                        ? '$done من $total مكتمل'
                                        : '$done of $total completed'),
                                style: GoogleFonts.cairo(
                                  color: isComplete
                                      ? Colors.green
                                      : Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFFD4AF37), size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ═══════════ التقويم الهجري ═══════════
  Widget _buildHijriCard() {
    final today = HijriCalendar.now();
    final isAr = LanguageManager.currentLanguage.value == 'ar';

    final hijriMonthsAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    final hijriMonthsEn = [
      'Muharram', 'Safar', 'Rabi I', 'Rabi II',
      'Jumada I', 'Jumada II', 'Rajab', 'Shaban',
      'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'
    ];
    final monthIdx = (today.hMonth - 1).clamp(0, 11);
    final monthName = isAr ? hijriMonthsAr[monthIdx] : hijriMonthsEn[monthIdx];
    final hijri = '${today.hDay} $monthName ${today.hYear} هـ';

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFFD4AF37).withOpacity(0.3),
                  const Color(0xFFFFE9A8).withOpacity(0.8),
                  glow,
                )!,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(const Color(0xFFD4AF37),
                            const Color(0xFFFFE9A8), glow)!,
                        const Color(0xFFB8860B),
                      ],
                    ),
                  ),
                  child: const Icon(Icons.calendar_month,
                      color: Color(0xFF0B2B26), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'التقويم الهجري' : 'Hijri Calendar',
                        style: GoogleFonts.cairo(
                            color: Colors.white60, fontSize: 11),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hijri,
                        style: GoogleFonts.amiri(
                          color: const Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Color(0xFFD4AF37), size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════ نور اليوم ═══════════
  Widget _buildNoorCard() {
    final noor = getTodayNoor();
    final isAr = LanguageManager.currentLanguage.value == 'ar';

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C),
                    glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                const Color(0xFFD4AF37).withOpacity(0.5),
                const Color(0xFFFFE9A8),
                glow,
              )!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.35 * glow),
                blurRadius: 18 + 15 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFFD4AF37),
                                const Color(0xFFFFE9A8), glow)!,
                            const Color(0xFFB8860B),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.wb_sunny,
                          color: Color(0xFF0B2B26), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      LanguageManager.t('noor_today'),
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNoorItem(Icons.menu_book, const Color(0xFF4ECDC4),
                    isAr ? noor.ayahAr : noor.ayahEn, noor.ayahRef, isAr),
                const SizedBox(height: 10),
                _buildNoorItem(Icons.auto_stories, const Color(0xFF4ECDC4),
                    isAr ? noor.hadithAr : noor.hadithEn, noor.hadithRef, isAr),
                const SizedBox(height: 10),
                _buildNoorItem(Icons.volunteer_activism, const Color(0xFFFFA500),
                    isAr ? noor.duaAr : noor.duaEn, null, isAr),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isAr ? noor.dhikrAr : noor.dhikrEn,
                          style: GoogleFonts.cairo(
                            color: const Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: isAr ? TextAlign.right : TextAlign.left,
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

  Widget _buildNoorItem(IconData icon, Color color, String text, String? ref, bool isAr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2B26).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13.5,
                    height: 1.7,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
          if (ref != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Text(
                '— $ref',
                style: GoogleFonts.cairo(
                    color: color.withOpacity(0.75), fontSize: 10),
                textAlign: isAr ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
