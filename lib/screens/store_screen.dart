import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../i18n/language_manager.dart';
import '../services/points_service.dart';
import '../services/store_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  int _points = 1240;
  Set<String> _owned = {};
  Map<String, String> _equipped = {};
  String _selectedCategory = 'all';
  bool _loading = true;
  late AnimationController _glowController;

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'الكل'},
    {'id': 'theme', 'label': '🎨 ثيمات'},
    {'id': 'wallpaper', 'label': '🖼️ خلفيات'},
    {'id': 'reciter', 'label': '🎙️ قراء'},
    {'id': 'badge', 'label': '🏅 شارات'},
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    final points = await PointsService.getPoints();
    final owned = await StoreService.getOwned();
    final equipped = await StoreService.getEquipped();
    setState(() {
      _points = points;
      _owned = owned;
      _equipped = equipped;
      _loading = false;
    });
  }

  List<StoreProduct> get _filteredItems {
    if (_selectedCategory == 'all') return StoreService.products;
    return StoreService.products
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  List<StoreProduct> get _myItems => StoreService.products
      .where((p) => _owned.contains(p.id))
      .toList();

  bool _isEquipped(StoreProduct p) {
    return _equipped[p.category] == p.id;
  }

  Future<void> _buy(StoreProduct product) async {
    if (_owned.contains(product.id)) {
      _showSnack('✅ Already owned', Colors.blue);
      return;
    }

    final success = await StoreService.buy(product, _points);
    if (success) {
      setState(() {
        _points -= product.price;
        _owned.add(product.id);
      });
      _showSnack('🎉 Purchased: ${product.nameEn}', Colors.green);
    } else {
      _showSnack(LanguageManager.t('not_enough_points'), Colors.red);
    }
  }

  Future<void> _equip(StoreProduct product) async {
    final isCurrentlyEquipped = _isEquipped(product);

    if (isCurrentlyEquipped) {
      await StoreService.unequip(product.category);
      setState(() {
        _equipped[product.category] = '';
      });
      _showSnack('🔓 Removed from ${product.category}', Colors.orange);
    } else {
      await StoreService.equip(product);
      setState(() {
        _equipped[product.category] = product.id;
      });
      _showSnack('✅ Activated: ${product.nameEn}', Colors.green);
    }
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
        final isAr = lang == 'ar';
        return DefaultTabController(
          length: 2,
          child: Directionality(
            textDirection:
                LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: const Color(0xFF143B32),
                title: Text(LanguageManager.t('store'),
                    style: GoogleFonts.cairo(color: const Color(0xFFD4AF37))),
                centerTitle: true,
                iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
                bottom: TabBar(
                  indicatorColor: const Color(0xFFD4AF37),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFFD4AF37),
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.cairo(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                        icon: const Icon(Icons.storefront, size: 20),
                        text: isAr ? 'المتجر' : 'Store'),
                    Tab(
                        icon: const Icon(Icons.inventory_2, size: 20),
                        text: isAr ? 'مملوكاتي' : 'My Items'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildStoreTab(isAr),
                  _buildOwnedTab(isAr),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreTab(bool isAr) {
    return Column(
      children: [
        _buildPointsBanner(isAr),
        _buildCategoryTabs(),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: _filteredItems.length,
            itemBuilder: (context, i) =>
                _buildItemCard(_filteredItems[i], isAr),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsBanner(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Color.lerp(
                  const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.2 * glow),
                blurRadius: 15 + 10 * glow,
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
                      Color.lerp(const Color(0xFFD4AF37),
                          const Color(0xFFFFE9A8), glow)!,
                      const Color(0xFF8B6914),
                    ],
                  ),
                ),
                child: const Icon(Icons.star,
                    color: Color(0xFF0B2B26), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LanguageManager.t('points'),
                        style: GoogleFonts.cairo(
                            color: Colors.white70, fontSize: 13)),
                    Text('$_points',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFD4AF37),
                          fontSize: 24,
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

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = cat['id'] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8860B)])
                    : null,
                color: isSelected ? null : const Color(0xFF143B32),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: GoogleFonts.cairo(
                    color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════ بطاقة المنتج (بصورة) ═══════════
  Widget _buildItemCard(StoreProduct product, bool isAr) {
    final owned = _owned.contains(product.id);
    final equipped = _isEquipped(product);
    final canAfford = _points >= product.price;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return GestureDetector(
          onTap: () => owned ? _equip(product) : _buy(product),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF143B32), Color(0xFF0B2B26)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: equipped
                    ? const Color(0xFFD4AF37)
                    : owned
                        ? Colors.green
                        : product.color.withOpacity(0.4 + 0.3 * glow),
                width: equipped ? 3 : owned ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: product.color.withOpacity(0.1 + 0.15 * glow),
                  blurRadius: 12 + 8 * glow,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ═══ الصورة ═══
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        product.color.withOpacity(0.4),
                                        product.color.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                  ),
                                  child: Icon(product.icon,
                                      color: Colors.white, size: 50),
                                ),
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: product.color.withOpacity(0.1),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFD4AF37),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      product.color.withOpacity(0.4),
                                      product.color.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(product.icon,
                                    color: Colors.white, size: 50),
                              ),
                        // تظليل خفيف لقراءة النص
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        // شارة الحالة
                        if (equipped)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFFD4AF37), Color(0xFF8B6914)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37)
                                        .withOpacity(0.6),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF0B2B26), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAr ? 'مُفعّل' : 'Active',
                                    style: GoogleFonts.cairo(
                                      color: const Color(0xFF0B2B26),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (owned)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isAr ? 'مملوك' : 'Owned',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // ═══ النص والسعر ═══
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? product.nameAr : product.nameEn,
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!owned)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: canAfford
                                  ? const LinearGradient(colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFB8860B)
                                    ])
                                  : null,
                              color: canAfford ? null : const Color(0xFF3B1414),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: canAfford
                                    ? const Color(0xFFD4AF37)
                                    : Colors.redAccent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    color: canAfford
                                        ? const Color(0xFF0B2B26)
                                        : Colors.redAccent,
                                    size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${product.price}',
                                  style: GoogleFonts.cairo(
                                    color: canAfford
                                        ? const Color(0xFF0B2B26)
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: equipped
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : const Color(0xFFD4AF37).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: equipped
                                    ? Colors.redAccent
                                    : const Color(0xFFD4AF37),
                              ),
                            ),
                            child: Text(
                              equipped
                                  ? (isAr ? 'اضغط للإلغاء' : 'Tap to remove')
                                  : (isAr ? 'اضغط للتفعيل' : 'Tap to activate'),
                              style: GoogleFonts.cairo(
                                color: equipped
                                    ? Colors.redAccent
                                    : const Color(0xFFD4AF37),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════ تبويب مملوكاتي ═══════════
  Widget _buildOwnedTab(bool isAr) {
    if (_myItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.inventory_2_outlined,
                  color: Color(0xFFD4AF37), size: 60),
            ),
            const SizedBox(height: 20),
            Text(
              isAr ? 'لم تشترِ أي عنصر بعد' : 'You have no items yet',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myItems.length,
      itemBuilder: (context, i) => _buildOwnedCard(_myItems[i], isAr),
    );
  }

  Widget _buildOwnedCard(StoreProduct product, bool isAr) {
    final isEquipped = _isEquipped(product);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEquipped
                  ? [
                      Color.lerp(const Color(0xFF1E4D40),
                          const Color(0xFF2B6E5C), glow)!,
                      const Color(0xFF0B2B26),
                    ]
                  : [const Color(0xFF143B32), const Color(0xFF0B2B26)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEquipped
                  ? Color.lerp(
                      const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!
                  : product.color.withOpacity(0.3),
              width: isEquipped ? 2 : 1.5,
            ),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color:
                          const Color(0xFFD4AF37).withOpacity(0.2 + 0.3 * glow),
                      blurRadius: 15 + 10 * glow,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // دائرة مزخرفة
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        product.color.withOpacity(0.4),
                        product.color.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(color: product.color, width: 2),
                  ),
                  child: Icon(product.icon, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? product.nameAr : product.nameEn,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isEquipped)
                        Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              isAr ? 'مُفعّل' : 'Equipped',
                              style: GoogleFonts.cairo(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          isAr ? 'غير مُفعّل' : 'Not equipped',
                          style: GoogleFonts.cairo(
                              color: Colors.white54, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () => _equip(product),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isEquipped
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
                      color: isEquipped ? const Color(0xFF3B1414) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEquipped
                            ? Colors.redAccent
                            : const Color(0xFFD4AF37),
                      ),
                    ),
                    child: Icon(
                      isEquipped ? Icons.close : Icons.check,
                      color: isEquipped
                          ? Colors.redAccent
                          : const Color(0xFF0B2B26),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
