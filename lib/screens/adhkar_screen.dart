import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';
import 'adhkar_data.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});
  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  String _selectedCategoryId = 'morning';
  int _currentIndex = 0;
  int _counter = 0;

  AdhkarCategory get _currentCategory =>
      allAdhkar.firstWhere((c) => c.id == _selectedCategoryId);

  Dhikr get _currentDhikr => _currentCategory.items[_currentIndex];

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
      if (_counter == _currentDhikr.count) {
        _showCompletionDialog();
      }
    }
  }

  void _showCompletionDialog() {
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
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
              SizedBox(width: 10),
              Text('أكملت الذكر! 🎉', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('أتممت ${_currentDhikr.count} مرة',
              style: const TextStyle(color: Colors.white70)),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _next();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
              ),
              child: const Text('التالي', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _reset() => setState(() => _counter = 0);

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


  String _catName(String key) {
    switch (key) {
      case 'MORNING': return LanguageManager.t('adhkar_morning_title');
      case 'EVENING': return LanguageManager.t('adhkar_evening_title');
      case 'SLEEP': return LanguageManager.t('adhkar_sleep_title');
      case 'AFTER_PRAYER': return LanguageManager.t('adhkar_after_prayer_title');
      case 'DUAS': return LanguageManager.t('duas_title');
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _counter / _currentDhikr.count;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // اختيار القسم
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allAdhkar.length,
            itemBuilder: (context, i) {
              final cat = allAdhkar[i];
              final isSelected = cat.id == _selectedCategoryId;
              return GestureDetector(
                onTap: () => _selectCategory(cat.id),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? cat.color : const Color(0xFF143B32),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? cat.color : cat.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon,
                          color: isSelected ? const Color(0xFF0B2B26) : cat.color,
                          size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _catName(cat.name),
                        style: TextStyle(
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
        ),
        const SizedBox(height: 20),

        // شريط تقدم الأذكار
        Row(
          children: [
            Text('${_currentIndex + 1} / ${_currentCategory.items.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _currentCategory.items.length,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF143B32),
                  valueColor: AlwaysStoppedAnimation<Color>(_currentCategory.color),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // بطاقة الذكر
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _currentCategory.color, width: 1.5),
          ),
          child: Column(
            children: [
              Text(_currentDhikr.text,
                  style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.8, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center),
              if (_currentDhikr.translation != null && LanguageManager.currentLanguage.value != 'ar') ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B2B26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(LanguageManager.currentLanguage.value == 'ar' ? _currentDhikr.translation! : _currentDhikr.translation!,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ),
              ],
              if (_currentDhikr.virtue != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _currentCategory.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: _currentCategory.color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_currentDhikr.virtue!,
                            style: TextStyle(color: _currentCategory.color, fontSize: 12),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // العداد الدائري
        Center(
          child: GestureDetector(
            onTap: _increment,
            child: SizedBox(
              width: 220, height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220, height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFF143B32),
                      valueColor: AlwaysStoppedAnimation<Color>(_currentCategory.color),
                    ),
                  ),
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF143B32),
                      shape: BoxShape.circle,
                      border: Border.all(color: _currentCategory.color.withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_counter',
                            style: TextStyle(color: _currentCategory.color, fontSize: 54, fontWeight: FontWeight.bold)),
                        Text('/ ${_currentDhikr.count}', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                        const SizedBox(height: 6),
                        const Icon(Icons.touch_app, color: Colors.white38, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // أزرار التحكم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circleBtn(Icons.skip_previous, _prev, _currentCategory.color),
            const SizedBox(width: 16),
            _circleBtn(Icons.refresh, _reset, _currentCategory.color),
            const SizedBox(width: 16),
            _circleBtn(Icons.skip_next, _next, _currentCategory.color),
          ],
        ),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 55, height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
