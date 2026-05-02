import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color background = Color(0xFFF8FAFC);
  static const Color textGrey = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryGreen,
    fontFamily: 'Inter', // Ensure you add this to pubspec
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: AppColors.primaryNavy, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: AppColors.primaryNavy),
    ),
  );
}