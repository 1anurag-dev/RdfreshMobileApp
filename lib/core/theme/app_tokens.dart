/// RDFresh Design System — Spacing, Radius, Shadows, Durations
import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─── Spacing Scale (4px base) ───
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // Page padding
  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets pagePaddingH = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(24);
  static const EdgeInsets inputPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);
}

// ─── Border Radius Scale ───
class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 14;
  static const double base = 20;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 100;

  static BorderRadius get xsBr => BorderRadius.circular(xs);
  static BorderRadius get smBr => BorderRadius.circular(sm);
  static BorderRadius get mdBr => BorderRadius.circular(md);
  static BorderRadius get baseBr => BorderRadius.circular(base);
  static BorderRadius get lgBr => BorderRadius.circular(lg);
  static BorderRadius get xlBr => BorderRadius.circular(xl);
  static BorderRadius get xxlBr => BorderRadius.circular(xxl);
  static BorderRadius get pillBr => BorderRadius.circular(pill);
}

// ─── Shadows ───
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get soft => [
        const BoxShadow(
          color: Color(0x08000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.09),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 30,
          offset: const Offset(0, 12),
        ),
      ];

  static List<BoxShadow> get glow => [
        BoxShadow(
          color: AppColors.primaryGreen.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  // Dark mode shadows
  static List<BoxShadow> get darkSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get darkMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

// ─── Durations ───
class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration stagger = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1500);
}
