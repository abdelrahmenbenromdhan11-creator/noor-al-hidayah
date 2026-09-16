import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'islamic_guidance_data.dart';
import '../i18n/language_manager.dart';

class GuidanceListScreen extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final Color color;
  final List<GuidanceItem> items;

  const GuidanceListScreen({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  State<GuidanceListScreen> createState() => _GuidanceListScreenState();
}

class _GuidanceListScreenState extends State<GuidanceListScreen>
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

  List<GuidanceItem> get _filtered {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items.where((i) =>
        i.titleAr.contains(_searchQuery) ||
        i.titleEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        i.descAr.contains(_searchQuery) ||
        i.descEn.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
                isAr ? widget.titleAr : widget.titleEn,
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
            ),
            body: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // ═══════ الهيدر المتوهج ═══════
                  _buildHeader(isAr),
                  const SizedBox(height: 12),

                  // ═══════ شريط البحث ═══════
                  _buildSearchBar(isAr),
                  const SizedBox(height: 10),

                  // ═══════ عدد العناصر ═══════
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(widget.icon, color: widget.color, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${_filtered.length} ${isAr ? "عنصر" : "items"}',
                          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ═══════ القائمة ═══════
                  Expanded(
                    child: _filtered.isEmpty
                        ? _buildEmpty(isAr)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _buildItemCard(_filtered[i], i, isAr),
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
          Icon(Icons.search_off, color: widget.color.withOpacity(0.5), size: 60),
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
                Color.lerp(widget.color.withOpacity(0.15), widget.color.withOpacity(0.25), glow)!,
                const Color(0xFF0B2B26),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.color.withOpacity(0.5 + 0.4 * glow),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15 + 0.25 * glow),
                blurRadius: 20 + 15 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // زخرفة الزوايا
              Positioned(top: 4, right: 4, child: _cornerOrnament(widget.color, 0)),
              Positioned(top: 4, left: 4, child: _cornerOrnament(widget.color, 1.5708)),
              Positioned(bottom: 4, right: 4, child: _cornerOrnament(widget.color, -1.5708)),
              Positioned(bottom: 4, left: 4, child: _cornerOrnament(widget.color, 3.1416)),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(widget.color, Colors.white.withOpacity(0.9), glow * 0.4)!,
                          widget.color.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.5 * glow),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: const Color(0xFF0B2B26), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? widget.titleAr : widget.titleEn,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? 'اقرأ وتعلّم وتدبّر' : 'Read, learn, and reflect',
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

  // ═══════════ شريط البحث ═══════════
  Widget _buildSearchBar(bool isAr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.1),
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
          hintText: isAr ? 'ابحث...' : 'Search...',
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(Icons.search, color: widget.color),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: widget.color),
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
            borderSide: BorderSide(color: widget.color.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.color.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: widget.color, width: 1.8),
          ),
        ),
      ),
    );
  }

  // ═══════════ بطاقة العنصر ═══════════
  Widget _buildItemCard(GuidanceItem item, int index, bool isAr) {
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
              color: widget.color.withOpacity(0.3 + 0.3 * glow),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.08 + 0.12 * glow),
                blurRadius: 12 + 8 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // زخرفة الزاوية العلوية
              Positioned(top: 6, right: 6, child: _cornerOrnament(widget.color, 0, size: 18)),
              Positioned(bottom: 6, left: 6, child: _cornerOrnament(widget.color, 3.1416, size: 18)),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════ الرأس (رقم + عنوان) ═══════
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الرقم في دائرة
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.lerp(widget.color, Colors.white.withOpacity(0.8), glow * 0.4)!,
                                widget.color.withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withOpacity(0.4 * glow),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF0B2B26),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              isAr ? item.titleAr : item.titleEn,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ═══════ الوصف في مربع مزخرف ═══════
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2B26).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: widget.color.withOpacity(0.2)),
                      ),
                      child: Text(
                        isAr ? item.descAr : item.descEn,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 14,
                          height: 1.7,
                        ),
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                    ),

                    // ═══════ المرجع ═══════
                    if (item.ref != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: widget.color.withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bookmark, color: widget.color, size: 13),
                            const SizedBox(width: 6),
                            Text(
                              item.ref!,
                              style: GoogleFonts.cairo(
                                color: widget.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ زخرفة الزاوية ═══════════
  Widget _cornerOrnament(Color color, double rotation, {double size = 22}) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: size, height: size,
        child: CustomPaint(painter: _CornerPainter(color)),
      ),
    );
  }
}

// ═══════════ رسم زخرفة الزاوية ═══════════
class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // خط زخرفي منحني
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.1, size.width * 0.4, 0);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);

    // نقطة ذهبية
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}
