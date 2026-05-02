/// RDFresh Theme — Re-exports new design system while keeping backward compat
/// All old imports of this file continue to work.
export 'app_theme_new.dart';
export 'app_colors.dart';
export 'app_tokens.dart';
export 'app_typography.dart';

// Legacy aliases for backward compatibility (old screens that reference AppColors.primaryNavy etc.)
import 'package:flutter/material.dart';
import 'app_colors.dart' as nc;
import 'app_theme_new.dart';

/// @deprecated Use AppColors from app_colors.dart directly
/// This keeps old code working during migration.
/// Note: primaryNavy now maps to dark forest green (#1A2E1A), not navy.
class LegacyColors {
  static const Color primaryGreen = nc.AppColors.primaryGreen;
  static const Color primaryNavy = nc.AppColors.secondary;
  static const Color background = nc.AppColors.lightBg;
  static const Color textGrey = nc.AppColors.lightTextSecondary;
  static const Color border = nc.AppColors.lightBorder;
}