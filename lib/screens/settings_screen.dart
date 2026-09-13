import 'package:flutter/material.dart';
import 'adhan_sounds_screen.dart';
import 'support_screen.dart';
import '../services/auth_service.dart';
import '../i18n/language_manager.dart';
import '../i18n/translations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> _prayerNotifs = {
    'fajr': true, 'dhuhr': true, 'asr': true, 'maghrib': true, 'isha': true,
  };
  bool _adhkarMorning = true;
  bool _adhkarEvening = true;
  bool _preReminder = true;
  int _preMinutes = 10;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('settings'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // اللغة
            _sectionTitle(LanguageManager.t('language'), Icons.language),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showLanguagePicker,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(allLanguages.firstWhere((l) => l.code == lang).flag,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          allLanguages.firstWhere((l) => l.code == lang).nativeName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 18),
                    ],
                  ),
                ),
              ),
            ),

            // أصوات الأذان
            const SizedBox(height: 24),
            _sectionTitle(LanguageManager.t('adhan_sound'), Icons.music_note),
            const SizedBox(height: 8),
            _navTile(Icons.music_note, LanguageManager.t('adhan_sound'), const AdhanSoundsScreen()),

            // إشعارات الصلاة
            const SizedBox(height: 24),
            _sectionTitle(LanguageManager.t('prayer_notifications'), Icons.notifications_active),
            const SizedBox(height: 8),
            ..._prayerNotifs.keys.map((key) => _switchTile(
                  title: LanguageManager.t(key),
                  subtitle: LanguageManager.t('pre_adhan'),
                  value: _prayerNotifs[key]!,
                  onChanged: (v) => setState(() => _prayerNotifs[key] = v),
                )).toList(),

            // تنبيه مسبق
            const SizedBox(height: 20),
            _sectionTitle(LanguageManager.t('pre_adhan'), Icons.alarm),
            const SizedBox(height: 8),
            _switchTile(
              title: LanguageManager.t('pre_adhan'),
              subtitle: '$_preMinutes min',
              value: _preReminder,
              onChanged: (v) => setState(() => _preReminder = v),
            ),

            // الأذكار
            const SizedBox(height: 20),
            _sectionTitle(LanguageManager.t('adhkar_reminder'), Icons.favorite),
            const SizedBox(height: 8),
            _switchTile(
              title: LanguageManager.t('morning_adhkar'),
              subtitle: LanguageManager.t('adhkar_reminder'),
              value: _adhkarMorning,
              onChanged: (v) => setState(() => _adhkarMorning = v),
            ),
            _switchTile(
              title: LanguageManager.t('evening_adhkar'),
              subtitle: LanguageManager.t('adhkar_reminder'),
              value: _adhkarEvening,
              onChanged: (v) => setState(() => _adhkarEvening = v),
            ),

            // الدعم
            const SizedBox(height: 24),
            _sectionTitle(LanguageManager.t('support_title'), Icons.support_agent),
            const SizedBox(height: 8),
            _navTile(Icons.support_agent, LanguageManager.t('contact_us'), const SupportScreen()),

            // تسجيل الخروج
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF143B32),
                      title: const Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text('تسجيل الخروج',
                              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('خروج', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B1414),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 24),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text('تسجيل الخروج',
                            style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        value: value,
        activeColor: const Color(0xFFD4AF37),
        onChanged: onChanged,
      ),
    );
  }

  Widget _navTile(IconData icon, String label, Widget page) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF143B32),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 550,
          child: Column(
            children: [
              Container(width: 50, height: 5,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(LanguageManager.t('choose_language'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allLanguages.length,
                  itemBuilder: (_, i) {
                    final l = allLanguages[i];
                    final isSelected = l.code == LanguageManager.currentLanguage.value;
                    return ListTile(
                      onTap: () {
                        LanguageManager.setLanguage(l.code);
                        Navigator.pop(ctx);
                      },
                      leading: Text(l.flag, style: const TextStyle(fontSize: 28)),
                      title: Text(l.nativeName,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      subtitle: Text(l.name, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37)) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
