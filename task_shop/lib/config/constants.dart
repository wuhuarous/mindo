import 'package:flutter/material.dart';

/// Pet Tech App palette (UI/UX Pro Max)
/// Claymorphism + Bento Box + Tactile Digital design system
class AppColors {
  static const Color primary = Color(0xFFF97316);
  static const Color onPrimary = Color(0xFF0F172A);
  static const Color secondary = Color(0xFFFB923C);
  static const Color accent = Color(0xFF2563EB);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFF7ED);
  static const Color foreground = Color(0xFF9A3412);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF9A3412);
  static const Color muted = Color(0xFFF1F0F0);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color border = Color(0xFFFED7AA);
  static const Color destructive = Color(0xFFDC2626);

  // Claymorphism shadows
  static const Color clayShadowDark = Color(0x1AF97316);
  static const Color clayShadowLight = Color(0xFFFFF5F0);
  static const Color clayInnerShadow = Color(0x33FFFFFF);

  // Task type colors
  static const Color textTask = Color(0xFF6366F1);
  static const Color imageTask = Color(0xFFF97316);
  static const Color videoTask = Color(0xFFEC4899);

  // Status colors
  static const Color statusPending = Color(0xFF3B82F6);
  static const Color statusDoing = Color(0xFFF97316);
  static const Color statusCompleted = Color(0xFF22C55E);
  static const Color statusExpired = Color(0xFF9CA3AF);
}

class AppTokens {
  // Border radius (claymorphism style)
  static const double radiusXS = 8;
  static const double radiusSM = 12;
  static const double radiusMD = 16;
  static const double radiusLG = 20;
  static const double radiusXL = 24;
  static const double radius2XL = 32;

  // Shadows (claymorphism)
  static const BoxShadow shadowSM = BoxShadow(
    color: AppColors.clayShadowDark,
    blurRadius: 8,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowMD = BoxShadow(
    color: AppColors.clayShadowDark,
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  static const BoxShadow shadowLG = BoxShadow(
    color: AppColors.clayShadowDark,
    blurRadius: 24,
    offset: Offset(0, 12),
  );
  static const BoxShadow shadowInner = BoxShadow(
    color: AppColors.clayInnerShadow,
    blurRadius: 4,
    offset: Offset(4, 4),
  );
  static const BoxShadow shadowInnerDark = BoxShadow(
    color: AppColors.clayShadowDark,
    blurRadius: 8,
    offset: Offset(-4, -4),
  );

  // Animation durations (UX guideline: 150-300ms)
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  // Spring physics (Tactile Digital)
  static const SpringDescription springBounce = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 20,
  );

  // Spacing (Bento Box rhythm)
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 12;
  static const double spaceLG = 16;
  static const double spaceXL = 24;
  static const double space2XL = 32;

  // Tactile press scale
  static const double pressScale = 0.95;
}

class AppConstants {
  static const String baseUrl = 'http://localhost:3000/api';
}
