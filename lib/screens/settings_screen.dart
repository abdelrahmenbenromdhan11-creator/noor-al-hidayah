import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'adhan_data.dart';
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
  String _selectedAdhanId = 'makkah';
  final AudioPlayer _previewPlayer = AudioPlayer();
  String? _playingId;

  Future<void> _preview(AdhanSound adhan) async {
    try {
      if (_playingId == adhan.id) {
        await _previewPlayer.stop();
        setState(() => _playingId = null);
        return;
      }
      setState(() => _playingId = adhan.id);
      await _previewPlayer.setUrl(adhan.url);
      _previewPlayer.play();
      _previewPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) {
          setState(() => _playingId = null);
        }
      });
    } catch (e) {
      setState(() => _playingId = null);
    }
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B2B26),
          appBar: AppBar(
            backgroundColor: const Color(0xFF143B32),
            title: Text(LanguageManager.t('settings'), style: const TextStyle(color: Color(0xFFD4AF37))),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
                        Text(allLanguages.firstWhere((l) => l.code == lang).flag, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(allLanguages.firstWhere((l) => l.code == lang).nativeName,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle(LanguageManager.t('prayer_notifications'), Icons.notifications_active),
              const SizedBox(height: 8),
              ..._prayerNotifs.keys.map((key) => _switchTile(
                    title: LanguageManager.t(key),
                    subtitle: LanguageManager.t('pre_adhan'),
                    value: _prayerNotifs[key]!,
                    onChanged: (v) => setState(() => _prayerNotifs[key] = v),
                  )).toList(),

              const SizedBox(height: 20),
              _sectionTitle(LanguageManager.t('pre_adhan'), Icons.alarm),
              const SizedBox(height: 8),
              _switchTile(
                title: LanguageManager.t('pre_adhan'),
                subtitle: '$_preMinutes min',
                value: _preReminder,
                onChanged: (v) => setState(() => _preReminder = v),
              ),
              if (_preReminder) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Color(0xFFD4AF37), size: 24),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _preMinutes,
                        dropdownColor: const Color(0xFF143B32),
                        underline: const SizedBox(),
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                        items: [5, 10, 15, 20, 30].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _preMinutes = v); },
                      ),
                    ],
                  ),
                ),
              ],

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

              const SizedBox(height: 20),
              _sectionTitle(LanguageManager.t('adhan_sound'), Icons.music_note),
              const SizedBox(height: 8),
              ...allAdhanSounds.map((adhan) => _adhanTile(adhan)).toList(),
            ],
          ),
        );
      },
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

  Widget _switchTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
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

  Widget _adhanTile(AdhanSound adhan) {
    final isSelected = adhan.id == _selectedAdhanId;
    final isPlaying = _playingId == adhan.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedAdhanId = adhan.id),
        leading: CircleAvatar(
          backgroundColor: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
          child: Icon(Icons.mosque, color: isSelected ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37), size: 22),
        ),
        title: Text(LanguageManager.t('adhan_${adhan.id}'), style: TextStyle(color: isSelected ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(adhan.name, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: IconButton(
          icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle, color: const Color(0xFFD4AF37), size: 32),
          onPressed: () => _preview(adhan),
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
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(LanguageManager.t('choose_language'), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
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
                      title: Text(l.nativeName, style: TextStyle(color: isSelected ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold)),
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
