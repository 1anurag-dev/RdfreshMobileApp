import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

// Re-export all tokens for single import
export 'app_colors.dart';
export 'app_tokens.dart';
export 'app_typography.dart';

/// RDFresh — Complete Theme Configuration
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  //  LIGHT THEME
  // ─────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        primaryColor: AppColors.primaryGreen,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          onSecondary: Colors.white,
          tertiary: AppColors.accent,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          outline: AppColors.lightBorder,
          error: AppColors.error,
          onError: Colors.white,
        ),

        // ─── AppBar ───
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTypography.headlineSmall.copyWith(
            color: AppColors.lightText,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.lightText,
            size: 22,
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.lightTextTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),

        // ─── Cards ───
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 2,
          shadowColor: Color(0x14000000),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.baseBr,
            side: BorderSide(color: AppColors.lightBorder),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Elevated Button ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBr,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // ─── Outlined Button ───
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBr,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // ─── Text Button ───
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            textStyle: AppTypography.button,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),

        // ─── Input Decoration ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightInputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide:
                const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.lightTextTertiary,
          ),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.lightTextSecondary,
          ),
          errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSurfaceVariant,
          selectedColor: AppColors.accent.withOpacity(0.15),
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBr,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ─── Divider ───
        dividerTheme: const DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 1,
          space: 1,
        ),

        // ─── Progress Indicator ───
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGreen,
          linearTrackColor: AppColors.lightSurfaceVariant,
        ),

        // ─── Snackbar ───
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
          ),
        ),

        // ─── Dialog ───
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBr),
          elevation: 0,
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.lightText,
          ),
        ),

        // ─── Bottom Sheet ───
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.lightBorder,
        ),

        // ─── Tab Bar ───
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.lightTextTertiary,
          indicatorColor: AppColors.primaryGreen,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: AppTypography.titleSmall,
          unselectedLabelStyle: AppTypography.bodySmall,
        ),

        // ─── Floating Action Button ───
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // ─── Text Selection ───
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primaryGreen,
          selectionColor: Color(0x330A6847),
          selectionHandleColor: AppColors.primaryGreen,
        ),
      );

  // ─────────────────────────────────────────────
  //  DARK THEME
  // ─────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        primaryColor: AppColors.primaryGreen,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryGreenLight,
          onPrimary: AppColors.darkBg,
          secondary: AppColors.secondaryLight,
          onSecondary: AppColors.darkBg,
          tertiary: AppColors.accentLight,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          surfaceContainerHighest: AppColors.darkSurfaceVariant,
          outline: AppColors.darkBorder,
          error: Color(0xFFF87171),
          onError: AppColors.darkBg,
        ),

        // ─── AppBar ───
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTypography.headlineSmall.copyWith(
            color: AppColors.darkText,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.darkText,
            size: 22,
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primaryGreenLight,
          unselectedItemColor: AppColors.darkTextTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),

        // ─── Cards ───
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgBr,
            side: BorderSide(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          margin: EdgeInsets.zero,
        ),

        // ─── Elevated Button ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBr,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // ─── Outlined Button ───
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreenLight,
            side: const BorderSide(
                color: AppColors.primaryGreenLight, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdBr,
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // ─── Text Button ───
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryGreenLight,
            textStyle: AppTypography.button,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),

        // ─── Input Decoration ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkInputFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: const BorderSide(
                color: AppColors.primaryGreenLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: const BorderSide(color: Color(0xFFF87171)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdBr,
            borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.5),
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextTertiary,
          ),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          errorStyle:
              AppTypography.caption.copyWith(color: const Color(0xFFF87171)),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurfaceVariant,
          selectedColor: AppColors.primaryGreen.withOpacity(0.25),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.darkText,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.pillBr,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ─── Divider ───
        dividerTheme: const DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
          space: 1,
        ),

        // ─── Progress Indicator ───
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryGreenLight,
          linearTrackColor: AppColors.darkSurfaceVariant,
        ),

        // ─── Snackbar ───
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBr),
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkBg,
          ),
        ),

        // ─── Dialog ───
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBr),
          elevation: 0,
          titleTextStyle: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkText,
          ),
        ),

        // ─── Bottom Sheet ───
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.darkBorder,
        ),

        // ─── Tab Bar ───
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primaryGreenLight,
          unselectedLabelColor: AppColors.darkTextTertiary,
          indicatorColor: AppColors.primaryGreenLight,
          labelStyle: AppTypography.titleSmall,
          unselectedLabelStyle: AppTypography.bodySmall,
        ),

        // ─── Floating Action Button ───
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // ─── Text Selection ───
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primaryGreenLight,
          selectionColor: Color(0x334ADE80),
          selectionHandleColor: AppColors.primaryGreenLight,
        ),
      );
}

/// Extension for easy theme-aware color access
extension ThemeColors on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.darkText : AppColors.lightText;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textTertiary =>
      isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardColor =>
      isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get borderColor =>
      isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get inputFillColor =>
      isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
  Color get shimmerBase =>
      isDark ? AppColors.darkShimmerBase : AppColors.lightShimmerBase;
  Color get shimmerHighlight =>
      isDark ? AppColors.darkShimmerHighlight : AppColors.lightShimmerHighlight;
  Color get primaryColor =>
      isDark ? AppColors.primaryGreenLight : AppColors.primaryGreen;

  List<BoxShadow> get cardShadow =>
      isDark ? AppShadows.darkSm : AppShadows.sm;
  List<BoxShadow> get elevatedShadow =>
      isDark ? AppShadows.darkMd : AppShadows.md;
}
