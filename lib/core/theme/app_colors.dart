import 'package:flutter/material.dart';

/// RD Fresh premium B2B color tokens.
class AppColors {
  AppColors._();

  // ─── Brand ───
  static const Color primaryGreen = Color(0xFF0A6847);
  static const Color primaryGreenLight = Color(0xFF15865E);
  static const Color primaryGreenDark = Color(0xFF064E34);

  static const Color secondary = Color(0xFF1A2E1A);
  static const Color secondaryLight = Color(0xFF2D4A2D);
  static const Color secondaryDark = Color(0xFF0F1F0F);

  static const Color accent = Color(0xFF8BC34A);
  static const Color accentLight = Color(0xFFAED581);
  static const Color accentDark = Color(0xFF689F38);
  static const Color accentBg = Color(0xFFF0F7E6);

  // ─── Status Colors ───
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  static const Color successBg = Color(0xFFF0FDF4);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color infoBg = Color(0xFFEFF6FF);

  // ─── Order Status ───
  static const Color statusPending = Color(0xFF2563EB);
  static const Color statusProcessing = Color(0xFFD97706);
  static const Color statusShipped = Color(0xFF7C3AED);
  static const Color statusDelivered = success;

  // ─── Light Theme ───
  static const Color lightBg = Color(0xFFF5F7F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDF2E8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A2E1A);
  static const Color lightTextSecondary = Color(0xFF6B7B6B);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightInputFill = Color(0xFFF0F4EC);
  static const Color lightShimmerBase = Color(0xFFE5E7EB);
  static const Color lightShimmerHighlight = Color(0xFFF8FAFC);

  // ─── Dark Theme ───
  static const Color darkBg = Color(0xFF0B1A0F);
  static const Color darkSurface = Color(0xFF111F14);
  static const Color darkSurfaceVariant = Color(0xFF1F2D1F);
  static const Color darkCard = Color(0xFF172617);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  static const Color darkTextTertiary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2D4A2D);
  static const Color darkDivider = Color(0xFF243824);
  static const Color darkInputFill = Color(0xFF1F2D1F);
  static const Color darkShimmerBase = Color(0xFF1F2D1F);
  static const Color darkShimmerHighlight = Color(0xFF2D4A2D);

  // ─── Gradient Presets ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryGreenDark, Color(0xFF0B1A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [primaryGreenDark, primaryGreen, primaryGreenLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [primaryGreen, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get glassMorphGradient => LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ─── Legacy Aliases (backward compat) ───
  static const Color primaryNavy = secondary;
  static const Color textGrey = lightTextSecondary;
  static const Color border = lightBorder;
  static const Color background = lightBg;
}
