import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class QuranPlanScreen extends StatefulWidget {
  const QuranPlanScreen({super.key});
  @override
  State<QuranPlanScreen> createState() => _QuranPlanScreenState();
}

class _QuranPlanScreenState extends State<QuranPlanScreen> {
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
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('quran_plan_title'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: _selectedDays == null ? _buildPlanSelection() : _buildActivePlan(),
      ),
    );
  }

  Widget _buildPlanSelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            children: [
              const Icon(Icons.menu_book, color: Color(0xFFD4AF37), size: 48),
              const SizedBox(height: 12),
              Text(LanguageManager.t('choose_your_plan'),
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(LanguageManager.t('plan_calc_note'),
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ..._plans.map((p) => _buildPlanCard(p)).toList(),
      ],
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> p) {
    final days = p['days'] as int;
    final pagesPerDay = (totalPages / days).ceil();
    return GestureDetector(
      onTap: () => _startPlan(days),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF143B32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (p['color'] as Color).withOpacity(0.4), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                color: (p['color'] as Color).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(p['icon'], color: p['color'], size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanguageManager.t(p['key'] as String),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$pagesPerDay ${LanguageManager.t('pages_day')}',
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: p['color'], size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePlan() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 220, height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220, height: 220,
                  child: CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 14,
                    backgroundColor: const Color(0xFF143B32),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${(_progress * 100).toInt()}%',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 42, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$_completedDays / $_selectedDays',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            children: [
              Text(LanguageManager.t('today_wird'),
                  style: const TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn(LanguageManager.t('pages_unit'), '$_pagesPerDay', Icons.description),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statColumn(LanguageManager.t('parts_unit'),
                      (_pagesPerDay / 20).toStringAsFixed(1), Icons.book),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statColumn(LanguageManager.t('start_page'),
                      '${_completedDays * _pagesPerDay + 1}', Icons.play_arrow),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _markToday,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: _todayDone ? const Color(0xFF1E4D40) : const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_todayDone ? Icons.check_circle : Icons.touch_app,
                    color: _todayDone ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26), size: 26),
                const SizedBox(width: 10),
                Text(
                  _todayDone
                      ? '${LanguageManager.t('mark_completed')} ✓'
                      : LanguageManager.t('mark_completed'),
                  style: TextStyle(
                    color: _todayDone ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(LanguageManager.t('daily_progress'),
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDaysGrid(),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: _resetPlan,
            icon: const Icon(Icons.refresh, color: Colors.white54),
            label: Text(LanguageManager.t('new_plan'),
                style: const TextStyle(color: Colors.white54)),
          ),
        ),
      ],
    );
  }

  Widget _statColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
        return Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isDone
                ? (isToday ? const Color(0xFFD4AF37) : const Color(0xFF1E4D40))
                : const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDone ? const Color(0xFFD4AF37) : Colors.white12,
              width: 1,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Color(0xFFD4AF37), size: 16)
                : Text('${i + 1}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
        );
      }),
    );
  }
}
