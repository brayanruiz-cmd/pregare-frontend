import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.accentInk,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
        ),
        dividerColor: AppColors.divider,
        cardColor: AppColors.surface,

        // AppBar — transparent, blending seamlessly with background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
        ),

        // Input fields — subtle dark surface style
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
        ),

        // Elevated Button (Pill Bone/Ivory or Gold)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.boneCard,
            foregroundColor: AppColors.boneInk,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            textStyle: AppTypography.button.copyWith(color: AppColors.boneInk),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
            textStyle: AppTypography.button,
          ),
        ),

        // Slider Theme for text size & controls (warm golden track + bone thumb)
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accentWarm,
          inactiveTrackColor: AppColors.surfaceElevated,
          thumbColor: AppColors.boneCard,
          trackHeight: 3.0,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
          overlayColor: AppColors.accentGlow,
        ),

        // Switch Theme (warm golden active track)
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.boneCard;
            return AppColors.textTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accentWarm;
            }
            return AppColors.surfaceElevated;
          }),
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),

        // Progress indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
        ),
      );
}
