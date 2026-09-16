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
import 'screens/location_permission_screen.dart';
import 'screens/profile_screen.dart';
import 'services/notification_service.dart';
import 'services/ads_service.dart';
import 'services/theme_service.dart';
import 'services/user_profile_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/location_service.dart';
import 'i18n/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Firebase: $e');
  }
  try {
    await NotificationService.initialize();
    await NotificationService.requestPermissions();
    await AdsService.initialize();
    await ThemeService.load();
  } catch (e) {
    print('Init: $e');
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
        return ValueListenableBuilder<int>(
          valueListenable: ThemeService.notifier,
          builder: (context, _, __) {
            return MaterialApp(
              title: LanguageManager.t('app_name'),
              debugShowCheckedModeBanner: false,
              locale: Locale(lang),
              theme: ThemeData(
                primaryColor: ThemeService.dark,
                scaffoldBackgroundColor: Colors.transparent,
                colorScheme: ColorScheme.dark(
                  primary: ThemeService.primary,
                  secondary: ThemeService.light,
                  surface: ThemeService.card,
                ),
                useMaterial3: true,
              ),
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/background.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: ThemeService.dark),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              ThemeService.dark.withOpacity(0.75),
                              const Color(0xFF061815).withOpacity(0.85),
                              ThemeService.dark.withOpacity(0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (child != null) child,
                  ],
                );
              },
              home: const _RootScreen(),
            );
          },
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
  int _step = 0;
  bool _checkingLocation = true;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      final hasPerm = await LocationService.hasPermission();
      final saved = await LocationService.getSavedLocation();
      setState(() {
        _step = (hasPerm && saved != null) ? 1 : 0;
        _checkingLocation = false;
      });
    } catch (e) {
      setState(() {
        _step = 0;
        _checkingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLocation) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    if (_step == 0) {
      return LocationPermissionScreen(
          onPermissionGranted: () => setState(() => _step = 1));
    }

    if (_step == 1) {
      return Stack(
        children: [
          const LoginScreen(),
          Positioned(
            bottom: 15,
            left: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _step = 2),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('تخطي / Skip',
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.skip_next,
                          color: Color(0xFFD4AF37), size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const MainScreen();
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
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection:
              LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: ThemeService.card,
              title: Text(
                '${LanguageManager.t('app_name')} | Noor Al-Hidayah',
                style: const TextStyle(
                    color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                // 🌐 زر اللغة
                IconButton(
                  icon: const Icon(Icons.translate, color: Color(0xFFD4AF37)),
                  tooltip: 'Language',
                  onPressed: () {
                    LanguageManager.setLanguage(
                      LanguageManager.currentLanguage.value == 'ar'
                          ? 'en'
                          : 'ar',
                    );
                  },
                ),
                // ⚙️ زر الإعدادات
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFFD4AF37)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                // 👤 زر الملف الشخصي (دائرة - تُظهر الصورة إن وُجدت)
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 4),
                  child: ValueListenableBuilder<int>(
                    valueListenable: UserProfileService.notifier,
                    builder: (context, _, __) {
                      return FutureBuilder<String?>(
                        future: UserProfileService.getAvatarPath(),
                        builder: (context, snapshot) {
                          final avatar = snapshot.data;
                          return GestureDetector(
                            onTap: () => setState(() => _currentIndex = 5),
                            child: Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: avatar == null
                                    ? const LinearGradient(
                                        colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: avatar != null
                                    ? Border.all(color: const Color(0xFFD4AF37), width: 2)
                                    : null,
                              ),
                              child: ClipOval(
                                child: avatar != null
                                    ? (kIsWeb
                                        ? Image.network(
                                            avatar,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Center(
                                              child: Icon(Icons.person, color: Color(0xFF0B2B26), size: 22),
                                            ),
                                          )
                                        : Image.file(
                                            File(avatar),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Center(
                                              child: Icon(Icons.person, color: Color(0xFF0B2B26), size: 22),
                                            ),
                                          ))
                                    : const Center(
                                        child: Icon(Icons.person, color: Color(0xFF0B2B26), size: 22),
                                      ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            body: _pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: ThemeService.card,
              selectedItemColor: ThemeService.primary,
              unselectedItemColor: Colors.white54,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 11,
              unselectedFontSize: 10,
              items: [
                BottomNavigationBarItem(
                    icon: const Icon(Icons.mosque),
                    label: LanguageManager.t('prayer')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.menu_book),
                    label: LanguageManager.t('quran')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.favorite),
                    label: LanguageManager.t('adhkar')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.emoji_events),
                    label: LanguageManager.t('challenge')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.people),
                    label: LanguageManager.t('community')),
                BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: isAr ? 'حسابي' : 'Me'),
              ],
            ),
          ),
        );
      },
    );
  }
}
