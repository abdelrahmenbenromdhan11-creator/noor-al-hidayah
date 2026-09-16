import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import '../i18n/language_manager.dart';

enum FastingStatus { none, recommended, forbidden }

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});
  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  late int _hijriYear;
  late int _hijriMonth;
  late int _hijriDay;

  final List<String> _hijriMonthsAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];
  final List<String> _hijriMonthsEn = [
    'Muharram', 'Safar', 'Rabi I', 'Rabi II',
    'Jumada I', 'Jumada II', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhul-Qadah', 'Dhul-Hijjah'
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // استخدام المكتبة للحصول على التاريخ الحقيقي
    final today = HijriCalendar.now();
    _hijriYear = today.hYear;
    _hijriMonth = today.hMonth;
    _hijriDay = today.hDay;
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  // تحويل هجري → ميلادي باستخدام المكتبة
  // ═══════════════════════════════════════════════════════
  DateTime _hijriToGregorian(int hYear, int hMonth, int hDay) {
    try {
      final hijri = HijriCalendar()
        ..hYear = hYear
        ..hMonth = hMonth
        ..hDay = hDay;
      return hijri.hijriToGregorian(hYear, hMonth, hDay);
    } catch (e) {
      // fallback
      return HijriCalendar.fromDate(DateTime(hYear, hMonth, hDay))
          .hijriToGregorian(hYear, hMonth, hDay);
    }
  }

  int _daysInHijriMonth(int hYear, int hMonth) {
    try {
      final hijri = HijriCalendar()
        ..hYear = hYear
        ..hMonth = hMonth
        ..hDay = 1;
      return hijri.lengthOfMonth;
    } catch (e) {
      return 30;
    }
  }

  // ═══════════════════════════════════════════════════════
  // تحديد حالة الصيام
  // ═══════════════════════════════════════════════════════
  FastingStatus _fastingStatus(int hMonth, int hDay, DateTime gregDate) {
    // ───── ممنوع ─────
    if (hMonth == 10 && hDay == 1) return FastingStatus.forbidden; // عيد الفطر
    if (hMonth == 12 && hDay == 10) return FastingStatus.forbidden; // عيد الأضحى
    if (hMonth == 12 && hDay >= 11 && hDay <= 13) {
      return FastingStatus.forbidden; // أيام التشريق
    }

    // ───── مستحب ─────
    if (hMonth == 9) return FastingStatus.recommended; // رمضان

    // الإثنين والخميس
    if (gregDate.weekday == DateTime.monday ||
        gregDate.weekday == DateTime.thursday) {
      return FastingStatus.recommended;
    }

    // الأيام البيض: 13، 14، 15
    if (hDay == 13 || hDay == 14 || hDay == 15) {
      return FastingStatus.recommended;
    }

    // عاشوراء: 9، 10، 11 محرم
    if (hMonth == 1 && (hDay == 9 || hDay == 10 || hDay == 11)) {
      return FastingStatus.recommended;
    }

    // 6 أيام من شوال
    if (hMonth == 10 && hDay >= 2 && hDay <= 7) {
      return FastingStatus.recommended;
    }

    // أول 9 أيام ذي الحجة
    if (hMonth == 12 && hDay >= 1 && hDay <= 9) {
      return FastingStatus.recommended;
    }

    return FastingStatus.none;
  }

  bool _isToday(int day) {
    return day == _hijriDay &&
        _hijriMonth == HijriCalendar.now().hMonth &&
        _hijriYear == HijriCalendar.now().hYear;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        final monthName =
            isAr ? _hijriMonthsAr[_hijriMonth - 1] : _hijriMonthsEn[_hijriMonth - 1];
        final isRamadan = _hijriMonth == 9;

        return Directionality(
          textDirection:
              LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                isAr ? 'التقويم الهجري' : 'Hijri Calendar',
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMonthSelector(isAr),
                const SizedBox(height: 20),
                _buildMonthHeader(monthName, isRamadan, isAr),
                const SizedBox(height: 20),
                _buildWeekDayRow(isAr),
                const SizedBox(height: 12),
                _buildDaysGrid(isAr),
                const SizedBox(height: 20),
                _buildLegend(isAr),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector(bool isAr) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, i) {
          final monthIdx = i;
          final isSelected = monthIdx == _hijriMonth - 1;
          final isRamadan = monthIdx == 8;

          return GestureDetector(
            onTap: () => setState(() => _hijriMonth = monthIdx + 1),
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                    : null,
                color: isSelected ? null : const Color(0xFF143B32),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  if (isRamadan)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.nightlight_round,
                          color: Color(0xFFD4AF37), size: 14),
                    ),
                  Text(
                    isAr ? _hijriMonthsAr[monthIdx] : _hijriMonthsEn[monthIdx],
                    style: GoogleFonts.cairo(
                      color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(String monthName, bool isRamadan, bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRamadan
                  ? [
                      Color.lerp(const Color(0xFFD4AF37),
                          const Color(0xFFFFE9A8), glow)!,
                      const Color(0xFF8B6914),
                      const Color(0xFF0B2B26),
                    ]
                  : const [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37),
                  const Color(0xFFFFE9A8), glow)!,
              width: isRamadan ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2 + 0.4 * glow),
                blurRadius: 20 + 15 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              if (isRamadan)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nightlight_round,
                          color: Color.lerp(const Color(0xFFD4AF37),
                              const Color(0xFFFFE9A8), glow),
                          size: 28),
                      const SizedBox(width: 8),
                      Icon(Icons.star,
                          color: Color.lerp(const Color(0xFFD4AF37),
                              const Color(0xFFFFE9A8), glow),
                          size: 24),
                      const SizedBox(width: 8),
                      Icon(Icons.nightlight_round,
                          color: Color.lerp(const Color(0xFFD4AF37),
                              const Color(0xFFFFE9A8), glow),
                          size: 28),
                    ],
                  ),
                ),
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
                  monthName,
                  style: GoogleFonts.amiri(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_hijriYear ${isAr ? 'هـ' : 'AH'}',
                style: GoogleFonts.cairo(
                  color:
                      isRamadan ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRamadan)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    isAr ? 'شهر رمضان المبارك 🌙' : 'Blessed Ramadan 🌙',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFF0B2B26),
                      fontSize: 14,
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

  Widget _buildWeekDayRow(bool isAr) {
    // دائماً بالأحرف الإنجليزية - الأحد أولاً (أحمر)
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final colors = [
      Colors.redAccent,
      const Color(0xFFD4AF37),
      const Color(0xFFD4AF37),
      const Color(0xFFD4AF37),
      const Color(0xFFD4AF37),
      const Color(0xFFD4AF37),
      const Color(0xFFD4AF37),
    ];

    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Center(
            child: Text(
              labels[i],
              style: GoogleFonts.cairo(
                color: colors[i],
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDaysGrid(bool isAr) {
    final daysInMonth = _daysInHijriMonth(_hijriYear, _hijriMonth);
    final monthStart = _hijriToGregorian(_hijriYear, _hijriMonth, 1);
    final firstDayOffset = monthStart.weekday % 7; // Sunday=0

    final totalCells = firstDayOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - firstDayOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 58));
              }

              final gregDate =
                  _hijriToGregorian(_hijriYear, _hijriMonth, dayNumber);
              final status =
                  _fastingStatus(_hijriMonth, dayNumber, gregDate);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: _buildDayCell(
                    dayNumber: dayNumber,
                    isToday: _isToday(dayNumber),
                    status: status,
                    gregDate: gregDate,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell({
    required int dayNumber,
    required bool isToday,
    required FastingStatus status,
    required DateTime gregDate,
  }) {
    Color borderColor;
    Color textColor;
    Color bgColor;
    List<BoxShadow>? shadows;

    if (isToday) {
      borderColor = const Color(0xFFFFE9A8);
      textColor = const Color(0xFF0B2B26);
      bgColor = const Color(0xFFD4AF37);
      shadows = [
        BoxShadow(
          color: const Color(0xFFD4AF37).withOpacity(0.7),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ];
    } else if (status == FastingStatus.forbidden) {
      borderColor = Colors.redAccent.withOpacity(0.7);
      textColor = Colors.redAccent;
      bgColor = Colors.redAccent.withOpacity(0.08);
    } else if (status == FastingStatus.recommended) {
      borderColor = const Color(0xFFD4AF37).withOpacity(0.85);
      textColor = const Color(0xFFD4AF37);
      bgColor = const Color(0xFFD4AF37).withOpacity(0.1);
      shadows = [
        BoxShadow(
          color: const Color(0xFFD4AF37).withOpacity(0.25),
          blurRadius: 8,
        ),
      ];
    } else {
      borderColor = Colors.white.withOpacity(0.15);
      textColor = Colors.white70;
      bgColor = const Color(0xFF143B32).withOpacity(0.4);
    }

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isToday ? 2 : 1.3),
        boxShadow: shadows,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '$dayNumber',
              style: GoogleFonts.cairo(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (status == FastingStatus.recommended && !isToday)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.nightlight_round,
                  color: Color(0xFFD4AF37), size: 11),
            ),
          if (status == FastingStatus.forbidden)
            Positioned(
              top: 3,
              right: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nightlight_round,
                      color: Colors.redAccent.withOpacity(0.9), size: 11),
                  const SizedBox(width: 1),
                  Icon(Icons.block,
                      color: Colors.redAccent.withOpacity(0.9), size: 11),
                ],
              ),
            ),
          if (isToday)
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0B2B26),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'المفتاح' : 'Legend',
            style: GoogleFonts.cairo(
              color: const Color(0xFFD4AF37),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _legendRow(
            Icons.nightlight_round,
            const Color(0xFFD4AF37),
            isAr ? 'يوم يُستحب صيامه' : 'Recommended fasting day',
          ),
          const SizedBox(height: 8),
          _legendRow(
            Icons.nightlight_round,
            Colors.redAccent,
            isAr ? 'يوم لا يجوز صيامه' : 'Forbidden fasting day',
            trailing: Icons.block,
          ),
          const SizedBox(height: 8),
          _legendRow(
            Icons.circle,
            const Color(0xFFD4AF37),
            isAr ? 'اليوم الحالي' : 'Today',
          ),
        ],
      ),
    );
  }

  Widget _legendRow(IconData icon, Color color, String label,
      {IconData? trailing}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        if (trailing != null) ...[
          const SizedBox(width: 2),
          Icon(trailing, color: color, size: 14),
        ],
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
