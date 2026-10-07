import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'spacing.dart';
import 'text_styles.dart';

/// Single source of truth for the app's ThemeData.
/// Overrides Material's default TextTheme entirely so no fallback/system
/// font can ever appear — every text style here is explicitly Poppins.
///
/// The color scheme is spelled out (not seeded) so any Material control
/// that doesn't set its own colors lands on the Pitchvilla palette instead
/// of a tonal palette derived from the yellow.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.brand,
      onPrimary: AppColors.ink,
      secondary: AppColors.brand,
      onSecondary: AppColors.ink,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      error: AppColors.error,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: kFontFamily,
      splashFactory: InkRipple.splashFactory,
      splashColor: AppColors.offWhite,
      highlightColor: AppColors.offWhite,
      hoverColor: AppColors.offWhite,
      focusColor: AppColors.offWhite,
    );

    return base.copyWith(
      textTheme: _poppinsTextTheme(base.textTheme),
      primaryTextTheme: _poppinsTextTheme(base.primaryTextTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3,
      ),
      // The one sanctioned dark fill in the app: a transient toast. Its
      // action label (Retry / Undo) uses the brand yellow so it pops.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.white),
        actionTextColor: AppColors.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.ink,
        selectionColor: AppColors.brand.withValues(alpha: 0.4),
        selectionHandleColor: AppColors.brandPressed,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ink,
        linearTrackColor: AppColors.gray100,
        circularTrackColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.ink),
        contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.gray500),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          overlayColor: AppColors.offWhite,
          textStyle: AppTextStyles.bodyLg.copyWith(fontWeight: AppFontWeight.semibold),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadius.md)),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.white, fontSize: 13, height: 1.4),
        // Tap-triggered tooltips used to vanish after ~1.5s: too quick to read a
        // two-line explanation. Stay up long enough to read, and still dismiss
        // on a tap anywhere else.
        showDuration: const Duration(seconds: 8),
        exitDuration: const Duration(milliseconds: 300),
        // Breathing room inside the bubble and from the screen edges (the text
        // used to touch the edges of the dark bar and the screen).
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md - 4),
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.brand,
        inactiveTrackColor: AppColors.gray100,
        thumbColor: AppColors.brand,
        overlayColor: AppColors.gray100,
        valueIndicatorColor: AppColors.ink,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.ink,
        brightness: Brightness.light,
      ),
    );
  }

  static TextTheme _poppinsTextTheme(TextTheme base) {
    return base.apply(fontFamily: kFontFamily).copyWith(
          displayLarge: AppTextStyles.display,
          displayMedium: AppTextStyles.h1,
          displaySmall: AppTextStyles.h2,
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          titleLarge: AppTextStyles.h3,
          titleMedium: AppTextStyles.bodyLg,
          titleSmall: AppTextStyles.label,
          bodyLarge: AppTextStyles.bodyLg,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
          labelLarge: AppTextStyles.label,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.caption,
        );
  }
}
