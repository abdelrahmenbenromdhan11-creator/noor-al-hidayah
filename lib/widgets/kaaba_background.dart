import 'package:flutter/material.dart';
import 'dart:math' as math;

class KaabaBackground extends StatefulWidget {
  final Widget child;
  final bool withLightRays;
  const KaabaBackground({
    super.key,
    required this.child,
    this.withLightRays = false,
  });

  @override
  State<KaabaBackground> createState() => _KaabaBackgroundState();
}

class _KaabaBackgroundState extends State<KaabaBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _lightController;

  @override
  void initState() {
    super.initState();
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ═══════ الصورة الأصلية للكعبة ═══════
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF08201C), Color(0xFF0B2B26)],
                ),
              ),
            ),
          ),
        ),

        // ═══════ تظليل أخضر داكن فوق الصورة ═══════
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0B2B26).withOpacity(0.75),
                  const Color(0xFF061815).withOpacity(0.85),
                  const Color(0xFF0B2B26).withOpacity(0.95),
                ],
              ),
            ),
          ),
        ),

        // ═══════ الأشعة الذهبية (اختياري) ═══════
        if (widget.withLightRays)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _lightController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LightRaysPainter(_lightController.value),
                );
              },
            ),
          ),

        // ═══════ المحتوى ═══════
        widget.child,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════
// الأشعة الذهبية الساطعة
// ═══════════════════════════════════════════════════════
class _LightRaysPainter extends CustomPainter {
  final double progress;
  _LightRaysPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 5 أشعة تخرج من الأفق العلوي
    final int rayCount = 5;
    for (int i = 0; i < rayCount; i++) {
      final baseX = (i + 1) * w / (rayCount + 1);
      final rayWidth = w * 0.08 + (i % 2) * w * 0.03;
      final rayTopY = h * 0.10 + (i % 3) * h * 0.03;
      final rayBottomY = h * 0.60 + (i % 2) * h * 0.05;

      final opacity = (0.15 + 0.10 * math.sin(progress * math.pi * 2 + i)) *
          (0.5 + 0.5 * progress);

      final rayPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE9A8).withOpacity(opacity.clamp(0, 1)),
            const Color(0xFFD4AF37).withOpacity((opacity * 0.5).clamp(0, 1)),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(
            baseX - rayWidth / 2, rayTopY, rayWidth, rayBottomY - rayTopY));

      final rayPath = Path();
      rayPath.moveTo(baseX - rayWidth * 0.3, rayTopY);
      rayPath.lineTo(baseX + rayWidth * 0.3, rayTopY);
      rayPath.lineTo(baseX + rayWidth, rayBottomY);
      rayPath.lineTo(baseX - rayWidth, rayBottomY);
      rayPath.close();

      canvas.drawPath(rayPath, rayPaint);
    }

    // هالة ذهبية متوهجة
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE9A8).withOpacity(0.20 * progress),
          const Color(0xFFD4AF37).withOpacity(0.08 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
          center: Offset(w * 0.5, h * 0.40), radius: w * 0.8));
    canvas.drawCircle(Offset(w * 0.5, h * 0.40), w * 0.8, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter oldDelegate) => true;
}
