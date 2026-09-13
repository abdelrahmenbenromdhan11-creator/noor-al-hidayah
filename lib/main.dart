import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/adhkar_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/community_screen.dart';
import 'screens/settings_screen.dart';
import 'i18n/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('✅ Firebase OK');
  } catch (e) {
    print('❌ Firebase failed: $e');
  }
  runApp(const NoorAlHidayahApp());
}

class NoorAlHidayahApp extends StatelessWidget {
  const NoorAlHidayahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        return MaterialApp(
          title: LanguageManager.t('app_name'),
          debugShowCheckedModeBanner: false,
          locale: Locale(lang),
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
          home: const _RootScreen(),
        );
      },
    );
  }
}

class _RootScreen extends StatefulWidget {
  const _RootScreen();
  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  bool _skipLogin = false;

  @override
  Widget build(BuildContext context) {
    if (_skipLogin) return const MainScreen();

    return Stack(
      children: [
        const LoginScreen(),
        // زر تخطي صغير
        Positioned(
          bottom: 15,
          left: 15,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _skipLogin = true),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF143B32),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('تخطي / Skip',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.skip_next, color: Color(0xFFD4AF37), size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                '${LanguageManager.t('app_name')} | Noor Al-Hidayah',
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.translate, color: Color(0xFFD4AF37)),
                  tooltip: 'Language',
                  onPressed: () {
                    LanguageManager.setLanguage(
                      LanguageManager.currentLanguage.value == 'ar' ? 'en' : 'ar',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFFD4AF37)),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: const Color(0xFF143B32),
              selectedItemColor: const Color(0xFFD4AF37),
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(icon: const Icon(Icons.mosque), label: LanguageManager.t('prayer')),
                BottomNavigationBarItem(icon: const Icon(Icons.menu_book), label: LanguageManager.t('quran')),
                BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: LanguageManager.t('adhkar')),
                BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: LanguageManager.t('challenge')),
                BottomNavigationBarItem(icon: const Icon(Icons.people), label: LanguageManager.t('community')),
              ],
            ),
          ),
        );
      },
    );
  }
}
