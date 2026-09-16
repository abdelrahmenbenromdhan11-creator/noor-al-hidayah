import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'adhkar_data.dart';
import '../i18n/language_manager.dart';
import '../services/adhkar_progress_service.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});
  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen>
    with TickerProviderStateMixin {
  String _selectedCategoryId = 'morning';
  int _currentIndex = 0;
  int _counter = 0;
  final Set<String> _completedDhikr = {};

  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  AdhkarCategory get _currentCategory =>
      allAdhkar.firstWhere((c) => c.id == _selectedCategoryId);

  Dhikr get _currentDhikr => _currentCategory.items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectCategory(String id) {
    setState(() {
      _selectedCategoryId = id;
      _currentIndex = 0;
      _counter = 0;
    });
  }

  void _increment() {
    if (_counter < _currentDhikr.count) {
      setState(() => _counter++);
      _pulseController.forward().then((_) => _pulseController.reverse());
      if (_counter == _currentDhikr.count) {
        _completedDhikr.add('$_selectedCategoryId-$_currentIndex');
        // ✅ سجّل التقدم
        AdhkarProgressService.markDhikrCompleted(
          categoryId: _selectedCategoryId,
          dhikrIndex: _currentIndex,
        );
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: const Color(0xFF143B32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  LanguageManager.currentLanguage.value == 'ar'
                      ? 'أكملت الذكر! 🎉'
                      : 'Dhikr Completed! 🎉',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            LanguageManager.currentLanguage.value == 'ar'
                ? 'أتممت ${_currentDhikr.count} مرة'
                : 'Completed ${_currentDhikr.count} times',
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _next();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                LanguageManager.currentLanguage.value == 'ar' ? 'التالي' : 'Next',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() {
    setState(() => _counter = 0);
  }

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _currentCategory.items.length;
      _counter = 0;
    });
  }

  void _prev() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _currentCategory.items.length) %
          _currentCategory.items.length;
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final progress = _counter / _currentDhikr.count;
        final isComplete = _completedDhikr.contains('$_selectedCategoryId-$_currentIndex');

        return FadeTransition(
          opacity: _fadeIn,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildCategoryTabs(),
              const SizedBox(height: 14),
              _buildProgressIndicator(progress),
              const SizedBox(height: 18),
              _buildDhikrCard(isComplete),
              const SizedBox(height: 20),
              _buildCounter(progress),
              const SizedBox(height: 24),
              _buildControls(),
              const SizedBox(height: 24),
              _buildProgressCard(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ بطاقة تقدم الأذكار ═══════════
  Widget _buildProgressCard() {
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return ValueListenableBuilder<int>(
      valueListenable: AdhkarProgressService.notifier,
      builder: (context, _, __) {
        return FutureBuilder<Map<String, int>>(
          future: Future.wait([
            AdhkarProgressService.getTotalCompletedToday(),
            AdhkarProgressService.getStreak(),
          ]).then((values) => {
            'completed': values[0],
            'streak': values[1],
          }),
          builder: (context, snapshot) {
            final data = snapshot.data ?? {'completed': 0, 'streak': 0};
            final completed = data['completed'] ?? 0;
            final streak = data['streak'] ?? 0;
            final progress = completed / 50; // افتراضي: 50 ذكر = إنجاز اليوم

            return AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final glow = _glowController.value;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                        const Color(0xFF0B2B26),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                        blurRadius: 15 + 10 * glow,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
                                  const Color(0xFF8B6914),
                                ],
                              ),
                            ),
                            child: const Icon(Icons.insights, color: Color(0xFF0B2B26), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? 'تقدمك اليومي' : 'Your Progress',
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFFD4AF37),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isAr ? 'أكملت $completed من أذكار اليوم' : 'Completed $completed adhkar today',
                                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 8,
                          backgroundColor: const Color(0xFF0B2B26),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B2B26).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(isAr ? 'Streak' : 'Streak',
                                          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10)),
                                      Text('$streak',
                                          style: GoogleFonts.cairo(
                                              color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B2B26).withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(isAr ? 'اليوم' : 'Today',
                                          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10)),
                                      Text('$completed',
                                          style: GoogleFonts.cairo(
                                              color: const Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ═══════════ الهيدر المزخرف ═══════════
  Widget _buildHeader() {
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(18),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                child: const Icon(Icons.favorite, color: Color(0xFF0B2B26), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFB8860B), Color(0xFFFFE9A8), Color(0xFFD4AF37), Color(0xFFFFE9A8)],
                      ).createShader(bounds),
                      child: Text(
                        isAr ? 'الأذكار والأدعية' : 'Adhkar & Dua',
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? 'ورد الصباح والمساء' : 'Morning & Evening Remembrance',
                      style: GoogleFonts.cairo(color: Colors.white60, fontSize: 12),
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

  // ═══════════ شريط التصنيفات ═══════════
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allAdhkar.length,
        itemBuilder: (context, i) {
          final cat = allAdhkar[i];
          final isSelected = cat.id == _selectedCategoryId;
          return GestureDetector(
            onTap: () => _selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [cat.color, cat.color.withOpacity(0.7)])
                    : null,
                color: isSelected ? null : const Color(0xFF143B32),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? cat.color : cat.color.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: cat.color.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    cat.icon,
                    color: isSelected ? const Color(0xFF0B2B26) : cat.color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _catName(cat),
                    style: GoogleFonts.cairo(
                      color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _catName(AdhkarCategory cat) {
    switch (cat.name) {
      case 'MORNING': return LanguageManager.t('adhkar_morning_title');
      case 'EVENING': return LanguageManager.t('adhkar_evening_title');
      case 'SLEEP': return LanguageManager.t('adhkar_sleep_title');
      case 'AFTER_PRAYER': return LanguageManager.t('adhkar_after_prayer_title');
      case 'DUAS': return LanguageManager.t('duas_title');
      default: return cat.name;
    }
  }

  // ═══════════ مؤشر التقدم ═══════════
  Widget _buildProgressIndicator(double progress) {
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_currentIndex + 1} / ${_currentCategory.items.length}',
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 13),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.cairo(
                  color: _currentCategory.color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF143B32),
              valueColor: AlwaysStoppedAnimation<Color>(_currentCategory.color),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════ بطاقة الذكر ═══════════
  Widget _buildDhikrCard(bool isComplete) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _currentCategory.color.withOpacity(0.5 + 0.4 * glow),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _currentCategory.color.withOpacity(0.15 + 0.25 * glow),
                blurRadius: 18 + 12 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(top: 6, right: 6, child: _corner(_currentCategory.color)),
              Positioned(top: 6, left: 6, child: Transform.rotate(angle: 1.5708, child: _corner(_currentCategory.color))),
              Positioned(bottom: 6, right: 6, child: Transform.rotate(angle: -1.5708, child: _corner(_currentCategory.color))),
              Positioned(bottom: 6, left: 6, child: Transform.rotate(angle: 3.1416, child: _corner(_currentCategory.color))),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (isComplete)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                LanguageManager.currentLanguage.value == 'ar'
                                    ? 'مكتمل ✓'
                                    : 'Completed ✓',
                                style: GoogleFonts.cairo(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // النص العربي
                    Text(
                      _currentDhikr.text,
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 22,
                        height: 2,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // الترجمة
                    if (_currentDhikr.translation != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B2B26).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _currentCategory.color.withOpacity(0.2)),
                        ),
                        child: Text(
                          _currentDhikr.translation!,
                          style: GoogleFonts.cairo(
                            color: Colors.white60,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    // الفضل
                    if (_currentDhikr.virtue != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _currentCategory.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _currentCategory.color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: _currentCategory.color, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentDhikr.virtue!,
                                style: GoogleFonts.cairo(
                                  color: _currentCategory.color,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
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

  // ═══════════ العداد الدائري ═══════════
  Widget _buildCounter(double progress) {
    final isComplete = _counter >= _currentDhikr.count;
    return Center(
      child: GestureDetector(
        onTap: _increment,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.04);
            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: 250, height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // التوهج الخارجي
                    Container(
                      width: 250, height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _currentCategory.color.withOpacity(
                              isComplete ? 0.4 : 0.3 + _pulseController.value * 0.2,
                            ),
                            blurRadius: 35,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // حلقة التقدم
                    SizedBox(
                      width: 250, height: 250,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 14,
                        backgroundColor: const Color(0xFF143B32),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete ? Colors.greenAccent : _currentCategory.color,
                        ),
                      ),
                    ),
                    // الدائرة الداخلية
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: _currentCategory.color.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                _currentCategory.color,
                                _currentCategory.color.withOpacity(0.7),
                                _currentCategory.color,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              '$_counter',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 68,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '/ ${_currentDhikr.count}',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentCategory.color.withOpacity(0.15),
                            ),
                            child: Icon(
                              Icons.touch_app,
                              color: _currentCategory.color,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════ أزرار التحكم ═══════════
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(Icons.skip_previous, _prev, isAr: false),
        const SizedBox(width: 20),
        _buildControlButton(Icons.refresh, _reset, isMain: true),
        const SizedBox(width: 20),
        _buildControlButton(Icons.skip_next, _next, isAr: true),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap,
      {bool isMain = false, bool isAr = false}) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(35),
            child: Container(
              width: isMain ? 70 : 60,
              height: isMain ? 70 : 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isMain
                    ? LinearGradient(
                        colors: [
                          Color.lerp(_currentCategory.color, const Color(0xFFFFE9A8), glow)!,
                          _currentCategory.color,
                        ],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                      ),
                border: Border.all(
                  color: _currentCategory.color.withOpacity(isMain ? 0.8 : 0.4),
                  width: isMain ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentCategory.color.withOpacity(isMain ? 0.4 : 0.15),
                    blurRadius: isMain ? 15 : 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isMain ? const Color(0xFF0B2B26) : _currentCategory.color,
                size: isMain ? 32 : 26,
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════ زخرفة الزاوية ═══════════
  Widget _corner(Color color, {double size = 22}) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(painter: _AdhkarCornerPainter(color)),
    );
  }
}

class _AdhkarCornerPainter extends CustomPainter {
  final Color color;
  _AdhkarCornerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.1, size.width * 0.4, 0);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.15), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _AdhkarCornerPainter oldDelegate) => false;
}
