import 'package:url_launcher/url_launcher.dart';

class YoutubeVideo {
  final String id;
  final String titleAr;
  final String titleEn;
  final String duration;
  final bool isFeatured;
  const YoutubeVideo({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.duration,
    this.isFeatured = false,
  });
}

class YoutubeService {
  // ═══════════════════════════════════════════════════════
  // الفيديوهات الحقيقية من قناة Noor AlHidayah
  // ═══════════════════════════════════════════════════════
  static const List<YoutubeVideo> videos = [
    YoutubeVideo(
      id: 'AMplM1C4Iq8',
      titleAr: 'الفيديو الأخير - مميز ✨',
      titleEn: 'Latest Featured Video ✨',
      duration: '15:00',
      isFeatured: true,
    ),
    YoutubeVideo(
      id: '1D5H23gRp9Y',
      titleAr: 'صالح عليه السلام: ناقة الله وقصة قوم ثمود',
      titleEn: 'Prophet Salih | Thamud & the She-Camel',
      duration: '4:41',
    ),
    YoutubeVideo(
      id: 'SEdhm6BglZw',
      titleAr: 'هود عليه السلام: الريح التي محت أعظم حضارة',
      titleEn: 'Prophet Hud | The Wind that Erased a Civilization',
      duration: '4:41',
    ),
    YoutubeVideo(
      id: 'VUxB8kSz34o',
      titleAr: 'قصة إدريس ونوح عليهما السلام قبل الطوفان',
      titleEn: 'Prophets Enoch & Noah | Before the Flood',
      duration: '7:24',
    ),
    YoutubeVideo(
      id: 'mr5Q4n48gX0',
      titleAr: 'لماذا رفض إبليس السجود؟ قصة آدم كاملة',
      titleEn: 'Why Iblis Refused to Prostrate | Story of Adam',
      duration: '10:15',
    ),
  ];

  static const String channelHandle = 'nooralhidayahoff';
  static const String channelUrl = 'https://youtube.com/@nooralhidayahoff';
  static const String subscribeUrl =
      'https://youtube.com/@nooralhidayahoff?sub_confirmation=1';

  // ═══════════════ فتح قناة يوتيوب ═══════════════
  static Future<void> openChannel() async {
    try {
      await launchUrl(Uri.parse(channelUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // ═══════════════ اشتراك مباشر ═══════════════
  static Future<void> openSubscribe() async {
    try {
      await launchUrl(Uri.parse(subscribeUrl),
          mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  // ═══════════════ صورة الفيديو المصغرة ═══════════════
  static String getThumbnail(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
  }
}
