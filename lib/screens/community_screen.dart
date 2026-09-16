import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'youtube_channel_screen.dart';
import '../i18n/language_manager.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          child: Column(
            children: [
              // التبويبات
              Container(
                color: const Color(0xFF143B32),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFFD4AF37),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFFD4AF37),
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.forum, size: 20),
                      text: isAr ? 'المنشورات' : 'Posts',
                    ),
                    Tab(
                      icon: const Icon(Icons.play_circle_fill, size: 20),
                      text: isAr ? 'قناتنا' : 'Our Channel',
                    ),
                  ],
                ),
              ),

              // المحتوى
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _PostsTab(),
                    YoutubeChannelScreen(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════ تبويب المنشورات ═══════════════
class _PostsTab extends StatefulWidget {
  const _PostsTab();
  @override
  State<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<_PostsTab> {
  String _selectedCategory = 'all';
  final List<String> _catIds = ['all', 'general', 'quran', 'questions', 'reflections', 'support'];

  final List<Map<String, dynamic>> _postsData = [
    {
      'id': 1,
      'avatar': 'أ',
      'category': 'reflections',
      'contentAr': 'الحمد لله، اليوم أكملت ختم القرآن الكريم. نسأل الله الإخلاص والقبول 🤲',
      'contentEn': 'Alhamdulillah, today I completed the Quran. May Allah accept it 🤲',
      'likes': 42, 'comments': 8, 'liked': false,
      'nameAr': 'أحمد محمد', 'nameEn': 'Ahmed Muhammad',
      'timeKey': 'comm_5min',
    },
    {
      'id': 2,
      'avatar': 'ف',
      'category': 'questions',
      'contentAr': 'هل يجوز صلاة السنة بعد العصر؟ جزاكم الله خيرًا.',
      'contentEn': 'Is it allowed to pray Sunnah after Asr?',
      'likes': 15, 'comments': 12, 'liked': false,
      'nameAr': 'فاطمة علي', 'nameEn': 'Fatimah Ali',
      'timeKey': 'comm_1hour',
    },
    {
      'id': 3,
      'avatar': 'م',
      'category': 'support',
      'contentAr': 'أدعو لأمي بالشفاء العاجل، هي في العناية المركزة. اللهم اشفها 🤲',
      'contentEn': "Please pray for my mother's healing 🤲",
      'likes': 128, 'comments': 45, 'liked': false,
      'nameAr': 'محمد السيد', 'nameEn': 'Muhammad Al-Sayed',
      'timeKey': 'comm_3hours',
    },
    {
      'id': 4,
      'avatar': 'خ',
      'category': 'quran',
      'contentAr': 'سورة الملك تنجي من عذاب القبر، لا تنسوا قراءتها كل ليلة 🌙',
      'contentEn': 'Surah Al-Mulk saves from grave punishment. Recite it every night 🌙',
      'likes': 87, 'comments': 6, 'liked': false,
      'nameAr': 'خديجة أحمد', 'nameEn': 'Khadijah Ahmed',
      'timeKey': 'comm_5hours',
    },
  ];

  List<Map<String, dynamic>> get _posts {
    if (_selectedCategory == 'all') return _postsData;
    return _postsData.where((p) => p['category'] == _selectedCategory).toList();
  }

  String _catLabel(String id) {
    switch (id) {
      case 'all': return LanguageManager.t('comm_cat_all');
      case 'general': return LanguageManager.t('comm_cat_general');
      case 'quran': return LanguageManager.t('comm_cat_quran');
      case 'questions': return LanguageManager.t('comm_cat_questions');
      case 'reflections': return LanguageManager.t('comm_cat_reflections');
      case 'support': return LanguageManager.t('comm_cat_support');
      default: return id;
    }
  }

  void _toggleLike(int id) {
    setState(() {
      final post = _postsData.firstWhere((p) => p['id'] == id);
      if (post['liked']) {
        post['likes']--;
        post['liked'] = false;
      } else {
        post['likes']++;
        post['liked'] = true;
      }
    });
  }

  void _showAddPostDialog() {
    final controller = TextEditingController();
    String category = 'general';
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF143B32),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5,
                      decoration: BoxDecoration(color: Colors.white24,
                          borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  Text(LanguageManager.t('comm_share_reflection'),
                      style: GoogleFonts.cairo(
                          color: const Color(0xFFD4AF37),
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: ['general', 'quran', 'questions', 'reflections', 'support'].map((c) {
                      final sel = c == category;
                      return GestureDetector(
                        onTap: () => setModalState(() => category = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel ? const Color(0xFFD4AF37) : const Color(0xFF0B2B26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_catLabel(c),
                              style: GoogleFonts.cairo(
                                  color: sel ? const Color(0xFF0B2B26) : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: LanguageManager.t('comm_write'),
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF0B2B26),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;
                        setState(() {
                          _postsData.insert(0, {
                            'id': DateTime.now().millisecondsSinceEpoch,
                            'avatar': 'أ',
                            'category': category,
                            'contentAr': controller.text.trim(),
                            'contentEn': controller.text.trim(),
                            'likes': 0, 'comments': 0, 'liked': false,
                            'nameAr': LanguageManager.t('comm_you'),
                            'nameEn': LanguageManager.t('comm_you'),
                            'timeKey': 'comm_now',
                          });
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(LanguageManager.t('comm_published'),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: Text(LanguageManager.t('comm_publish'),
                          style: GoogleFonts.cairo(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0B2B26),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddPostDialog,
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF0B2B26),
            icon: const Icon(Icons.edit),
            label: Text(LanguageManager.t('comm_share'),
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _catIds.length,
                  itemBuilder: (context, i) {
                    final id = _catIds[i];
                    final isSelected = id == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = id),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF143B32),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFFD4AF37).withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(_catLabel(id),
                              style: GoogleFonts.cairo(
                                color: isSelected ? const Color(0xFF0B2B26) : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  itemBuilder: (context, i) => _buildPostCard(_posts[i], isAr),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, bool isAr) {
    final content = isAr ? post['contentAr'] : post['contentEn'];
    final name = isAr ? post['nameAr'] : post['nameEn'];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFD4AF37),
                child: Text(post['avatar'],
                    style: const TextStyle(
                        color: Color(0xFF0B2B26),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Text(LanguageManager.t(post['timeKey']),
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_catLabel(post['category']),
                    style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(content,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(post['id']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post['liked']
                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                        : const Color(0xFF0B2B26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        post['liked'] ? Icons.favorite : Icons.favorite_border,
                        color: post['liked'] ? const Color(0xFFD4AF37) : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text('${post['likes']}',
                          style: TextStyle(
                            color: post['liked'] ? const Color(0xFFD4AF37) : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2B26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text('${post['comments']}',
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.white54, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
