import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quran_detail_screen.dart';
import '../i18n/language_manager.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});
  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _surahs = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  late AnimationController _glowController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _loadSurahs();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final res = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'));
      final data = json.decode(res.body)['data'];
      setState(() {
        _surahs = data;
        _filtered = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _filter(String q) {
    setState(() {
      _filtered = _surahs.where((s) =>
          s['englishName'].toString().toLowerCase().contains(q.toLowerCase()) ||
          s['number'].toString().contains(q) ||
          s['name'].toString().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            children: [
              _buildHeader(isAr),
              _buildSearchBar(isAr),
              _buildCountRow(isAr),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) => _buildSurahCard(_filtered[i], i, isAr),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.25 * glow),
                blurRadius: 20 + 15 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(top: 4, right: 4, child: _corner()),
              Positioned(top: 4, left: 4, child: Transform.rotate(angle: 1.5708, child: _corner())),
              Positioned(bottom: 4, right: 4, child: Transform.rotate(angle: -1.5708, child: _corner())),
              Positioned(bottom: 4, left: 4, child: Transform.rotate(angle: 3.1416, child: _corner())),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
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
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_book, color: Color(0xFF0B2B26), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37), Color(0xFFFFE9A8)],
                          ).createShader(bounds),
                          child: Text(
                            isAr ? 'القرآن الكريم' : 'The Holy Quran',
                            style: GoogleFonts.amiri(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? '114 سورة • استمع واقرأ' : '114 Surahs • Read & Listen',
                          style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isAr) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filter,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: LanguageManager.t('chapter_search'),
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFD4AF37)),
                  onPressed: () {
                    _searchController.clear();
                    _filter('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF143B32),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCountRow(bool isAr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 14),
          const SizedBox(width: 6),
          Text(
            '${_filtered.length} ${isAr ? "سورة" : "Surahs"}',
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> s, int i, bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuranDetailScreen(
                surahNumber: s['number'],
                surahName: s['name'],
                surahEnglish: s['englishName'],
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3 + 0.2 * glow),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.05 + 0.1 * glow),
                  blurRadius: 10 + 5 * glow,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
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
                        color: const Color(0xFFD4AF37).withOpacity(0.4 * glow),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${s['number']}',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF0B2B26),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageManager.currentLanguage.value == 'ar'
                            ? s['name']
                            : s['englishName'],
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LanguageManager.currentLanguage.value == 'ar'
                            ? '${s['englishName']} • ${s['numberOfAyahs']} ${LanguageManager.t('ayahs_count')}'
                            : '${s['numberOfAyahs']} ${LanguageManager.t('ayahs_count')}',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD4AF37).withOpacity(0.15),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _corner({double size = 22}) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _QuranCornerPainter()),
    );
  }
}

class _QuranCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

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
