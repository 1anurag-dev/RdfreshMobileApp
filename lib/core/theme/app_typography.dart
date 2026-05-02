import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// RD Fresh premium typography scale.
class AppTypography {
  AppTypography._();

  // ─── Hero Style ───
  static TextStyle get displayHero => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.8,
        color: AppColors.lightText,
      );

  // ─── Heading Styles ───
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
    fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
    color: AppColors.lightText,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.lightText,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.lightText,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
    fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
    letterSpacing: -0.5,
    color: AppColors.lightText,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
    fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.35,
    letterSpacing: -0.3,
    color: AppColors.lightText,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
    fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
    letterSpacing: -0.2,
    color: AppColors.lightText,
      );

  // ─── Body Styles ───
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.lightText,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.lightText,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.lightText,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.lightText,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.lightTextSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.lightTextSecondary,
      );

  // ─── Utility Styles ───
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.lightText,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.3,
        color: AppColors.lightTextSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
        color: AppColors.lightTextSecondary,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.4,
        letterSpacing: 1.2,
          color: AppColors.lightTextSecondary,
      );

        static TextStyle get button => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.2,
          letterSpacing: 0.5,
      );

        static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
          letterSpacing: 0.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
          fontSize: 14,
        fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.lightTextSecondary,
      );

        static TextStyle get small => GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.lightTextSecondary,
        );

  // ─── Number / Price Style ───
        static TextStyle get price => GoogleFonts.inter(
        fontSize: 24,
          fontWeight: FontWeight.w700,
        height: 1.2,
          letterSpacing: -0.3,
          color: AppColors.primaryGreen,
      );

        static TextStyle get priceSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.2,
          color: AppColors.primaryGreen,
      );

        static TextStyle get stat => GoogleFonts.inter(
        fontSize: 48,
          fontWeight: FontWeight.w700,
        height: 1.0,
          letterSpacing: -1,
      );
}
