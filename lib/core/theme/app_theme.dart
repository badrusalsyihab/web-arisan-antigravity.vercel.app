import 'package:flutter/material.dart';

class AppTheme {
  // Pure Bright Light Theme Palette
  static const Color primary = Color(0xFF193B43); // Deep Dark Teal Header & Button Accent
  static const Color primaryDark = Color(0xFF112C32);
  static const Color secondary = Color(0xFF9333EA); // Purple / Lavender Accent
  static const Color accent = Color(0xFF10B981); // Emerald / Mint
  static const Color limeAccent = Color(0xFFD3F36B); // Bright Accent Lime
  static const Color pastelPurple = Color(0xFFE8E0FB); // Pastel Lavender Card
  static const Color pastelCream = Color(0xFFFAF2E7); // Pastel Cream Card
  static const Color pastelLime = Color(0xFFF3FAD2); // Pastel Lime Card
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFD97706); // Amber 600
  
  static const Color bgLight = Color(0xFFF4F6F8); // Bright Soft Off-White Background
  static const Color cardBg = Colors.white;
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A); // Deep Slate Text
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      primaryColor: primary,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: cardBg,
        error: danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        surfaceTintColor: bgLight,
        scrolledUnderElevation: 4.0,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textMain),
        titleTextStyle: const TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
