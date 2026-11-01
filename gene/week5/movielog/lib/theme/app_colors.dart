import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const primary = Color(0xFF6750A4);
  static const primaryDark = Color(0xFF4F378A);
  static const primaryDark90 = Color(0xE64F378A); // primaryDark 90% 투명도
  static const primaryContainer = Color(0xFFE8DEF9);
  static const primaryDisabled = Color(0xFFCCC2DC);

  // Background / Surface
  static const background = Color(0xFFFAF9F5);
  static const white = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFE6E0E9);
  static const surfaceContainer = Color(0xFFECE6EE);
  static const surfaceNeutral = Color(0xFFE3E2DF);
  static const divider = Color(0xFFCBC4D2);
  static const overlayDark = Color(0xCC322F35); // 포스터 위 별점 배지

  // Text
  static const textPrimary = Color(0xFF1D1B20);
  static const textHeading = Color(0xFF1B1C1A);
  static const textSecondary = Color(0xFF494551);
  static const textTertiary = Color(0xFF79747E);
  static const textOnImage = Color(0xFFF8F2FA);
  static const textOnDark = Color(0xFFF5EFF7);
  static const hint = Color(0xFF7A7582);

  // Input
  static const fieldFill = Color(0xFFF5F3F0);
  static const fieldBorder = Color(0xFFCBC4D2);

  // Error
  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFFFDAD6);

  // Shadow
  static const shadow = Color(0x1A000000);
  static const shadowSubtle = Color(0x0D000000);
}
