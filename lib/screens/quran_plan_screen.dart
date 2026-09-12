import 'package:flutter/material.dart';

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
    {'days': 30, 'label': 'شهر واحد', 'icon': Icons.speed, 'color': Color(0xFFFF6B6B)},
    {'days': 60, 'label': 'شهران', 'icon': Icons.trending_up, 'color': Color(0xFFFFA500)},
    {'days': 90, 'label': '3 أشهر', 'icon': Icons.calendar_view_month, 'color': Color(0xFF4ECDC4)},
    {'days': 180, 'label': '6 أشهر', 'icon': Icons.calendar_month, 'color': Color(0xFF95E1D3)},
    {'days': 365, 'label': 'سنة', 'icon': Icons.event_note, 'color': Color(0xFFD4AF37)},
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B2B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143B32),
        title: const Text('خطة ختم القرآن', style: TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
      ),
      body: _selectedDays == null ? _buildPlanSelection() : _buildActivePlan(),
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
          child: const Column(
            children: [
              Icon(Icons.menu_book, color: Color(0xFFD4AF37), size: 48),
              SizedBox(height: 12),
              Text('اختر خطتك لختم القرآن', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('سنحسب لك الورد اليومي تلقائيًا', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
                  Text(p['label'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$pagesPerDay صفحة يوميًا', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
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
        // دائرة التقدم
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
                    Text('$_completedDays / $_selectedDays يوم',
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),

        // بطاقة الورد اليومي
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
              const Text('ورد اليوم', style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn('صفحات', '$_pagesPerDay', Icons.description),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statColumn('أجزاء', '${(_pagesPerDay / 20).toStringAsFixed(1)}', Icons.book),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _statColumn('صفحة البداية', '${_completedDays * _pagesPerDay + 1}', Icons.play_arrow),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // زر إكمال الورد
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
                Text(_todayDone ? 'أكملت ورد اليوم ✓' : 'أكملت وردي اليوم',
                    style: TextStyle(
                      color: _todayDone ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // شبكة الأيام
        const Text('تقدمك اليومي', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDaysGrid(),
        const SizedBox(height: 24),

        // زر إعادة
        Center(
          child: TextButton.icon(
            onPressed: _resetPlan,
            icon: const Icon(Icons.refresh, color: Colors.white54),
            label: const Text('اختيار خطة جديدة', style: TextStyle(color: Colors.white54)),
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
