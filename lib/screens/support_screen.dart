import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n/language_manager.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open: $url'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLanguage,
      builder: (context, lang, _) => Scaffold(
        backgroundColor: const Color(0xFF0B2B26),
        appBar: AppBar(
          backgroundColor: const Color(0xFF143B32),
          title: Text(LanguageManager.t('support_title'),
              style: const TextStyle(color: Color(0xFFD4AF37))),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة ترحيبية
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
                  const Icon(Icons.support_agent, color: Color(0xFFD4AF37), size: 48),
                  const SizedBox(height: 12),
                  Text(LanguageManager.t('support_welcome'),
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(LanguageManager.t('support_desc'),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(LanguageManager.t('contact_us'),
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // WhatsApp 1
            _linkCard(
              context: context,
              icon: Icons.chat,
              iconColor: const Color(0xFF25D366),
              title: 'WhatsApp',
              subtitle: '+971 50 115 9417',
              url: 'https://wa.me/971501159417',
            ),
            // WhatsApp 2
            _linkCard(
              context: context,
              icon: Icons.chat,
              iconColor: const Color(0xFF25D366),
              title: 'WhatsApp',
              subtitle: '+971 55 217 3597',
              url: 'https://wa.me/971552173597',
            ),
            // Gmail 1
            _linkCard(
              context: context,
              icon: Icons.email,
              iconColor: const Color(0xFFEA4335),
              title: 'Gmail',
              subtitle: 'abdelrahmenbenromdhan11@gmail.com',
              url: 'mailto:abdelrahmenbenromdhan11@gmail.com?subject=Noor Al-Hidayah Support',
            ),
            // Gmail 2
            _linkCard(
              context: context,
              icon: Icons.email,
              iconColor: const Color(0xFFEA4335),
              title: 'Gmail',
              subtitle: 'nooralimanechannel@gmail.com',
              url: 'mailto:nooralimanechannel@gmail.com?subject=Noor Al-Hidayah Support',
            ),
            // YouTube
            _linkCard(
              context: context,
              icon: Icons.play_circle_fill,
              iconColor: const Color(0xFFFF0000),
              title: 'YouTube',
              subtitle: '@nooralhidayahoff',
              url: 'https://youtube.com/@nooralhidayahoff?si=YpXMLXowlgVaLN-j',
            ),

            const SizedBox(height: 30),

            // زر تقييم التطبيق
            ElevatedButton.icon(
              onPressed: () => _open(context, 'https://play.google.com/store/apps'),
              icon: const Icon(Icons.star),
              label: Text(LanguageManager.t('rate_app'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF0B2B26),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context, url),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: iconColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 45, height: 45,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Color(0xFFD4AF37), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
