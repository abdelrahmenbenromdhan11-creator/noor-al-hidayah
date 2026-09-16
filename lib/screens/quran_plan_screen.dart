import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/language_manager.dart';

class QuranPlanScreen extends StatefulWidget {
  const QuranPlanScreen({super.key});
  @override
  State<QuranPlanScreen> createState() => _QuranPlanScreenState();
}

class _QuranPlanScreenState extends State<QuranPlanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int? _selectedDays;
  int _completedDays = 0;
  bool _todayDone = false;
  final int totalPages = 604;

  final List<Map<String, dynamic>> _plans = [
    {'days': 30, 'icon': Icons.speed, 'color': const Color(0xFFFF6B6B), 'key': 'one_month'},
    {'days': 60, 'icon': Icons.trending_up, 'color': const Color(0xFFFFA500), 'key': 'two_months'},
    {'days': 90, 'icon': Icons.calendar_view_month, 'color': const Color(0xFF4ECDC4), 'key': 'three_months'},
    {'days': 180, 'icon': Icons.calendar_month, 'color': const Color(0xFF95E1D3), 'key': 'six_months'},
    {'days': 365, 'icon': Icons.event_note, 'color': const Color(0xFFD4AF37), 'key': 'one_year'},
  ];

  int get _pagesPerDay => _selectedDays == null ? 0 : (totalPages / _selectedDays!).ceil();
  double get _progress => _selectedDays == null ? 0 : _completedDays / _selectedDays!;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _startPlan(int days) {
    setState(() {
      _selectedDays = days;
      _completedDays = 0;
      _todayDone = false;
    });
  }

  void _markToday() {
    if (!_todayDone) {
      setState(() {
        _todayDone = true;
        _completedDays++;
      });
    }
  }

  void _resetPlan() {
    setState(() {
      _selectedDays = null;
      _completedDays = 0;
      _todayDone = false;
    });
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
                LanguageManager.t('quran_plan_title'),
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: _selectedDays == null ? _buildPlanSelection(isAr) : _buildActivePlan(isAr),
          ),
        );
      },
    );
  }

  Widget _buildPlanSelection(bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildIntroCard(isAr),
        const SizedBox(height: 24),
        ..._plans.map((p) => _buildPlanCard(p, isAr)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIntroCard(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
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
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.5 * glow),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book, color: Color(0xFF0B2B26), size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageManager.t('choose_your_plan'),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                LanguageManager.t('plan_calc_note'),
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p, bool isAr) {
    final days = p['days'] as int;
    final pagesPerDay = (totalPages / days).ceil();
    final color = p['color'] as Color;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () => _startPlan(days),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(const Color(0xFF143B32), color.withOpacity(0.15), glow * 0.5)!,
                  const Color(0xFF0B2B26),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.4 + 0.4 * glow),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15 + 0.15 * glow),
                  blurRadius: 12 + 8 * glow,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.25), color.withOpacity(0.05)],
                    ),
                    border: Border.all(color: color, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4 * glow),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(p['icon'], color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageManager.t(p['key'] as String),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.description, color: color, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '$pagesPerDay ${LanguageManager.t('pages_day')}',
                            style: GoogleFonts.cairo(color: color, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                  ),
                  child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivePlan(bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProgressCircle(isAr),
        const SizedBox(height: 30),
        _buildWirdCard(isAr),
        const SizedBox(height: 20),
        _buildCompleteButton(isAr),
        const SizedBox(height: 24),
        _buildDaysGridSection(isAr),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: _resetPlan,
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            label: Text(
              LanguageManager.t('new_plan'),
              style: GoogleFonts.cairo(color: const Color(0xFFD4AF37), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCircle(bool isAr) {
    return Center(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glow = _glowController.value;
          return SizedBox(
            width: 220, height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220, height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.15 * glow),
                        blurRadius: 25 + 15 * glow,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 220, height: 220,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 12,
                    backgroundColor: const Color(0xFF143B32),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  ),
                ),
                Container(
                  width: 170, height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF143B32),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37)],
                        ).createShader(bounds),
                        child: Text(
                          '${(_progress * 100).toInt()}%',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_completedDays / $_selectedDays',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWirdCard(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                LanguageManager.t('today_wird'),
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statBox(LanguageManager.t('pages_unit'), '$_pagesPerDay', Icons.description, const Color(0xFFD4AF37)),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statBox(LanguageManager.t('parts_unit'), (_pagesPerDay / 20).toStringAsFixed(1), Icons.book, const Color(0xFF4ECDC4)),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statBox(LanguageManager.t('start_page'), '${_completedDays * _pagesPerDay + 1}', Icons.play_arrow, const Color(0xFF95E1D3)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildCompleteButton(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: _markToday,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: _todayDone
                  ? const LinearGradient(colors: [Color(0xFF1E4D40), Color(0xFF143B32)])
                  : LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37),
                        Color.lerp(const Color(0xFFE8C766), const Color(0xFFFFE9A8), glow)!,
                        const Color(0xFFD4AF37),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3 + 0.3 * glow),
                  blurRadius: 15 + 8 * glow,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _todayDone ? Icons.check_circle : Icons.touch_app,
                  color: _todayDone ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                  size: 26,
                ),
                const SizedBox(width: 10),
                Text(
                  _todayDone
                      ? '${LanguageManager.t('mark_completed')} ✓'
                      : LanguageManager.t('mark_completed'),
                  style: GoogleFonts.cairo(
                    color: _todayDone ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaysGridSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.15),
              ),
              child: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              LanguageManager.t('daily_progress'),
              style: GoogleFonts.cairo(
                color: const Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final displayDays = _selectedDays! > 60 ? 60 : _selectedDays!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(displayDays, (i) {
        final isDone = i < _completedDays;
        final isToday = i == _completedDays - 1 && _todayDone;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: isDone
                ? LinearGradient(
                    colors: isToday
                        ? [const Color(0xFFFFE9A8), const Color(0xFFD4AF37)]
                        : [const Color(0xFFD4AF37), const Color(0xFFB8860B)],
                  )
                : null,
            color: isDone ? null : const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDone ? const Color(0xFFD4AF37) : Colors.white12,
              width: 1,
            ),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Color(0xFF0B2B26), size: 16)
                : Text('${i + 1}', style: GoogleFonts.cairo(color: Colors.white38, fontSize: 11)),
          ),
        );
      }),
    );
  }
}
