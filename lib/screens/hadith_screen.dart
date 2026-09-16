import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hadith_data.dart';
import '../i18n/language_manager.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});
  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  HadithPart? _selectedPart;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
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
                _selectedPart == null
                    ? (isAr ? 'موسوعة الأحاديث' : 'Hadith Encyclopedia')
                    : (isAr ? _selectedPart!.titleAr : _selectedPart!.titleEn),
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
              leading: _selectedPart != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => setState(() {
                        _selectedPart = null;
                        _selectedCategory = 'all';
                      }),
                    )
                  : null,
            ),
            body: _selectedPart == null
                ? _buildPartsGrid(isAr)
                : _buildPartContent(isAr),
          ),
        );
      },
    );
  }

  // ═══════════════ شبكة الأجزاء الثلاثين ═══════════════
  Widget _buildPartsGrid(bool isAr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMainHeader(isAr),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: allHadithParts.length,
          itemBuilder: (context, i) => _buildPartCard(allHadithParts[i], isAr),
        ),
      ],
    );
  }

  Widget _buildMainHeader(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(24),
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
              Positioned(top: 6, right: 6, child: _corner()),
              Positioned(top: 6, left: 6, child: Transform.rotate(angle: 1.5708, child: _corner())),
              Positioned(bottom: 6, right: 6, child: Transform.rotate(angle: -1.5708, child: _corner())),
              Positioned(bottom: 6, left: 6, child: Transform.rotate(angle: 3.1416, child: _corner())),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_stories, color: Color(0xFF0B2B26), size: 36),
                  ),
                  const SizedBox(height: 14),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37), Color(0xFFFFE9A8)],
                    ).createShader(bounds),
                    child: Text(
                      isAr ? 'موسوعة الأحاديث' : 'Hadith Encyclopedia',
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? '29 جزءًا من الأحاديث الصحيحة' : '29 parts of authentic hadiths',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPartCard(HadithPart part, bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () {
            if (part.available) {
              setState(() => _selectedPart = part);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isAr ? 'هذا الجزء قريبًا إن شاء الله' : 'Coming soon, in sha Allah',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF143B32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: part.available
                    ? [
                        Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                        const Color(0xFF0B2B26),
                      ]
                    : [const Color(0xFF143B32).withOpacity(0.5), const Color(0xFF0B2B26)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: part.available
                    ? Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!
                    : Colors.white.withOpacity(0.08),
                width: part.available ? 1.8 : 1,
              ),
              boxShadow: part.available
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                        blurRadius: 12 + 8 * glow,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                if (part.available)
                  Positioned(top: 4, right: 4, child: _corner(size: 16)),
                if (part.available)
                  Positioned(bottom: 4, left: 4, child: Transform.rotate(angle: 3.1416, child: _corner(size: 16))),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // الأيقونة
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: part.available
                              ? LinearGradient(
                                  colors: [
                                    Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                                    const Color(0xFF8B6914),
                                  ],
                                )
                              : null,
                          color: part.available ? null : Colors.white.withOpacity(0.05),
                          boxShadow: part.available
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withOpacity(0.4 * glow),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          part.icon,
                          color: part.available ? const Color(0xFF0B2B26) : Colors.white38,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // رقم الجزء
                      Text(
                        '${isAr ? "الجزء" : "Part"} ${part.number}',
                        style: GoogleFonts.cairo(
                          color: part.available ? const Color(0xFFD4AF37) : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // العنوان
                      Text(
                        isAr ? part.titleAr : part.titleEn,
                        style: GoogleFonts.cairo(
                          color: part.available ? Colors.white : Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!part.available) ...[
                        const SizedBox(height: 6),
                        const Icon(Icons.lock, color: Colors.white24, size: 12),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════ محتوى الجزء ═══════════════
  List<Hadith> _getCurrentHadiths() {
    switch (_selectedPart?.number) {
      case 1: return part1Hadiths;
      case 2: return part2Hadiths;
      case 3: return part3Hadiths;
      case 4: return part4Hadiths;
      case 5: return part5Hadiths;
      case 6: return part6Hadiths;
      case 7: return part7Hadiths;
      case 8: return part8Hadiths;
      case 9: return part9Hadiths;
      case 10: return part10Hadiths;
      case 11: return part11Hadiths;
      case 12: return part12Hadiths;
      case 13: return part13Hadiths;
      case 14: return part14Hadiths;
      case 15: return part15Hadiths;
      case 16: return part16Hadiths;
      case 17: return part17Hadiths;
      case 18: return part18Hadiths;
      case 19: return part19Hadiths;
      case 20: return part20Hadiths;
      case 21: return part21Hadiths;
      case 22: return part22Hadiths;
      case 23: return part23Hadiths;
      case 24: return part24Hadiths;
      case 25: return part25Hadiths;
      case 26: return part26Hadiths;
      case 27: return part27Hadiths;
      case 28: return part28Hadiths;
      case 29: return part29Hadiths;
      default: return [];
    }
  }

  List<HadithCategory> _getCurrentCategories() {
    switch (_selectedPart?.number) {
      case 1: return part1Categories;
      case 2: return part2Categories;
      case 3: return part3Categories;
      case 4: return part4Categories;
      case 5: return part5Categories;
      case 6: return part6Categories;
      case 7: return part7Categories;
      case 8: return part8Categories;
      case 9: return part9Categories;
      case 10: return part10Categories;
      case 11: return part11Categories;
      case 12: return part12Categories;
      case 13: return part13Categories;
      case 14: return part14Categories;
      case 15: return part15Categories;
      case 16: return part16Categories;
      case 17: return part17Categories;
      case 18: return part18Categories;
      case 19: return part19Categories;
      case 20: return part20Categories;
      case 21: return part21Categories;
      case 22: return part22Categories;
      case 23: return part23Categories;
      case 24: return part24Categories;
      case 25: return part25Categories;
      case 26: return part26Categories;
      case 27: return part27Categories;
      case 28: return part28Categories;
      case 29: return part29Categories;
      default: return [];
    }
  }

  Widget _buildPartContent(bool isAr) {
    final allHadiths = _getCurrentHadiths();
    final allCategories = _getCurrentCategories();
    final filtered = _selectedCategory == 'all'
        ? allHadiths
        : allHadiths.where((h) => h.categoryId == _selectedCategory).toList();

    return Column(
      children: [
        // شريط التصنيفات
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allCategories.length + 1,
            itemBuilder: (context, i) {
              final isAll = i == 0;
              final cat = isAll ? null : allCategories[i - 1];
              final catId = isAll ? 'all' : cat!.id;
              final isSelected = catId == _selectedCategory;

              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = catId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                        : null,
                    color: isSelected ? null : const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (cat != null) ...[
                        Icon(cat.icon, color: isSelected ? const Color(0xFF0B2B26) : const Color(0xFFD4AF37), size: 14),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        isAll ? (isAr ? 'الكل' : 'All') : (isAr ? cat!.nameAr : cat!.nameEn),
                        style: GoogleFonts.cairo(
                          color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // عدد الأحاديث
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.library_books, color: Color(0xFFD4AF37), size: 14),
              const SizedBox(width: 6),
              Text(
                '${filtered.length} ${isAr ? "حديثًا" : "hadiths"}',
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),

        // القائمة
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, i) => _buildHadithCard(filtered[i], isAr, i),
          ),
        ),
      ],
    );
  }

  // ═══════════════ بطاقة الحديث ═══════════════
  Widget _buildHadithCard(Hadith hadith, bool isAr, int index) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              Positioned(top: 6, right: 6, child: _corner(size: 18)),
              Positioned(bottom: 6, left: 6, child: Transform.rotate(angle: 3.1416, child: _corner(size: 18))),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══════ الرأس (رقم + عنوان) ═══════
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42, height: 42,
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
                              isAr ? hadith.titleAr : hadith.titleEn,
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

                    // ═══════ نص الحديث ═══════
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B2B26).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                      ),
                      child: Text(
                        isAr ? hadith.textAr : hadith.textEn,
                        style: GoogleFonts.amiri(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 16,
                          height: 1.9,
                        ),
                        textAlign: isAr ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ═══════ الراوي ═══════
                    _infoRow(Icons.person, const Color(0xFF4ECDC4),
                        isAr ? hadith.narratorAr : hadith.narratorEn),
                    const SizedBox(height: 6),
                    // ═══════ المصدر ═══════
                    _infoRow(Icons.book, const Color(0xFF95E1D3), hadith.source),
                    const SizedBox(height: 6),
                    // ═══════ الدرجة ═══════
                    _infoRow(Icons.verified, Colors.greenAccent, hadith.grade, bold: true),

                    // ═══════ الوسوم ═══════
                    if (hadith.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: hadith.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25)),
                          ),
                          child: Text(
                            '#$tag',
                            style: GoogleFonts.cairo(color: const Color(0xFFD4AF37), fontSize: 10),
                          ),
                        )).toList(),
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

  Widget _infoRow(IconData icon, Color color, String text, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 11,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _corner({double size = 22}) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _HadithCornerPainter()),
    );
  }
}

class _HadithCornerPainter extends CustomPainter {
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
