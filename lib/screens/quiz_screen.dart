import 'package:flutter/material.dart';
import 'store_screen.dart';
import 'quiz_questions.dart';
import '../i18n/language_manager.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _points = 1240;
  int _streak = 7;
  int _currentQuestion = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _correct = false;
  bool _promoUsed = false;
  bool _todayCompleted = false;
  final TextEditingController _promoController = TextEditingController();

  List<QuizQuestion> _todayQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadDailyQuiz();
  }

  void _loadDailyQuiz() {
    final today = DateTime.now();
    final random = Random(today.day + today.month * 31 + today.year * 365);
    final indices = List<int>.generate(allQuizQuestions.length, (i) => i)..shuffle(random);
    final selected = indices.take(5).toList();
    setState(() {
      _todayQuestions = selected.map((i) => allQuizQuestions[i]).toList();
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _correct = index == _todayQuestions[_currentQuestion].correct;
      if (_correct) _points += 20;
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

  void _openPromoDialog() {
    _promoController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
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
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LanguageManager.t('enter_promo'),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: _promoController,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'NAH2026',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF0B2B26),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
            ElevatedButton(
              onPressed: () {
                final code = _promoController.text.trim().toUpperCase();
                Navigator.pop(ctx);
                if (code == 'NAH2026' && !_promoUsed) {
                  setState(() {
                    _points += 1000;
                    _promoUsed = true;
                  });
                  _showSnack('🎉 +1000 ${LanguageManager.t('points')}', Colors.green);
                } else if (_promoUsed) {
                  _showSnack('⚠️ Already used', Colors.orange);
                } else {
                  _showSnack('❌ Invalid code', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
              ),
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _statCard(Icons.star, LanguageManager.t('points'), '$_points', const Color(0xFFD4AF37))),
              const SizedBox(width: 12),
              Expanded(child: _statCard(Icons.local_fire_department, LanguageManager.t('streak'), '$_streak', Colors.orange)),
            ],
          ),
          const SizedBox(height: 16),
          _actionCard(
            icon: Icons.redeem,
            title: LanguageManager.t('promo_code'),
            subtitle: LanguageManager.t('enter_promo'),
            badge: '+1000',
            onTap: _openPromoDialog,
          ),
          const SizedBox(height: 12),
          _actionCard(
            icon: Icons.store,
            title: LanguageManager.t('store'),
            subtitle: LanguageManager.t('store'),
            badge: null,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
          ),
          const SizedBox(height: 20),
          if (_todayCompleted) _buildCompletedCard() else _buildQuizBody(),
        ],
      ),
    );
  }

  Widget _buildCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
          begin: Alignment.topRight, end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              border: Border.all(color: const Color(0xFFD4AF37), width: 3),
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 60),
          ),
          const SizedBox(height: 20),
          Text(LanguageManager.t('completed_today'),
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2B26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, color: Color(0xFFD4AF37), size: 20),
                const SizedBox(width: 10),
                Text(LanguageManager.t('come_back_tomorrow'),
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBody() {
    if (_todayQuestions.isEmpty) return const SizedBox();
    final q = _todayQuestions[_currentQuestion];
    final isAr = LanguageManager.currentLanguage.value == 'ar';
    final questionText = isAr ? q.qAr : q.qEn;
    final options = isAr ? q.optsAr : q.optsEn;
    final progress = (_currentQuestion + 1) / 5;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF143B32), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${LanguageManager.t('question')} ${_currentQuestion + 1} ${LanguageManager.t('of')} 5',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress, minHeight: 8,
                  backgroundColor: const Color(0xFF0B2B26),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight, end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 36),
              const SizedBox(height: 12),
              Text(LanguageManager.t('daily_challenge'),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(questionText,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('+20', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(options.length, (i) => _answerTile(q, options[i], i)),
        if (_answered) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _nextQuestion,
            icon: const Icon(Icons.arrow_forward),
            label: Text(_currentQuestion < 4 ? LanguageManager.t('next_question') : LanguageManager.t('finish_challenge'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B2B26),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({required IconData icon, required String title, required String subtitle, required String? badge, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E4D40), Color(0xFF143B32)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(20)),
                  child: Text(badge, style: const TextStyle(color: Color(0xFF0B2B26), fontWeight: FontWeight.bold, fontSize: 12)),
                )
              else
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerTile(QuizQuestion q, String option, int i) {
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

    return GestureDetector(
      onTap: () => _selectAnswer(i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: _answered && (i == q.correct || i == _selectedAnswer) ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)),
              child: Center(child: Text('${i + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(option, style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w500))),
            if (trailingIcon != null) Icon(trailingIcon, color: textColor, size: 24),
          ],
        ),
      ),
    );
  }
}
