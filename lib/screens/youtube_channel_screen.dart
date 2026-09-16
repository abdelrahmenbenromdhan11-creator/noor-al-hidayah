import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/youtube_service.dart';
import '../i18n/language_manager.dart';

class YoutubeChannelScreen extends StatelessWidget {
  const YoutubeChannelScreen({super.key});

  Future<void> _openVideo(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) {
        final isAr = lang == 'ar';
        return Directionality(
          textDirection: LanguageManager.isRTL() ? TextDirection.rtl : TextDirection.ltr,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة القناة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E4D40), Color(0xFF0B2B26)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80, height: 80,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD4AF37), Color(0xFF8B6914), Color(0xFFD4AF37)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0B2B26),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                width: 74,
                                height: 74,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.play_arrow,
                                  color: Color(0xFFD4AF37),
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Noor AlHidayah',
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '@${YoutubeService.channelHandle}',
                                style: GoogleFonts.cormorantGaramond(
                                  color: const Color(0xFFD4AF37),
                                  fontSize: 13,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAr
                                    ? 'قصص إسلامية • أنبياء • عبر'
                                    : 'Islamic Stories • Prophets',
                                style: GoogleFonts.cairo(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: YoutubeService.openSubscribe,
                        icon: const Icon(Icons.notifications_active,
                            color: Color(0xFF0B2B26)),
                        label: Text(
                          isAr ? 'اشترك في القناة' : 'Subscribe',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF0B2B26),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 8,
                          shadowColor: const Color(0xFFD4AF37).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Icon(Icons.video_library, color: Color(0xFFD4AF37), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isAr ? 'أحدث الفيديوهات' : 'Latest Videos',
                    style: GoogleFonts.cairo(
                      color: const Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: YoutubeService.videos.length,
                itemBuilder: (context, i) {
                  final video = YoutubeService.videos[i];
                  return _buildVideoCard(context, video, isAr);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(BuildContext context, YoutubeVideo video, bool isAr) {
    return GestureDetector(
      onTap: () => _openVideo(video.id),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF143B32),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  Image.network(
                    YoutubeService.getThumbnail(video.id),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: const Color(0xFF0B2B26),
                      child: const Center(
                        child: Icon(Icons.play_circle,
                            color: Color(0xFFD4AF37), size: 40),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill,
                            color: Color(0xFFD4AF37), size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                isAr ? video.titleAr : video.titleEn,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
