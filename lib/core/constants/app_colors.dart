import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color primaryLight = Color(0xFF66E5FF);

  // Accent
  static const Color accent = Color(0xFF00FF87);
  static const Color accentDark = Color(0xFF00CC6A);

  // Backgrounds
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1A1F38);
  static const Color surfaceLight = Color(0xFF252A45);
  static const Color card = Color(0xFF1E2340);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textHint = Color(0xFF6C7293);

  // Status
  static const Color success = Color(0xFF00FF87);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD740);
  static const Color info = Color(0xFF448AFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00FF87), Color(0xFF00CC6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0E21), Color(0xFF1A1F38)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2340), Color(0xFF252A45)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass effect color
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
}
