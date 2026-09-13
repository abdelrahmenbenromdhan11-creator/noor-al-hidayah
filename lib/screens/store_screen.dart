import 'package:flutter/material.dart';
import '../i18n/language_manager.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _points = 1240;
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'label': 'all_cat'},
    {'id': 'wallpapers', 'label': 'Wallpapers'},
    {'id': 'themes', 'label': 'Themes'},
    {'id': 'reciters', 'label': 'Reciters'},
    {'id': 'adhkar', 'label': 'Adhkar'},
    {'id': 'badges', 'label': 'Badges'},
  ];

  final List<Map<String, dynamic>> _items = [
    {'name': 'Masjid Al-Haram', 'cat': 'wallpapers', 'price': 500, 'icon': Icons.mosque, 'color': const Color(0xFFD4AF37), 'owned': false},
    {'name': 'Masjid An-Nabawi', 'cat': 'wallpapers', 'price': 500, 'icon': Icons.mosque, 'color': const Color(0xFF4ECDC4), 'owned': false},
    {'name': 'Islamic Art', 'cat': 'wallpapers', 'price': 400, 'icon': Icons.auto_awesome, 'color': const Color(0xFF95E1D3), 'owned': false},
    {'name': 'Royal Purple', 'cat': 'themes', 'price': 800, 'icon': Icons.palette, 'color': const Color(0xFF9B59B6), 'owned': false},
    {'name': 'Black & Gold', 'cat': 'themes', 'price': 800, 'icon': Icons.palette, 'color': const Color(0xFFD4AF37), 'owned': false},
    {'name': 'Sky Blue', 'cat': 'themes', 'price': 700, 'icon': Icons.palette, 'color': const Color(0xFF3498DB), 'owned': false},
    {'name': 'Ahmed Al-Ajamy', 'cat': 'reciters', 'price': 600, 'icon': Icons.mic, 'color': const Color(0xFFE74C3C), 'owned': false},
    {'name': 'Al-Shatri', 'cat': 'reciters', 'price': 600, 'icon': Icons.mic, 'color': const Color(0xFF1ABC9C), 'owned': false},
    {'name': 'Muhammad Ayyoub', 'cat': 'reciters', 'price': 600, 'icon': Icons.mic, 'color': const Color(0xFF16A085), 'owned': false},
    {'name': 'Ramadan Adhkar', 'cat': 'adhkar', 'price': 500, 'icon': Icons.nightlight_round, 'color': const Color(0xFFF39C12), 'owned': false},
    {'name': 'Hajj Adhkar', 'cat': 'adhkar', 'price': 500, 'icon': Icons.account_balance, 'color': const Color(0xFFD4AF37), 'owned': false},
    {'name': 'Friday Adhkar', 'cat': 'adhkar', 'price': 400, 'icon': Icons.calendar_today, 'color': const Color(0xFF2ECC71), 'owned': false},
    {'name': 'Gold Streak', 'cat': 'badges', 'price': 300, 'icon': Icons.local_fire_department, 'color': const Color(0xFFFF6B00), 'owned': false},
    {'name': 'Challenger', 'cat': 'badges', 'price': 200, 'icon': Icons.emoji_events, 'color': const Color(0xFFD4AF37), 'owned': false},
  ];

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'all') return _items;
    return _items.where((i) => i['cat'] == _selectedCategory).toList();
  }

  void _buy(Map<String, dynamic> item) {
    if (item['owned'] == true) {
      _showSnack('Already owned', Colors.blue);
      return;
    }
    if (_points >= item['price']) {
      setState(() {
        _points -= item['price'] as int;
        item['owned'] = true;
      });
      _showSnack('Purchased: ${item['name']}', Colors.green);
    } else {
      _showSnack(LanguageManager.t('not_enough_points'), Colors.red);
    }
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
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('store'), style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                    ),
                    child: const Icon(Icons.star, color: Color(0xFFD4AF37), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LanguageManager.t('points'),
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('$_points',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  final isSelected = cat['id'] == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF143B32),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat['label'] == 'all_cat'
                              ? LanguageManager.t('all_cat')
                              : cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _filteredItems.length,
                itemBuilder: (context, i) => _buildItemCard(_filteredItems[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final owned = item['owned'] == true;
    final canAfford = _points >= item['price'];
    return GestureDetector(
      onTap: () => _buy(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF143B32),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: owned ? Colors.green : (item['color'] as Color).withOpacity(0.4),
            width: owned ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (item['color'] as Color).withOpacity(0.15),
              ),
              child: Icon(item['icon'], color: item['color'], size: 30),
            ),
            const SizedBox(height: 10),
            Text(item['name'],
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            if (owned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 4),
                    Text(LanguageManager.t('owned'),
                        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford ? const Color(0xFFD4AF37) : const Color(0xFF3B1414),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: canAfford ? const Color(0xFF0B2B26) : Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text('${item['price']}',
                        style: TextStyle(
                          color: canAfford ? const Color(0xFF0B2B26) : Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
