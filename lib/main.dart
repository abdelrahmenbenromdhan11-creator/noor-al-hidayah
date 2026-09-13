import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/adhkar_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/community_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'i18n/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
          home: StreamBuilder<User?>(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0B2B26),
                  body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                );
              }
              if (snapshot.hasData) {
                return const MainScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
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
