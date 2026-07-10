import 'package:flutter/material.dart';

/// Brand palette - warm cream, deep green, gold accents.
abstract final class AppColors {
  static const Color brandPrimary = Color(0xFF1B4332);
  static const Color brandAccent = Color(0xFFC9A227);
  static const Color primary = brandPrimary;
  static const Color primaryDark = Color(0xFF0F2A1F);
  static const Color accentGreen = Color(0xFF2D6A4F);
  static const Color accentMint = Color(0xFFE8F5F0);
  static const Color surfaceSoft = Color(0xFFF7F3EA);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color cardBorder = Color(0xFFE6DFD0);
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color warning = Color(0xFFF59E0B);
  static const Color bannerBg = Color(0xFFFFF3CD);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC9A227), Color(0xFFE0C35A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
