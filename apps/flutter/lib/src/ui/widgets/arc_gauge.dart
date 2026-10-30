import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/lv_theme.dart';
import 'liquid_card.dart';

class ArcGauge extends StatelessWidget {
  const ArcGauge({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    required this.unit,
    required this.accentColor,
  });

  final double value;
  final double maxValue;
  final String label;
  final String unit;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return LiquidCard(
      child: SizedBox(
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(170, 170),
              painter: _ArcPainter(
                progress: progress,
                accentColor: accentColor,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: LVTheme.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: LVTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.3,
                    color: LVTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.progress, required this.accentColor});

  final double progress;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    const start = 5 * pi / 6;
    const sweep = 4 * pi / 3;
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    stroke.color = LVTheme.gaugeArcBg;
    canvas.drawArc(rect, start, sweep, false, stroke);

    if (progress > 0) {
      stroke.shader = SweepGradient(
        startAngle: start,
        endAngle: start + max(sweep * progress, 0.001),
        colors: [accentColor.withOpacity(0.6), accentColor],
      ).createShader(rect);
      canvas.drawArc(rect, start, sweep * progress, false, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor;
  }
}
