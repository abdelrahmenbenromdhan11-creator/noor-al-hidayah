import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'asmaa_allah_data.dart';
import '../i18n/language_manager.dart';

class AsmaaAllahScreen extends StatefulWidget {
  const AsmaaAllahScreen({super.key});
  @override
  State<AsmaaAllahScreen> createState() => _AsmaaAllahScreenState();
}

class _AsmaaAllahScreenState extends State<AsmaaAllahScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AllahName> get _filtered {
    if (_searchQuery.isEmpty) return allahNames;
    return allahNames.where((n) =>
        n.arabic.contains(_searchQuery) ||
        n.transliteration.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.meaningAr.contains(_searchQuery) ||
        n.meaningEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.number.toString() == _searchQuery).toList();
  }

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
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                isAr ? 'أسماء الله الحسنى' : 'Names of Allah',
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  _buildHeader(isAr),
                  const SizedBox(height: 12),
                  _buildSearchBar(isAr),
                  const SizedBox(height: 10),
                  _buildCountRow(isAr),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _filtered.isEmpty
                        ? _buildEmpty(isAr)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) =>
                                _buildNameCard(_filtered[i], i, isAr),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              color: const Color(0xFFD4AF37).withOpacity(0.5), size: 60),
          const SizedBox(height: 12),
          Text(
            isAr ? 'لا توجد نتائج' : 'No results',
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ═══════════ الهيدر المزخرف ═══════════
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
                Color.lerp(
                    const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow)!,
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
              Positioned(top: 4, right: 4, child: _cornerOrnament(0)),
              Positioned(
                  top: 4, left: 4,
                  child: Transform.rotate(angle: 1.5708, child: _cornerOrnament(0))),
              Positioned(
                  bottom: 4, right: 4,
                  child: Transform.rotate(angle: -1.5708, child: _cornerOrnament(0))),
              Positioned(
                  bottom: 4, left: 4,
                  child: Transform.rotate(angle: 3.1416, child: _cornerOrnament(0))),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(const Color(0xFFD4AF37),
                              const Color(0xFFFFE9A8), glow)!,
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
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFF0B2B26), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFB8860B),
                              Color(0xFFFFE9A8),
                              Color(0xFFD4AF37),
                              Color(0xFFFFE9A8),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            isAr ? 'أسماء الله الحسنى' : 'Names of Allah',
                            style: GoogleFonts.amiri(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                              ? '99 اسمًا بحسب الحديث الصحيح'
                              : '99 Names (Authentic Hadith)',
                          style: GoogleFonts.cairo(
                              color: Colors.white60, fontSize: 12),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: isAr ? 'ابحث عن اسم...' : 'Search for a name...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFFD4AF37)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.bookmark, color: Color(0xFFD4AF37), size: 14),
          const SizedBox(width: 6),
          Text(
            '${_filtered.length} ${isAr ? "اسمًا" : "names"}',
            style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ═══════════ بطاقة الاسم ═══════════
  Widget _buildNameCard(AllahName name, int index, bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(0.3 + 0.3 * glow),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.08 + 0.12 * glow),
                blurRadius: 12 + 8 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(top: 6, right: 6, child: _cornerOrnament(0, size: 18)),
              Positioned(
                  bottom: 6, left: 6,
                  child: Transform.rotate(
                      angle: 3.1416, child: _cornerOrnament(0, size: 18))),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // ═══════ الرقم في دائرة متوهجة ═══════
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFFD4AF37),
                                const Color(0xFFFFE9A8), glow)!,
                            const Color(0xFF8B6914),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.5 * glow),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${name.number}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF0B2B26),
                            fontSize: 16,
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
                          // ═══════ الاسم المزخرف ═══════
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                const Color(0xFFB8860B),
                                Color.lerp(const Color(0xFFFFE9A8),
                                    Colors.white, glow * 0.5)!,
                                const Color(0xFFD4AF37),
                                Color.lerp(const Color(0xFFFFE9A8),
                                    Colors.white, glow * 0.5)!,
                                const Color(0xFFB8860B),
                              ],
                            ).createShader(bounds),
                            child: Text(
                              name.arabic,
                              style: GoogleFonts.amiri(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                              textAlign:
                                  isAr ? TextAlign.right : TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // ═══════ النقل اللاتيني ═══════
                          Text(
                            name.transliteration,
                            style: GoogleFonts.cormorantGaramond(
                              color: const Color(0xFFD4AF37).withOpacity(0.85),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ═══════ المعنى في مربع ═══════
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B2B26).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFD4AF37).withOpacity(0.2)),
                            ),
                            child: Text(
                              isAr ? name.meaningAr : name.meaningEn,
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cornerOrnament(double rotation, {double size = 22}) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size, height: size,
        child: CustomPaint(painter: _AsmaaCornerPainter()),
      ),
    );
  }
}

// ═══════════ رسم زخرفة الزاوية ═══════════
class _AsmaaCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.7)
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
