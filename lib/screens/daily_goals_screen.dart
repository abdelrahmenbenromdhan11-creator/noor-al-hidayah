import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({super.key});
  @override
  State<DailyGoalsScreen> createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  final Map<String, bool> _goals = {
    'goal_quran_page': false,
    'goal_5_prayers': false,
    'goal_morning_adhkar': false,
    'goal_evening_adhkar': false,
    'goal_istighfar_100': false,
    'goal_salawat_10': false,
    'goal_dua_today': false,
  };

  int get _completedCount => _goals.values.where((v) => v).length;
  double get _progress => _completedCount / _goals.length;

  void _toggle(String key) {
    setState(() => _goals[key] = !_goals[key]!);
    if (_completedCount == _goals.length) {
      _showAllCompletedDialog();
    }
  }

  void _showAllCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: const Color(0xFF143B32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.celebration, color: Color(0xFFD4AF37), size: 32),
              const SizedBox(width: 10),
              Text(LanguageManager.t('goals_done'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(LanguageManager.t('goals_done_msg'),
              style: const TextStyle(color: Colors.white70)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
              ),
              child: Text(LanguageManager.t('ok'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      for (final k in _goals.keys) {
        _goals[k] = false;
      }
    });
  }

  IconData _goalIcon(String key) {
    switch (key) {
      case 'goal_quran_page': return Icons.menu_book;
      case 'goal_5_prayers': return Icons.mosque;
      case 'goal_morning_adhkar': return Icons.wb_twilight;
      case 'goal_evening_adhkar': return Icons.nights_stay;
      case 'goal_istighfar_100': return Icons.favorite;
      case 'goal_salawat_10': return Icons.star;
      case 'goal_dua_today': return Icons.volunteer_activism;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('daily_goals_title'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
              onPressed: _resetAll,
              tooltip: LanguageManager.t('reset'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة التقدم
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: 140, height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140, height: 140,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${(_progress * 100).toInt()}%',
                                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 36, fontWeight: FontWeight.bold)),
                            Text('$_completedCount / ${_goals.length}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _completedCount == _goals.length
                        ? LanguageManager.t('goals_done')
                        : LanguageManager.t('keep_going'),
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(LanguageManager.t('today_goals'),
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._goals.keys.map((k) => _goalTile(k)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _goalTile(String key) {
    final done = _goals[key]!;
    return GestureDetector(
      onTap: () => _toggle(key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: done ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: done ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
            width: done ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
              ),
              child: Icon(
                _goalIcon(key),
                color: done ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                LanguageManager.t(key),
                style: TextStyle(
                  color: done ? const Color(0xFFD4AF37) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? const Color(0xFFD4AF37) : Colors.transparent,
                border: Border.all(
                  color: done ? const Color(0xFFD4AF37) : Colors.white38,
                  width: 2,
                ),
              ),
              child: done ? const Icon(Icons.check, color: Color(0xFF0B2B26), size: 18) : null,
            ),
          ],
        ),
      ),
    );
  }
}
