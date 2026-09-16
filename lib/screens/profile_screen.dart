import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import '../i18n/language_manager.dart';
import '../services/user_profile_service.dart';
import '../services/points_service.dart';
import '../services/store_service.dart';
import '../services/user_progress_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  String _name = '';
  String _bio = '';
  String? _avatarPath;
  int _points = 0;
  int _streak = 0;
  int _fastingDays = 0;
  int _quranProgress = 0;
  int _prayerProgress = 0;
  int _goalProgress = 0;
  bool _loading = true;

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
    final name = await UserProfileService.getName();
    final bio = await UserProfileService.getBio();
    final avatar = await UserProfileService.getAvatarPath();
    final points = await PointsService.getPoints();
    final streak = await UserProgressService.getStreak();
    final prayers = await UserProgressService.getTodayPrayersCount();
    final goals = await UserProgressService.getTodayGoalsCount();

    setState(() {
      _name = name;
      _bio = bio;
      _avatarPath = avatar;
      _points = points;
      _streak = streak;
      _prayerProgress = prayers;
      _goalProgress = goals;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await UserProfileService.setAvatarPath(picked.path);
      setState(() => _avatarPath = picked.path);
    }
  }

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _name);
    final bioCtrl = TextEditingController(text: _bio);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF143B32),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Directionality(
        textDirection:
            LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50, height: 5,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                Text('تعديل الملف الشخصي',
                    style: GoogleFonts.cairo(
                        color: const Color(0xFFD4AF37),
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    labelStyle: GoogleFonts.cairo(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person,
                        color: Color(0xFFD4AF37)),
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
                const SizedBox(height: 14),
                TextField(
                  controller: bioCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'نبذة عنك',
                    labelStyle: GoogleFonts.cairo(color: Colors.white70),
                    prefixIcon: const Icon(Icons.info_outline,
                        color: Color(0xFFD4AF37)),
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
                    onPressed: () async {
                      await UserProfileService.setName(nameCtrl.text.trim());
                      await UserProfileService.setBio(bioCtrl.text.trim());
                      setState(() {
                        _name = nameCtrl.text.trim();
                        _bio = bioCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.save),
                    label: Text('حفظ',
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
        return Directionality(
          textDirection:
              LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: const Color(0xFF143B32),
              title: Text(
                isAr ? 'ملفي الشخصي' : 'My Profile',
                style: GoogleFonts.cairo(color: const Color(0xFFD4AF37)),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'تعديل',
                  onPressed: _editProfile,
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAvatarSection(isAr),
                const SizedBox(height: 20),
                _buildStatsGrid(isAr),
                const SizedBox(height: 20),
                _buildProgressSection(isAr),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════ الصورة الشخصية ═══════════
  Widget _buildAvatarSection(bool isAr) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(24),
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color.lerp(
                  const Color(0xFFD4AF37), const Color(0xFFFFE9A8), glow)!,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.15 + 0.25 * glow),
                blurRadius: 20 + 10 * glow,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.lerp(const Color(0xFFD4AF37),
                                const Color(0xFFFFE9A8), glow)!,
                            const Color(0xFF8B6914),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFD4AF37).withOpacity(0.5 * glow),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Container(
                        width: 120, height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0B2B26),
                        ),
                        child: ClipOval(
                          child: _avatarPath != null
                              ? (kIsWeb
                                  ? Image.network(
                                      _avatarPath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _defaultAvatar(),
                                    )
                                  : Image.file(
                                      File(_avatarPath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _defaultAvatar(),
                                    ))
                              : _defaultAvatar(),
                        ),
                      ),
                    ),
                    // أيقونة الكاميرا
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37),
                        border: Border.all(
                            color: const Color(0xFF0B2B26), width: 2),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Color(0xFF0B2B26), size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _name.isEmpty ? (isAr ? 'مستخدم جديد' : 'New User') : _name,
                style: GoogleFonts.cairo(
                  color: const Color(0xFFD4AF37),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _bio,
                  style: GoogleFonts.cairo(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _defaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF1E4D40), Color(0xFF143B32)],
        ),
      ),
      child: const Icon(Icons.person, color: Color(0xFFD4AF37), size: 60),
    );
  }

  // ═══════════ إحصائيات سريعة ═══════════
  Widget _buildStatsGrid(bool isAr) {
    return Row(
      children: [
        Expanded(
            child: _statCard(Icons.star, '$_points',
                isAr ? 'النقاط' : 'Points', const Color(0xFFD4AF37))),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(Icons.local_fire_department, '$_streak',
                isAr ? 'Streak' : 'Streak', Colors.orange)),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = _glowController.value;
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: GoogleFonts.cairo(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
              Text(label,
                  style: GoogleFonts.cairo(
                      color: Colors.white54, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  // ═══════════ أقسام التقدم ═══════════
  Widget _buildProgressSection(bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'تقدمي في التطبيق' : 'My Progress',
          style: GoogleFonts.cairo(
            color: const Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        _progressRow(
          Icons.check_circle,
          isAr ? 'الصلوات اليوم' : 'Prayers Today',
          '$_prayerProgress / 5',
          _prayerProgress / 5,
          const Color(0xFFD4AF37),
        ),
        const SizedBox(height: 12),
        _progressRow(
          Icons.flag,
          isAr ? 'الأهداف اليومية' : 'Daily Goals',
          '$_goalProgress / 7',
          _goalProgress / 7,
          const Color(0xFF4ECDC4),
        ),
        const SizedBox(height: 12),
        _progressRow(
          Icons.menu_book,
          isAr ? 'خطة القرآن' : 'Quran Plan',
          '$_quranProgress',
          0.0,
          const Color(0xFF95E1D3),
        ),
        const SizedBox(height: 12),
        _progressRow(
          Icons.nightlight,
          isAr ? 'الصيام' : 'Fasting',
          '$_fastingDays',
          0.0,
          const Color(0xFFFFA500),
        ),
      ],
    );
  }

  Widget _progressRow(IconData icon, String label, String value,
      double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF143B32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: GoogleFonts.cairo(
                    color: Colors.white, fontSize: 14)),
          ),
          Text(value,
              style: GoogleFonts.cairo(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
