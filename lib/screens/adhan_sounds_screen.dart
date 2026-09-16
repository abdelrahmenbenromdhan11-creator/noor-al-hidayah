import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'adhan_data.dart';
import '../i18n/language_manager.dart';

class AdhanSoundsScreen extends StatefulWidget {
  const AdhanSoundsScreen({super.key});
  @override
  State<AdhanSoundsScreen> createState() => _AdhanSoundsScreenState();
}

class _AdhanSoundsScreenState extends State<AdhanSoundsScreen> {
  String _selectedId = 'makkah';
  final AudioPlayer _player = AudioPlayer();
  String? _playingId;

  Future<void> _preview(AdhanSound adhan) async {
    try {
      if (_playingId == adhan.id) {
        await _player.stop();
        setState(() => _playingId = null);
        return;
      }
      setState(() => _playingId = adhan.id);
      await _player.setUrl(adhan.url);
      _player.play();
      _player.playerStateStream.listen((state) {
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
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('adhan_sound'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allAdhanSounds.length,
          itemBuilder: (context, i) {
            final adhan = allAdhanSounds[i];
            final isSelected = adhan.id == _selectedId;
            final isPlaying = _playingId == adhan.id;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                onTap: () => setState(() => _selectedId = adhan.id),
                leading: CircleAvatar(
                  backgroundColor: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                  child: Icon(Icons.mosque,
                      color: isSelected ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37), size: 22),
                ),
                title: Text(adhan.arabic,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                subtitle: Text(adhan.name,
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: IconButton(
                  icon: Icon(isPlaying ? Icons.stop_circle : Icons.play_circle,
                      color: const Color(0xFFD4AF37), size: 32),
                  onPressed: () => _preview(adhan),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
