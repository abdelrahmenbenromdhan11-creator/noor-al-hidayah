import 'package:flutter/material.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/adhkar_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/placeholder_screens.dart';

void main() {
  runApp(const NoorAlHidayahApp());
}

class NoorAlHidayahApp extends StatelessWidget {
  const NoorAlHidayahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noor Al-Hidayah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0B2B26),
        scaffoldBackgroundColor: const Color(0xFF0B2B26),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFF1E4D40),
          surface: Color(0xFF143B32),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PrayerTimesScreen(),
    QuranScreen(),
    AdhkarScreen(),
    QuizScreen(),
    CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: const Text(
            'نور الهداية | Noor Al-Hidayah',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF143B32),
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.mosque), label: 'الصلاة'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'القرآن'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'الأذكار'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'التحدي'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المجتمع'),
          ],
        ),
      ),
    );
  }
}
