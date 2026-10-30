import 'package:flutter/material.dart';

class LVTheme {
  static const backgroundPrimary = Color(0xFF0A0A0A);
  static const backgroundCard = Color(0x991A1A1E);
  static const backgroundElevated = Color(0xFF2C2C30);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0A8);
  static const neonGreen = Color(0xFF00FF88);
  static const neonCyan = Color(0xFF00DDFF);
  static const neonBlue = Color(0xFF00AAFF);
  static const neonOrange = Color(0xFFFF8800);
  static const neonRed = Color(0xFFFF2244);
  static const gaugeArcBg = Color(0xFF1E1E24);

  static const cardPadding = 16.0;
  static const cardRadius = 20.0;
  static const sectionSpacing = 16.0;
  static const minTouchTarget = 56.0;

  static Color heatColor(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped < 0.3) return neonCyan;
    if (clamped < 0.6) return neonGreen;
    if (clamped < 0.8) return neonOrange;
    return neonRed;
  }
}
