import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAyahs();
  }

  Future<void> _loadAyahs() async {
    try {
      // جلب النص العربي والإنجليزي معًا
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

  Future<void> _playArabic() async {
    final url = 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${widget.surahNumber}.mp3';
    try {
      if (_playing) {
        await _player.pause();
        setState(() => _playing = false);
      } else {
        await _player.setUrl(url);
        _player.play();
        setState(() => _playing = true);
      }
    } catch (e) {
      setState(() => _playing = false);
    }
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
            tooltip: 'الترجمة',
            onPressed: () => setState(() => _showEnglish = !_showEnglish),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : Column(
              children: [
                // بطاقة مشغل الصوت
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
                            onPressed: _playArabic,
                            icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle,
                                color: const Color(0xFFD4AF37), size: 48),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.surahEnglish,
                                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 4),
                                const Text('القارئ: مشاري العفاسي',
                                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('الترجمة الإنجليزية',
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
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

                // قائمة الآيات
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _ayahs.length,
                    itemBuilder: (context, i) {
                      final a = _ayahs[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF143B32),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // النص العربي
                            Text(a['arabic'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 22, height: 1.8),
                                textAlign: TextAlign.right),
                            const SizedBox(height: 10),
                            // النص الإنجليزي (يظهر حسب التبديل)
                            if (_showEnglish) ...[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0B2B26),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(a['english'],
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                        height: 1.5,
                                        fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.left),
                              ),
                              const SizedBox(height: 8),
                            ],
                            // رقم الآية
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('${a['number']}',
                                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
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
