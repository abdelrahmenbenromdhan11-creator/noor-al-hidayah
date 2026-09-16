import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';

class StoreProduct {
  final String id;
  final String nameAr;
  final String nameEn;
  final String category;
  final int price;
  final IconData icon;
  final Color color;
  final String? themeId;
  final String? reciterId;
  final String? imageUrl;
  const StoreProduct({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.themeId,
    this.reciterId,
    this.imageUrl,
  });
}

class StoreService {
  static final ValueNotifier<int> notifier = ValueNotifier(0);

  static const List<StoreProduct> products = [
    // ═══════════════ الثيمات ═══════════════
    StoreProduct(
      id: 'theme_purple',
      nameAr: 'ثيم بنفسجي ملكي',
      nameEn: 'Royal Purple Theme',
      category: 'theme',
      price: 800,
      icon: Icons.palette,
      color: Color(0xFF9B59B6),
      themeId: 'theme_purple',
      imageUrl: 'assets/store/theme_purple.jpg',
    ),
    StoreProduct(
      id: 'theme_sky',
      nameAr: 'ثيم أزرق سماوي',
      nameEn: 'Sky Blue Theme',
      category: 'theme',
      price: 700,
      icon: Icons.palette,
      color: Color(0xFF3498DB),
      themeId: 'theme_sky',
      imageUrl: 'assets/store/theme_sky.jpg',
    ),
    StoreProduct(
      id: 'theme_emerald',
      nameAr: 'ثيم أخضر زمردي',
      nameEn: 'Emerald Green Theme',
      category: 'theme',
      price: 900,
      icon: Icons.palette,
      color: Color(0xFF2ECC71),
      themeId: 'theme_emerald',
      imageUrl: 'assets/store/theme_emerald.jpg',
    ),

    // ═══════════════ الخلفيات ═══════════════
    StoreProduct(
      id: 'wallpaper_kaaba',
      nameAr: 'خلفية الكعبة',
      nameEn: 'Kaaba Wallpaper',
      category: 'wallpaper',
      price: 500,
      icon: Icons.mosque,
      color: Color(0xFFD4AF37),
      imageUrl: 'assets/store/wallpaper_kaaba.jpg',
    ),
    StoreProduct(
      id: 'wallpaper_madinah',
      nameAr: 'خلفية المسجد النبوي',
      nameEn: 'Prophet Mosque Wallpaper',
      category: 'wallpaper',
      price: 500,
      icon: Icons.mosque,
      color: Color(0xFF4ECDC4),
      imageUrl: 'assets/store/wallpaper_madinah.jpg',
    ),
    StoreProduct(
      id: 'wallpaper_pattern',
      nameAr: 'زخرفة إسلامية',
      nameEn: 'Islamic Pattern',
      category: 'wallpaper',
      price: 400,
      icon: Icons.auto_awesome,
      color: Color(0xFF95E1D3),
      imageUrl: 'assets/store/wallpaper_pattern.jpg',
    ),

    // ═══════════════ القرّاء ═══════════════
    StoreProduct(
      id: 'reciter_ajamy',
      nameAr: 'الشيخ أحمد العجمي',
      nameEn: 'Sheikh Ahmed Al-Ajamy',
      category: 'reciter',
      price: 600,
      icon: Icons.mic,
      color: Color(0xFFE74C3C),
      reciterId: 'ar.ahmedajamy',
      imageUrl: 'assets/store/reciter_ajamy.jpg',
    ),
    StoreProduct(
      id: 'reciter_shatri',
      nameAr: 'الشيخ أبو بكر الشاطري',
      nameEn: 'Sheikh Abu Bakr Al-Shatri',
      category: 'reciter',
      price: 600,
      icon: Icons.mic,
      color: Color(0xFF1ABC9C),
      reciterId: 'ar.shaatree',
      imageUrl: 'assets/store/reciter_shatri.jpg',
    ),
    StoreProduct(
      id: 'reciter_husary',
      nameAr: 'الشيخ محمود الحصري',
      nameEn: 'Sheikh Mahmoud Al-Husary',
      category: 'reciter',
      price: 600,
      icon: Icons.mic,
      color: Color(0xFF16A085),
      reciterId: 'ar.husary',
      imageUrl: 'assets/store/reciter_husary.jpg',
    ),
    StoreProduct(
      id: 'reciter_minshawi',
      nameAr: 'الشيخ المنشاوي',
      nameEn: 'Sheikh Al-Minshawi',
      category: 'reciter',
      price: 700,
      icon: Icons.mic,
      color: Color(0xFF27AE60),
      reciterId: 'ar.minshawi',
      imageUrl: 'assets/store/reciter_minshawi.jpg',
    ),

    // ═══════════════ الشارات ═══════════════
    StoreProduct(
      id: 'badge_gold',
      nameAr: 'شارة Streak ذهبية',
      nameEn: 'Gold Streak Badge',
      category: 'badge',
      price: 300,
      icon: Icons.local_fire_department,
      color: Color(0xFFFF6B00),
      imageUrl: 'assets/store/badge_gold.jpg',
    ),
    StoreProduct(
      id: 'badge_challenger',
      nameAr: 'شارة المتحدي',
      nameEn: 'Challenger Badge',
      category: 'badge',
      price: 200,
      icon: Icons.emoji_events,
      color: Color(0xFFD4AF37),
      imageUrl: 'assets/store/badge_challenger.jpg',
    ),
    StoreProduct(
      id: 'badge_scholar',
      nameAr: 'شارة العالِم',
      nameEn: 'Scholar Badge',
      category: 'badge',
      price: 500,
      icon: Icons.school,
      color: Color(0xFF8E44AD),
      imageUrl: 'assets/store/badge_scholar.jpg',
    ),
  ];

  static Future<Set<String>> getOwned() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('owned_items') ?? []).toSet();
  }

  static Future<void> addOwned(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('owned_items') ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList('owned_items', list);
    }
    notifier.value++;
  }

  static Future<Map<String, String>> getEquipped() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'theme': prefs.getString('equipped_theme') ?? '',
      'wallpaper': prefs.getString('equipped_wallpaper') ?? '',
      'reciter': prefs.getString('equipped_reciter') ?? '',
      'badge': prefs.getString('equipped_badge') ?? '',
    };
  }

  static Future<String> getEquippedInCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('equipped_$category') ?? '';
  }

  static Future<void> equip(StoreProduct product) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipped_${product.category}');
    if (product.category == 'theme') {
      await ThemeService.setTheme('default_gold');
    }
    await prefs.setString('equipped_${product.category}', product.id);
    if (product.category == 'theme' && product.themeId != null) {
      await ThemeService.setTheme(product.themeId!);
    }
    notifier.value++;
  }

  static Future<void> unequip(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('equipped_$category');
    if (category == 'theme') {
      await ThemeService.setTheme('default_gold');
    }
    notifier.value++;
  }

  static Future<bool> buy(StoreProduct product, int currentPoints) async {
    if (currentPoints < product.price) return false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', currentPoints - product.price);
    await addOwned(product.id);
    return true;
  }
}
