import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// PREGARE Typography System
/// - Fraunces: Elegant editorial serif for titles, greetings, Scripture verses,
///   declarations, and quotes.
/// - Inter: Clean, modern sans-serif for UI elements, labels, buttons, and navigation.
class AppTypography {
  AppTypography._();

  // ─── Fraunces Editorial Serif (Scripture, Quotes, Declarations, Display) ───
  static TextStyle displaySerif = GoogleFonts.fraunces(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.15,
  );

  static TextStyle displaySerifLarge = GoogleFonts.fraunces(
    fontSize: 34,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.1,
  );

  static TextStyle headingSerif = GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static TextStyle verseText = GoogleFonts.fraunces(
    fontSize: 22,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    height: 1.45,
    letterSpacing: -0.2,
  );

  static TextStyle verseTextLarge = GoogleFonts.fraunces(
    fontSize: 26,
    fontWeight: FontWeight.w300,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static TextStyle declarationText = GoogleFonts.fraunces(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.2,
  );

  // ─── Inter Clean UI (Headings, Body, Labels, Eyebrows) ─────────────────────
  static TextStyle display = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle heading = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle subheading = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: -0.1,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle eyebrow = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle verseReference = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );
}
