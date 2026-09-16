import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/language_manager.dart';

class FastingScreen extends StatefulWidget {
  const FastingScreen({super.key});
  @override
  State<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends State<FastingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final Set<String> _fastedDays = {};
  String _selectedMonth = 'ramadan';
  final int _year = 1447;
  final List<String> _months = ['ramadan', 'shaban', 'shawwal', 'dhulqidah', 'dhulhijjah', 'muharram'];

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

  List<Map<String, dynamic>> get _fastingTypes => [
    {'name': LanguageManager.t('fasting_ramadan'), 'icon': Icons.nightlight_round, 'color': const Color(0xFFD4AF37), 'desc': LanguageManager.t('fasting_obligatory')},
    {'name': LanguageManager.t('fasting_monday_thursday'), 'icon': Icons.calendar_today, 'color': const Color(0xFF4ECDC4), 'desc': LanguageManager.t('fasting_sunnah')},
    {'name': LanguageManager.t('fasting_white_days'), 'icon': Icons.brightness_3, 'color': const Color(0xFF95E1D3), 'desc': LanguageManager.t('white_days_desc')},
    {'name': LanguageManager.t('fasting_arafah'), 'icon': Icons.star, 'color': const Color(0xFFFFA500), 'desc': LanguageManager.t('arafah_desc')},
    {'name': LanguageManager.t('fasting_ashura'), 'icon': Icons.water_drop, 'color': const Color(0xFFFF6B6B), 'desc': LanguageManager.t('ashura_desc')},
    {'name': LanguageManager.t('fasting_voluntary'), 'icon': Icons.favorite, 'color': const Color(0xFFD4AF37), 'desc': LanguageManager.t('voluntary_desc')},
  ];

  int get _daysInMonth => 30;

  void _toggleDay(int day) {
    setState(() {
      final key = '$_year-$_selectedMonth-$day';
      _fastedDays.contains(key) ? _fastedDays.remove(key) : _fastedDays.add(key);
    });
  }

  bool _isFasted(int day) => _fastedDays.contains('$_year-$_selectedMonth-$day');

  int _countFasted() => List.generate(_daysInMonth, (i) => _isFasted(i + 1)).where((v) => v).length;

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
                LanguageManager.t('fasting_tracker'),
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProgressCard(isAr),
                const SizedBox(height: 20),
                _buildMonthSelector(),
                const SizedBox(height: 20),
                _buildSectionTitle(LanguageManager.t('days_of_month'), Icons.calendar_month),
                const SizedBox(height: 12),
                _buildDaysGrid(),
                const SizedBox(height: 28),
                _buildSectionTitle(LanguageManager.t('fasting_types'), Icons.list_alt),
                const SizedBox(height: 12),
                ..._fastingTypes.map((f) => _buildFastingTypeCard(f)).toList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
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
            children: [
              SizedBox(
                width: 90, height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90, height: 90,
                      child: CircularProgressIndicator(
                        value: _countFasted() / _daysInMonth,
                        strokeWidth: 8,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_countFasted()}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFFD4AF37),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          '/ $_daysInMonth',
                          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_year هـ',
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _countFasted() == _daysInMonth
                            ? LanguageManager.t('month_completed')
                            : '${LanguageManager.t('remaining_days')} ${_daysInMonth - _countFasted()} ${LanguageManager.t('day_unit')}',
                        style: GoogleFonts.cairo(color: const Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        itemBuilder: (context, i) {
          final isSelected = _months[i] == _selectedMonth;
          return GestureDetector(
            onTap: () => setState(() => _selectedMonth = _months[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                    : null,
                color: isSelected ? null : const Color(0xFF143B32),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  LanguageManager.t('month_${_months[i]}'),
                  style: GoogleFonts.cairo(
                    color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD4AF37).withOpacity(0.15),
          ),
          child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: const Color(0xFFD4AF37),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _daysInMonth,
      itemBuilder: (context, i) {
        final day = i + 1;
        final isFasted = _isFasted(day);
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              gradient: isFasted
                  ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                  : null,
              color: isFasted ? null : const Color(0xFF143B32),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFasted ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
              ),
              boxShadow: isFasted
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isFasted
                  ? const Icon(Icons.check, color: Color(0xFF0B2B26), size: 18)
                  : Text(
                      '$day',
                      style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFastingTypeCard(Map<String, dynamic> f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (f['color'] as Color).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: (f['color'] as Color).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: (f['color'] as Color).withOpacity(0.4)),
            ),
            child: Icon(f['icon'], color: f['color'], size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['name'],
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  f['desc'],
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
