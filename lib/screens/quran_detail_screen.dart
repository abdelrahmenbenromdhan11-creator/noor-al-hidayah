import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'reciters.dart';

class QuranDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String surahEnglish;
  const QuranDetailScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surahEnglish,
  });

  @override
  State<QuranDetailScreen> createState() => _QuranDetailScreenState();
}

class _QuranDetailScreenState extends State<QuranDetailScreen> {
  List<dynamic> _ayahs = [];
  bool _loading = true;
  bool _showEnglish = true;
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Reciter _reciter = allReciters.first;
  int _currentAyahIndex = -1;

  bool get _isFullSurah => fullSurahSources.containsKey(_reciter.id);

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _player.currentIndexStream.listen((index) {
      if (mounted && index != null && !_isFullSurah) {
        setState(() => _currentAyahIndex = index);
      }
    });
    _player.playerStateStream.listen((state) {
      if (mounted && state.processingState == ProcessingState.completed) {
        setState(() {
          _playing = false;
          _currentAyahIndex = -1;
        });
      }
    });
  }

  Future<void> _loadAyahs() async {
    try {
      final res = await http.get(Uri.parse(
          'https://api.alquran.cloud/v1/surah/${widget.surahNumber}/editions/quran-uthmani,en.sahih'));
      final data = json.decode(res.body)['data'];
      final arabic = data[0]['ayahs'];
      final english = data[1]['ayahs'];
      final merged = <Map<String, dynamic>>[];
      for (int i = 0; i < arabic.length; i++) {
        merged.add({
          'arabic': arabic[i]['text'],
          'english': english[i]['text'],
          'number': arabic[i]['numberInSurah'],
          'globalAyahNumber': arabic[i]['number'],
        });
      }
      setState(() {
        _ayahs = merged;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _playSurah() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }

    try {
      if (_isFullSurah) {
        // صوت السورة كاملة من mp3quran.net
        final baseUrl = fullSurahSources[_reciter.id]!;
        final surahPad = widget.surahNumber.toString().padLeft(3, '0');
        final url = '$baseUrl/$surahPad.mp3';
        await _player.setUrl(url);
      } else {
        // آية بآية من islamic.network
        final playlist = ConcatenatingAudioSource(children: []);
        for (final ayah in _ayahs) {
          final num = ayah['globalAyahNumber'];
          final url = 'https://cdn.islamic.network/quran/audio/64/${_reciter.id}/$num.mp3';
          playlist.add(AudioSource.uri(Uri.parse(url)));
        }
        await _player.setAudioSource(playlist);
      }
      _player.play();
      setState(() => _playing = true);
    } catch (e) {
      setState(() => _playing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تشغيل ${_reciter.arabic} لهذه السورة'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _pickReciter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF143B32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          child: Column(
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              Text(LanguageManager.t('choose_reciter'), style: TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allReciters.length,
                  itemBuilder: (_, i) {
                    final r = allReciters[i];
                    final isSelected = r.id == _reciter.id;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _reciter = r;
                          _playing = false;
                          _currentAyahIndex = -1;
                        });
                        _player.stop();
                        Navigator.pop(ctx);
                      },
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                        child: Text('${i + 1}', style: TextStyle(color: isSelected ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                      ),
                      title: Text(r.arabic, style: TextStyle(color: isSelected ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('${r.name} • ${r.country}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2B26),
      appBar: AppBar(
        backgroundColor: const Color(0xFF143B32),
        title: Text(widget.surahName, style: const TextStyle(color: Color(0xFFD4AF37))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          IconButton(
            icon: Icon(_showEnglish ? Icons.translate : Icons.translate_outlined),
            onPressed: () => setState(() => _showEnglish = !_showEnglish),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _playSurah,
                            icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle,
                                color: const Color(0xFFD4AF37), size: 48),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.surahEnglish, style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('${LanguageManager.t('reciter_label')}: ${_reciter.arabic}', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
                                if (_isFullSurah)
                                  Text(LanguageManager.t('full_surah_audio'), style: TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickReciter,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2B26),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic, color: Color(0xFFD4AF37), size: 20),
                                SizedBox(width: 8),
                                Text('تغيير القارئ (13 متوفر)', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LanguageManager.t('english_translation_label'), style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Switch(
                            value: _showEnglish,
                            activeColor: const Color(0xFFD4AF37),
                            onChanged: (v) => setState(() => _showEnglish = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ayahs.length,
                    itemBuilder: (context, i) {
                      final a = _ayahs[i];
                      final isCurrent = i == _currentAyahIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF1E4D40) : const Color(0xFF143B32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.1),
                            width: isCurrent ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(a['arabic'],
                                style: TextStyle(
                                  color: isCurrent ? const Color(0xFFD4AF37) : Colors.white,
                                  fontSize: 22,
                                  height: 1.8,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.right),
                            const SizedBox(height: 10),
                            if (_showEnglish) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFF0B2B26), borderRadius: BorderRadius.circular(8)),
                                child: Text(a['english'],
                                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5, fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.left),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCurrent ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${a['number']}',
                                    style: TextStyle(
                                      color: isCurrent ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
