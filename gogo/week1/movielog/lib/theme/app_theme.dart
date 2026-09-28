import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      surface: AppColors.surface,
    ),

    scaffoldBackgroundColor: AppColors.surface,

    fontFamily: 'Manrope',

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}