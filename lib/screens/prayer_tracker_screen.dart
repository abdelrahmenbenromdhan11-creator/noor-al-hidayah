import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class PrayerTrackerScreen extends StatefulWidget {
  const PrayerTrackerScreen({super.key});
  @override
  State<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends State<PrayerTrackerScreen> {
  // المفتاح: 'y-m-d-prayer' → القيمة: true إذا صلى
  final Set<String> _prayed = {};

  final List<String> _prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
  final List<String> _dayNames = ['sat', 'sun', 'mon', 'tue', 'wed', 'thu', 'fri'];

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isPrayed(DateTime d, String prayer) => _prayed.contains('${_dateKey(d)}-$prayer');

  void _toggle(DateTime d, String prayer) {
    setState(() {
      final key = '${_dateKey(d)}-$prayer';
      _prayed.contains(key) ? _prayed.remove(key) : _prayed.add(key);
    });
  }

  int _todayCount() {
    final today = DateTime.now();
    return _prayerKeys.where((p) => _isPrayed(today, p)).length;
  }

  int _weekCount() {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      count += _prayerKeys.where((p) => _isPrayed(d, p)).length;
    }
    return count;
  }

  int _streak() {
    int s = 0;
    for (int i = 0; i < 30; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final count = _prayerKeys.where((p) => _isPrayed(d, p)).length;
      if (count == 5) {
        s++;
      } else if (i > 0) {
        break;
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Scaffold(
          backgroundColor: const Color(0xFF0B2B26),
          appBar: AppBar(
            backgroundColor: const Color(0xFF143B32),
            title: Text(LanguageManager.t('prayer_tracker_title'),
                style: const TextStyle(color: Color(0xFFD4AF37))),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة الإحصائيات
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
                              value: _todayCount() / 5,
                              strokeWidth: 8,
                              backgroundColor: const Color(0xFF0B2B26),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${_todayCount()}',
                                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 26, fontWeight: FontWeight.bold)),
                              Text('/ 5', style: const TextStyle(color: Colors.white54, fontSize: 11)),
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
                          Text(LanguageManager.t('today_prayers'),
                              style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            _todayCount() == 5
                                ? LanguageManager.t('all_prayers_done')
                                : '${5 - _todayCount()} ${LanguageManager.t('remaining_prayers')}',
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text('${_streak()} ${LanguageManager.t('streak_days')}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // إحصائيات الأسبوع
              Row(
                children: [
                  Expanded(child: _statBox(Icons.check_circle, '${_weekCount()}/35', LanguageManager.t('this_week'), const Color(0xFF4ECDC4))),
                  const SizedBox(width: 12),
                  Expanded(child: _statBox(Icons.local_fire_department, '${_streak()}', LanguageManager.t('streak'), Colors.orange)),
                ],
              ),
              const SizedBox(height: 24),

              // اليوم
              Text(LanguageManager.t('today_prayers'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._prayerKeys.map((p) => _prayerTile(DateTime.now(), p, isAr)).toList(),
              const SizedBox(height: 24),

              // آخر 7 أيام
              Text(LanguageManager.t('last_7_days'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...List.generate(7, (i) {
                final d = DateTime.now().subtract(Duration(days: i));
                return _dayCard(d, isAr);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _prayerTile(DateTime date, String prayerKey, bool isAr) {
    final isPrayed = _isPrayed(date, prayerKey);
    return GestureDetector(
      onTap: () => _toggle(date, prayerKey),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isPrayed ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrayed ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
            width: isPrayed ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(_prayerIcon(prayerKey),
                color: isPrayed ? const Color(0xFFD4AF37) : Colors.white54, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Text(LanguageManager.t(prayerKey),
                  style: TextStyle(
                    color: isPrayed ? const Color(0xFFD4AF37) : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPrayed ? const Color(0xFFD4AF37) : Colors.transparent,
                border: Border.all(
                  color: isPrayed ? const Color(0xFFD4AF37) : Colors.white38,
                  width: 2,
                ),
              ),
              child: isPrayed
                  ? const Icon(Icons.check, color: Color(0xFF0B2B26), size: 20)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCard(DateTime date, bool isAr) {
    final count = _prayerKeys.where((p) => _isPrayed(date, p)).length;
    final dayName = _dayNames[date.weekday % 7];
    final progress = count / 5;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: count == 5 ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.15),
          width: count == 5 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LanguageManager.t('day_$dayName'),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${date.day}/${date.month}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFF0B2B26),
                valueColor: AlwaysStoppedAnimation<Color>(
                  count == 5 ? const Color(0xFFD4AF37) : const Color(0xFF4ECDC4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('$count/5',
              style: TextStyle(
                color: count == 5 ? const Color(0xFFD4AF37) : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  IconData _prayerIcon(String prayer) {
    switch (prayer) {
      case 'fajr': return Icons.wb_twilight;
      case 'dhuhr': return Icons.wb_sunny;
      case 'asr': return Icons.wb_cloudy;
      case 'maghrib': return Icons.wb_twilight;
      case 'isha': return Icons.nights_stay;
      default: return Icons.mosque;
    }
  }
}
