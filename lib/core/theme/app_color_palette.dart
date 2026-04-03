import 'package:flutter/material.dart';

class AppColorPalette {
  AppColorPalette._();

  // Brand
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFB71C1C);
  static const Color secondary = Color(0xFFFF7043);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD32F2F);

  // Surfaces and text
  static const Color background = Color(0xFFFFF5F5);
  static const Color surface = Color(0xFFFFEBEE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A0A0A);
  static const Color textSecondary = Color(0xFF6B7280);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color gray = Colors.grey;

  // Accents
  static const Color gold = Color(0xFFFFD700);
  static const Color info = Color(0xFF2196F3);
  static const Color infoAccent = Color(0xFF40C4FF);
  static const Color teal = Color(0xFF009688);
  static const Color violet = Color(0xFF673AB7);
  static const Color errorAccent = Colors.redAccent;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
