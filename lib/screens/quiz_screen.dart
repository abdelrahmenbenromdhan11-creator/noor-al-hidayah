import 'package:flutter/material.dart';

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

  final TextEditingController _promoController = TextEditingController();

  final List<Map<String, dynamic>> _questions = [
    {'question': 'كم عدد الصلوات المفروضة في اليوم؟', 'options': ['ثلاث', 'خمس', 'سبع'], 'correct': 1, 'points': 20},
    {'question': 'في أي شهر يصوم المسلمون؟', 'options': ['شعبان', 'رمضان', 'شوال'], 'correct': 1, 'points': 20},
    {'question': 'كم عدد أركان الإسلام؟', 'options': ['أربعة', 'خمسة', 'ستة'], 'correct': 1, 'points': 20},
    {'question': 'ما هي أول سورة في القرآن الكريم؟', 'options': ['البقرة', 'الفاتحة', 'الإخلاص'], 'correct': 1, 'points': 20},
    {'question': 'كم عدد أجزاء القرآن الكريم؟', 'options': ['20', '30', '40'], 'correct': 1, 'points': 20},
  ];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _correct = index == _questions[_currentQuestion]['correct'];
      if (_correct) {
        _points += _questions[_currentQuestion]['points'] as int;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestion < _questions.length - 1) {
        _currentQuestion++;
      } else {
        _currentQuestion = 0;
      }
      _selectedAnswer = null;
      _answered = false;
      _correct = false;
    });
  }

  void _openPromoDialog() {
    _promoController.clear();
    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: const Color(0xFF143B32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
            ),
            title: const Row(
              children: [
                Icon(Icons.card_giftcard, color: Color(0xFFD4AF37)),
                SizedBox(width: 10),
                Text('كود المكافأة', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('أدخل كود المكافأة للحصول على نقاط إضافية',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: () {
                  final code = _promoController.text.trim().toUpperCase();
                  Navigator.pop(ctx);
                  if (code == 'NAH2026' && !_promoUsed) {
                    setState(() {
                      _points += 1000;
                      _promoUsed = true;
                    });
                    _showSnack('🎉 مبروك! تمت إضافة 1000 نقطة', Colors.green);
                  } else if (_promoUsed) {
                    _showSnack('⚠️ لقد استخدمت هذا الكود مسبقًا', Colors.orange);
                  } else {
                    _showSnack('❌ كود غير صحيح', Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B2B26),
                ),
                child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
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
    final q = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF143B32),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFD4AF37), size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('النقاط', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('$_points', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF143B32),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Streak', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Text('$_streak أيام', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // زر كود المكافأة
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openPromoDialog,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E4D40), Color(0xFF143B32)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.redeem, color: Color(0xFFD4AF37), size: 26),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('عندك كود مكافأة؟', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('أدخل الكود لتحصل على نقاط', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('+1000', style: TextStyle(color: Color(0xFF0B2B26), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // شريط تقدم
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('السؤال ${_currentQuestion + 1} من ${_questions.length}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF0B2B26),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // بطاقة السؤال
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1),
          ),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 36),
              const SizedBox(height: 12),
              const Text('التحدي اليومي', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(q['question'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('+${q['points']} نقطة', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...List.generate((q['options'] as List).length, (i) {
          Color bgColor = const Color(0xFF143B32);
          Color borderColor = const Color(0xFFD4AF37).withOpacity(0.3);
          Color textColor = Colors.white;
          IconData? trailingIcon;

          if (_answered) {
            if (i == q['correct']) {
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
                border: Border.all(
                  color: borderColor,
                  width: _answered && (i == q['correct'] || i == _selectedAnswer) ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)),
                    child: Center(child: Text('${i + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Text((q['options'] as List)[i], style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.w500))),
                  if (trailingIcon != null) Icon(trailingIcon, color: textColor, size: 24),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        if (_answered)
          ElevatedButton.icon(
            onPressed: _nextQuestion,
            icon: const Icon(Icons.arrow_forward),
            label: Text(_currentQuestion < _questions.length - 1 ? 'السؤال التالي' : 'إعادة التحدي', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0B2B26),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
      ],
    );
  }
}
