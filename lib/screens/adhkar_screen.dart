import 'package:flutter/material.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});
  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['الصباح', 'المساء', 'بعد الصلاة', 'النوم', 'أدعية'];
  
  int _counter = 0;
  final int _target = 33;
  String _currentDhikr = 'سُبْحَانَ اللَّهِ';

  final List<Map<String, dynamic>> _adhkar = [
    {'text': 'سُبْحَانَ اللَّهِ', 'count': 33, 'translation': 'Glory be to Allah'},
    {'text': 'الْحَمْدُ لِلَّهِ', 'count': 33, 'translation': 'All praise to Allah'},
    {'text': 'اللَّهُ أَكْبَرُ', 'count': 34, 'translation': 'Allah is the Greatest'},
    {'text': 'لَا إِلَهَ إِلَّا اللَّهُ', 'count': 100, 'translation': 'There is no god but Allah'},
    {'text': 'أَسْتَغْفِرُ اللَّهَ', 'count': 100, 'translation': 'I seek Allah forgiveness'},
  ];

  void _increment() {
    setState(() {
      if (_counter < _target) _counter++;
    });
  }

  void _reset() {
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF143B32),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
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
                Text(_currentDhikr, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(_adhkar[0]['translation'], style: const TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          GestureDetector(
            onTap: _increment,
            child: SizedBox(
              width: 220, height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220, height: 220,
                    child: CircularProgressIndicator(
                      value: _counter / _target,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFF143B32),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                  ),
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF143B32),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$_counter', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 56, fontWeight: FontWeight.bold)),
                        Text('/ $_target', style: const TextStyle(color: Colors.white54, fontSize: 18)),
                        const SizedBox(height: 8),
                        const Icon(Icons.touch_app, color: Color(0xFFD4AF37), size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF143B32),
                  foregroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _counter = 0;
                    _currentDhikr = _adhkar[(_adhkar.indexWhere((d) => d['text'] == _currentDhikr) + 1) % _adhkar.length]['text'];
                  });
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('التالي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF0B2B26),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
