import 'package:flutter/material.dart';

/// PREGARE Official Design System Colors
/// Hybrid North + Threshold: Nocturne dark base, warm radiant gold/amber glows,
/// contrasting bone/ivory cards for scripture, and clean paper mode for long reading.
class AppColors {
  AppColors._();

  // ─── Backgrounds (Nocturne Base) ──────────────────────────────────────────
  static const Color background = Color(0xFF0E0E12);
  static const Color backgroundAlt = Color(0xFF131217);
  static const Color backgroundCard = Color(0xFF17161C);

  // ─── Glowing Ambient Lights / Amber Glows ─────────────────────────────────
  static const Color glowAmbientTop = Color(0xFF1A1820);
  static const Color glowAmberPrimary = Color(0xFFC68B45);
  static const Color glowAmberDeep = Color(0xFF824E22);
  static const Color glowAmberBright = Color(0xFFE5A855);
  static const Color glowAmberSoft = Color(0x33C68B45);
  static const Color glowAmberFaint = Color(0x14C68B45);

  // ─── Surfaces (Dark Mode Cards) ───────────────────────────────────────────
  static const Color surface = Color(0xFF19171E);
  static const Color surfaceElevated = Color(0xFF221F28);
  static const Color surfaceBorder = Color(0x1AFFFFFF); // 10% white
  static const Color surfaceBorderSubtle = Color(0x0DFFFFFF); // 5% white
  static const Color surfaceGlass = Color(0x1AFFFFFF); // 10% white
  static const Color surfaceGlassMid = Color(0x26FFFFFF); // 15% white

  // ─── Bone & Paper Ivory (Threshold Light Moments & Front Flip Cards) ──────
  static const Color boneCard = Color(0xFFF6EFE3);
  static const Color boneCardGradientEnd = Color(0xFFEDE5D6);
  static const Color boneInk = Color(0xFF1F1D19);
  static const Color boneInkSecondary = Color(0xFF6B665A);

  // ─── Paper Mode (Bible Reader / Devotional Detail) ────────────────────────
  static const Color paperBackground = Color(0xFFFAF7F2);
  static const Color paperSurface = Color(0xFFF2ECE1);
  static const Color paperInk = Color(0xFF1F1D19);
  static const Color paperInkSecondary = Color(0xFF6B665A);
  static const Color paperBorder = Color(0xFFE5DDD0);
  static const Color paperHighlight = Color(0xFFF7EBD2);

  // ─── Gold Accents & Highlights ────────────────────────────────────────────
  static const Color accent = Color(0xFFE4C87A);
  static const Color accentBright = Color(0xFFF2DC98);
  static const Color accentWarm = Color(0xFFD49A58);
  static const Color accentGlow = Color(0x59E4C87A);
  static const Color accentInk = Color(0xFF161418);
  static const Color streakPill = Color(0xFF26232B);

  // ─── Text Colors (Dark Mode) ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA5A0A9);
  static const Color textTertiary = Color(0xFF716C76);
  static const Color textMuted = Color(0xFF55515B);

  // ─── Semantic & Utility ───────────────────────────────────────────────────
  static const Color border = Color(0x1AFFFFFF);
  static const Color borderSoft = Color(0x0FFFFFFF);
  static const Color divider = Color(0x14FFFFFF);
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);

  // ─── Legacy compatibility aliases ────────────────────────────────────────
  static const Color gold = accent;
  static const Color goldLight = accentBright;
  static const Color goldDark = accentWarm;
  static const Color accentSoft = Color(0x26E4C87A);
  static const Color male = Color(0xFF38BDF8);
  static const Color female = Color(0xFFF472B6);
  static const Color maleBg = Color(0xFF0F172A);
  static const Color femaleBg = Color(0xFF831843);
  static const Color surfaceSolid = surface;
  static const Color surfaceSolid2 = surfaceElevated;
  static const Color surfaceVariant = surfaceElevated;
  static const Color borderGlass = surfaceBorder;
  static const Color activePill = Color(0xFF2E2B35);
  static const Color indicatorRed = accent;
}
