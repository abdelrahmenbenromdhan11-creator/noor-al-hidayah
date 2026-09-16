import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'reciters.dart';
import '../i18n/language_manager.dart';

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

class _QuranDetailScreenState extends State<QuranDetailScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _ayahs = [];
  bool _loading = true;
  bool _showEnglish = true;
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  Reciter _reciter = allReciters.first;
  int _currentAyahIndex = -1;
  late AnimationController _glowController;

  bool get _isFullSurah => fullSurahSources.containsKey(_reciter.id);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
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
        final baseUrl = fullSurahSources[_reciter.id]!;
        final surahPad = widget.surahNumber.toString().padLeft(3, '0');
        final url = '$baseUrl/$surahPad.mp3';
        await _player.setUrl(url);
      } else {
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
          SnackBar(
            content: Text('تعذر تشغيل ${_reciter.arabic}',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _pickReciter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF143B32),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          child: Column(
            children: [
              Container(
                width: 50, height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LanguageManager.t('choose_reciter'),
                style: GoogleFonts.cairo(
                  color: const Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allReciters.length,
                  itemBuilder: (_, i) {
                    final r = allReciters[i];
                    final isSelected = r.id == _reciter.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E4D40) : const Color(0xFF0B2B26),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            _reciter = r;
                            _playing = false;
                            _currentAyahIndex = -1;
                          });
                          _player.stop();
                          Navigator.pop(ctx);
                        },
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                                : null,
                            color: isSelected ? null : const Color(0xFF143B32),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.cairo(
                                color: isSelected ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          r.arabic,
                          style: GoogleFonts.cairo(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${r.name} • ${r.country}',
                          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                            : null,
                      ),
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
    _glowController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                widget.surahName,
                style: GoogleFonts.amiri(color: const Color(0xFFD4AF37), fontSize: 22),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
              actions: [
                IconButton(
                  icon: Icon(_showEnglish ? Icons.translate : Icons.translate_outlined),
                  color: const Color(0xFFD4AF37),
                  onPressed: () => setState(() => _showEnglish = !_showEnglish),
                ),
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : Column(
                    children: [
                      _buildPlayerCard(isAr),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _ayahs.length,
                          itemBuilder: (context, i) => _buildAyahCard(_ayahs[i], i, isAr),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ═══════════ بطاقة المشغل ═══════════
  Widget _buildPlayerCard(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                blurRadius: 15 + 10 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // زر التشغيل
                  GestureDetector(
                    onTap: _playSurah,
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                            const Color(0xFF8B6914),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.5 * glow),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _playing ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xFF0B2B26),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.surahEnglish,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${LanguageManager.t('reciter_label')}: ${_reciter.arabic}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFFD4AF37),
                            fontSize: 12,
                          ),
                        ),
                        if (_isFullSurah)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              LanguageManager.t('full_surah_audio'),
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // زر تغيير القارئ
              GestureDetector(
                onTap: _pickReciter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2B26).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic, color: Color(0xFFD4AF37), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${LanguageManager.t('change_reciter')} (13)',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ بطاقة الآية ═══════════
  Widget _buildAyahCard(Map<String, dynamic> a, int i, bool isAr) {
    final isCurrent = i == _currentAyahIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isCurrent
              ? [const Color(0xFF1E4D40), const Color(0xFF2B6E5C)]
              : [const Color(0xFF143B32), const Color(0xFF0B2B26)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withOpacity(0.2),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // الزخرفة العلوية اليمنى
          Positioned(top: 6, right: 6, child: _corner(size: 16)),
          Positioned(bottom: 6, left: 6, child: Transform.rotate(angle: 3.1416, child: _corner(size: 16))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // النص العربي
                Text(
                  a['arabic'],
                  style: GoogleFonts.amiri(
                    color: isCurrent ? const Color(0xFFD4AF37) : Colors.white,
                    fontSize: 22,
                    height: 2,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                // الترجمة الإنجليزية
                if (_showEnglish) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2B26).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)),
                    ),
                    child: Text(
                      a['english'],
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                // رقم الآية
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: isCurrent
                          ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                          : null,
                      color: isCurrent ? null : const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    ),
                    child: Text(
                      '${a['number']}',
                      style: GoogleFonts.cairo(
                        color: isCurrent ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _corner({double size = 22}) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _AyahCornerPainter()),
    );
  }
}

class _AyahCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.1, size.width * 0.4, 0);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
