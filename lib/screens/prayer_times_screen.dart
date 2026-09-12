import 'package:flutter/material.dart';
import 'qibla_screen.dart';
import 'zakat_screen.dart';
import 'quran_plan_screen.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(child: _quickBtn(context, Icons.explore, 'القبلة', const QiblaScreen())),
            const SizedBox(width: 12),
            Expanded(child: _quickBtn(context, Icons.calculate, 'الزكاة', const ZakatScreen())),
          ],
        ),
        const SizedBox(height: 12),
        _quickBtnWide(context, Icons.menu_book, 'خطة ختم القرآن', const QuranPlanScreen()),
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
          child: const Column(
            children: [
              Text('الصلاة القادمة', style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 8),
              Text('العصر', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('3:47 PM', style: TextStyle(color: Colors.white, fontSize: 24)),
              SizedBox(height: 12),
              Text('متبقي 1 ساعة و 42 دقيقة', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('أوقات الصلاة اليوم', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _card('الفجر', '5:12 AM', Icons.wb_twilight, false),
        _card('الظهر', '12:58 PM', Icons.wb_sunny, false),
        _card('العصر', '3:47 PM', Icons.wb_cloudy, true),
        _card('المغرب', '6:34 PM', Icons.wb_twilight, false),
        _card('العشاء', '8:02 PM', Icons.nights_stay, false),
      ],
    );
  }

  Widget _quickBtn(BuildContext context, IconData icon, String label, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
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
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
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
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 28),
              const SizedBox(width: 16),
              Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 16),
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
