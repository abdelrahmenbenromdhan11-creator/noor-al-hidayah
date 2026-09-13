import 'package:flutter/material.dart';
import 'qibla_screen.dart';
import 'zakat_screen.dart';
import 'quran_plan_screen.dart';
import 'fasting_screen.dart';
import 'noor_data.dart';
import 'prayer_tracker_screen.dart';
import 'daily_goals_screen.dart';
import '../i18n/language_manager.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(child: _quickBtn(context, Icons.explore, LanguageManager.t('qibla'), const QiblaScreen())),
                const SizedBox(width: 12),
                Expanded(child: _quickBtn(context, Icons.calculate, LanguageManager.t('zakat'), const ZakatScreen())),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _quickBtn(context, Icons.menu_book, LanguageManager.t('quran_plan'), const QuranPlanScreen())),
                const SizedBox(width: 12),
                Expanded(child: _quickBtn(context, Icons.nightlight, LanguageManager.t('fasting'), const FastingScreen())),
              ],
            ),
            const SizedBox(height: 12),
            _quickBtnWide(context, Icons.check_circle, LanguageManager.t('prayer_tracker_title'), const PrayerTrackerScreen()),
            const SizedBox(height: 12),
            _quickBtnWide(context, Icons.flag, LanguageManager.t('daily_goals_title'), const DailyGoalsScreen()),
            const SizedBox(height: 20),
            _buildNoorCard(context),
            const SizedBox(height: 20),
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
                  Text(LanguageManager.t('next_prayer'),
                      style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(LanguageManager.t('asr'),
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('3:47 PM', style: TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('1h 42min',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(LanguageManager.t('prayer_times_today'),
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _card(LanguageManager.t('fajr'), '5:12 AM', Icons.wb_twilight, false),
            _card(LanguageManager.t('dhuhr'), '12:58 PM', Icons.wb_sunny, false),
            _card(LanguageManager.t('asr'), '3:47 PM', Icons.wb_cloudy, true),
            _card(LanguageManager.t('maghrib'), '6:34 PM', Icons.wb_twilight, false),
            _card(LanguageManager.t('isha'), '8:02 PM', Icons.nights_stay, false),
          ],
        );
      },
    );
  }

  Widget _buildNoorCard(BuildContext context) {
    final noor = getTodayNoor();
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 8),
              Text(LanguageManager.t('noor_today'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0B2B26), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(isAr ? noor.ayahAr : noor.ayahEn,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.7),
                    textAlign: isAr ? TextAlign.right : TextAlign.left),
                const SizedBox(height: 6),
                Text('— ${noor.ayahRef}',
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11),
                    textAlign: isAr ? TextAlign.left : TextAlign.right),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0B2B26), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book, color: Color(0xFF4ECDC4), size: 16),
                    const SizedBox(width: 6),
                    Text(LanguageManager.t('noor_hadith'),
                        style: const TextStyle(color: Color(0xFF4ECDC4), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(isAr ? noor.hadithAr : noor.hadithEn,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                    textAlign: isAr ? TextAlign.right : TextAlign.left),
                const SizedBox(height: 4),
                Text('— ${noor.hadithRef}',
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                    textAlign: isAr ? TextAlign.left : TextAlign.right),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0B2B26), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volunteer_activism, color: Color(0xFFFFA500), size: 16),
                    const SizedBox(width: 6),
                    Text(LanguageManager.t('noor_dua'),
                        style: const TextStyle(color: Color(0xFFFFA500), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(isAr ? noor.duaAr : noor.duaEn,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                    textAlign: isAr ? TextAlign.right : TextAlign.left),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(isAr ? noor.dhikrAr : noor.dhikrEn,
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold, height: 1.5),
                      textAlign: isAr ? TextAlign.right : TextAlign.left),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickBtn(BuildContext context, IconData icon, String label, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickBtnWide(BuildContext context, IconData icon, String label, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E4D40), Color(0xFF143B32)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String name, String time, IconData icon, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(16),
        border: isNext ? Border.all(color: const Color(0xFFD4AF37), width: 1) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: isNext ? const Color(0xFFD4AF37) : Colors.white54, size: 28),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: TextStyle(color: isNext ? const Color(0xFFD4AF37) : Colors.white, fontSize: 18, fontWeight: isNext ? FontWeight.bold : FontWeight.normal))),
          Text(time, style: TextStyle(color: isNext ? const Color(0xFFD4AF37) : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Icon(Icons.notifications_active, color: isNext ? const Color(0xFFD4AF37) : Colors.white24, size: 22),
        ],
      ),
    );
  }
}
