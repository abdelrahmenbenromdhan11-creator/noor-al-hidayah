import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'store_screen.dart';
import 'quiz_questions.dart';
import '../i18n/language_manager.dart';
import '../services/points_service.dart';
import '../services/ads_service.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _points = 1240;
  int _streak = 7;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _correct = false;
  bool _promoUsed = false;
  bool _todayCompleted = false;
  int _adsWatched = 0;
  bool _loading = true;
  final TextEditingController _promoController = TextEditingController();

  List<QuizQuestion> _todayQuestions = [];

  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

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
    _load();
  }

  Future<void> _load() async {
    final points = await PointsService.getPoints();
    final promo = await PointsService.isPromoUsed();
    final ads = await PointsService.getAdsWatchedToday();
    final today = DateTime.now();
    final random = Random(today.day + today.month * 31 + today.year * 365);
    final indices = List<int>.generate(allQuizQuestions.length, (i) => i)..shuffle(random);
    final selected = indices.take(5).toList();
    setState(() {
      _points = points;
      _promoUsed = promo;
      _adsWatched = ads;
      _todayQuestions = selected.map((i) => allQuizQuestions[i]).toList();
      _loading = false;
    });
    _fadeController.forward();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _correct = index == _todayQuestions[_currentQuestion].correct;
      if (_correct) {
        _points += 20;
        PointsService.addPoints(20);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < 4) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = null;
        _answered = false;
        _correct = false;
      });
    } else {
      setState(() => _todayCompleted = true);
    }
  }

  // ═══════════ مشاهدة إعلان لربح 20 نقطة ═══════════
  Future<void> _watchAd() async {
    final isAr = LanguageManager.currentLanguage.value == 'ar';

    _showSnack(
      isAr ? '⏳ جاري تحميل الإعلان...' : '⏳ Loading ad...',
      const Color(0xFFD4AF37),
    );

    await AdsService.loadRewardedAd(
      onRewarded: (amount) async {
        // ═══ المستخدم شاهد الإعلان كاملًا → يمنح 20 نقطة ═══
        await PointsService.addPoints(20);
        if (mounted) {
          setState(() => _points += 20);
          _showSnack(
            '🎉 +20 ${LanguageManager.t('points')}',
            Colors.green,
          );
        }
        AdsService.reset();
      },
      onError: (error) {
        if (mounted) {
          _showSnack(
            isAr ? '❌ تعذر تحميل الإعلان' : '❌ Failed to load ad',
            Colors.red,
          );
        }
        AdsService.reset();
      },
    );
  }

  void _openPromoDialog() {
    _promoController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          backgroundColor: const Color(0xFF143B32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          title: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Color(0xFFD4AF37)),
              const SizedBox(width: 10),
              Text(LanguageManager.t('promo_code'),
                  style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold)),
            ],
          ),
          content: TextField(
            controller: _promoController,
            style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'NAH2026',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF0B2B26),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = _promoController.text.trim().toUpperCase();
                Navigator.pop(ctx);
                if (code == 'NAH2026' && !_promoUsed) {
                  await PointsService.addPoints(1000);
                  await PointsService.usePromo();
                  setState(() {
                    _points += 1000;
                    _promoUsed = true;
                  });
                  _showSnack('🎉 +1000', Colors.green);
                } else if (_promoUsed) {
                  _showSnack('⚠️ Already used', Colors.orange);
                } else {
                  _showSnack('❌ Invalid code', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B2B26)),
              child: Text('تأكيد',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
    }

    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        return FadeTransition(
          opacity: _fadeIn,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsRow(),
              const SizedBox(height: 14),
              _buildPromoCard(),
              const SizedBox(height: 10),
              _buildAdCard(),
              const SizedBox(height: 10),
              _buildStoreCard(),
              const SizedBox(height: 20),
              if (_todayCompleted) _buildCompletedCard() else _buildQuizBody(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ الهيدر ═══════════
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
                child: const Icon(Icons.emoji_events, color: Color(0xFF0B2B26), size: 28),
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
                        isAr ? 'تحدي الإيمان' : 'Faith Challenge',
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? 'اختبر معرفتك واكسب النقاط' : 'Test your knowledge & earn points',
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

  // ═══════════ النقاط والـ Streak ═══════════
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              Icons.star,
              LanguageManager.t('points'),
              '$_points',
              const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              Icons.local_fire_department,
              LanguageManager.t('streak'),
              '$_streak',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withOpacity(0.4 + 0.3 * glow),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1 + 0.15 * glow),
                blurRadius: 12 + 8 * glow,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11)),
                    Text(value,
                        style: GoogleFonts.cairo(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ بطاقة Promo ═══════════
  Widget _buildPromoCard() {
    return _actionCard(
      icon: Icons.redeem,
      title: LanguageManager.t('promo_code'),
      subtitle: LanguageManager.t('enter_promo'),
      badge: '+1000',
      onTap: _openPromoDialog,
      color: const Color(0xFFD4AF37),
    );
  }

  // ═══════════ بطاقة النقاط المجانية (20 نقطة) ═══════════
  Widget _buildAdCard() {
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    return _actionCard(
      icon: Icons.card_giftcard,
      title: isAr ? 'اضغط لربح 20 نقطة' : 'Tap to earn 20 points',
      subtitle: isAr ? 'بدون حدود • فوري' : 'Unlimited • Instant',
      badge: '+20',
      onTap: _watchAd,
      color: const Color(0xFF2ECC71),
    );
  }

  // ═══════════ بطاقة المتجر ═══════════
  Widget _buildStoreCard() {
    return _actionCard(
      icon: Icons.store,
      title: LanguageManager.t('store'),
      subtitle: LanguageManager.currentLanguage.value == 'ar'
          ? 'استبدل نقاطك'
          : 'Spend your points',
      badge: null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StoreScreen()),
      ),
      color: const Color(0xFF4ECDC4),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String? badge,
    required VoidCallback onTap,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(const Color(0xFF143B32), color.withOpacity(0.15), glow * 0.5)!,
                      const Color(0xFF0B2B26),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.4 + 0.4 * glow), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08 + 0.12 * glow),
                      blurRadius: 10 + 8 * glow,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(badge,
                            style: GoogleFonts.cairo(
                              color: const Color(0xFF0B2B26),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            )),
                      )
                    else
                      Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════ بطاقة الاكتمال ═══════════
  Widget _buildCompletedCard() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow)!,
                const Color(0xFF0B2B26),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2 + 0.3 * glow),
                blurRadius: 20 + 10 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 100, height: 100,
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
                      color: const Color(0xFFD4AF37).withOpacity(0.6 * glow),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF0B2B26), size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                LanguageManager.t('completed_today'),
                style: GoogleFonts.cairo(
                  color: const Color(0xFFD4AF37),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2B26).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, color: Color(0xFFD4AF37), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      LanguageManager.t('come_back_tomorrow'),
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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

  // ═══════════ جسم التحدي ═══════════
  Widget _buildQuizBody() {
    if (_todayQuestions.isEmpty) return const SizedBox();
    final q = _todayQuestions[_currentQuestion];
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    final questionText = isAr ? q.qAr : q.qEn;
    final options = isAr ? q.optsAr : q.optsEn;
    final progress = (_currentQuestion + 1) / 5;

    return Column(
      children: [
        // شريط التقدم
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${LanguageManager.t('question')} ${_currentQuestion + 1} ${LanguageManager.t('of')} 5',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 12,
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
                  minHeight: 7,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // بطاقة السؤال
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glow = _glowController.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(const Color(0xFF1E4D40), const Color(0xFF2B6E5C), glow * 0.5)!,
                    const Color(0xFF0B2B26),
                  ],
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
                  const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 32),
                  const SizedBox(height: 10),
                  Text(
                    LanguageManager.t('daily_challenge'),
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    questionText,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+20 ${LanguageManager.t('points')}',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        // الخيارات
        ...List.generate(options.length, (i) => _buildAnswerTile(q, options[i], i)),

        // زر التالي
        if (_answered) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _currentQuestion < 4
                      ? LanguageManager.t('next_question')
                      : LanguageManager.t('finish_challenge'),
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B2B26),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerTile(QuizQuestion q, String option, int i) {
    Color bgColor = const Color(0xFF143B32);
    Color borderColor = const Color(0xFFD4AF37).withOpacity(0.3);
    Color textColor = Colors.white;
    IconData? trailingIcon;

    if (_answered) {
      if (i == q.correct) {
        bgColor = const Color(0xFF1E4D40);
        borderColor = Colors.green;
        textColor = Colors.greenAccent;
        trailingIcon = Icons.check_circle;
      } else if (i == _selectedAnswer && !_correct) {
        bgColor = const Color(0xFF3B1414);
        borderColor = Colors.red;
        textColor = Colors.redAccent;
        trailingIcon = Icons.cancel;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () => _selectAnswer(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: _answered && (i == q.correct || i == _selectedAnswer) ? 2 : 1.5,
            ),
            boxShadow: _answered && i == q.correct
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor.withOpacity(0.2),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.cairo(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.cairo(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: textColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
