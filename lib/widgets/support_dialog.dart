import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
          decoration: BoxDecoration(
            color: const Color(0xFF143B32),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 40,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══════ الرأس ═══════
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.support_agent, color: Color(0xFFD4AF37), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الدعم والتواصل',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFFD4AF37),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Support & Contact',
                              style: GoogleFonts.cormorantGaramond(
                                color: Colors.white54,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                              )),
                        ],
                      ),
                    ),
                    // زر X
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.close, color: Color(0xFFD4AF37), size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // خط فاصل
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFD4AF37).withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // ═══════ المحتوى ═══════
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    children: [
                      _linkTile(context, Icons.chat, const Color(0xFF25D366),
                          'WhatsApp', '+971 50 115 9417', 'https://wa.me/971501159417'),
                      _linkTile(context, Icons.chat, const Color(0xFF25D366),
                          'WhatsApp', '+971 55 217 3597', 'https://wa.me/971552173597'),
                      _linkTile(context, Icons.email, const Color(0xFFEA4335),
                          'Gmail', 'abdelrahmenbenromdhan11@gmail.com',
                          'mailto:abdelrahmenbenromdhan11@gmail.com?subject=Noor Al-Hidayah'),
                      _linkTile(context, Icons.email, const Color(0xFFEA4335),
                          'Gmail', 'nooralimanechannel@gmail.com',
                          'mailto:nooralimanechannel@gmail.com?subject=Noor Al-Hidayah'),
                      _linkTile(context, Icons.play_circle_fill, const Color(0xFFFF0000),
                          'YouTube', '@nooralhidayahoff',
                          'https://youtube.com/@nooralhidayahoff?si=YpXMLXowlgVaLN-j'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _linkTile(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String url,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _open(context, url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B2B26).withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: color.withOpacity(0.7), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════ فتح الديالوج مع ضبابية الخلفية ═══════
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Support',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Stack(
          children: [
            // ضبابية الخلفية
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),
            // مربع الدعم
            const SupportDialog(),
          ],
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }
}
