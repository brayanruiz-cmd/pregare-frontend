// PREGARE — tokens del design doc v2 traducidos a Flutter.
// Valores literales del documento. No añadir nada aquí sin aprobación del diseño.
//
// Dependencias: google_fonts
//   hanken_grotesk pesos 300/400/500/600 · newsreader pesos 200/300/400 + italic 300

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// La paleta completa: 4 valores base + alfas de ellos. Nada más.
abstract final class PColors {
  static const ink = Color(0xFF141310); // tinta: fondo de utilidad, texto sobre hueso
  static const bone = Color(0xFFF4F2EC); // hueso: texto sobre tinta, fondo de lectura
  static const inkDeep = Color(0xFF0E0E0C); // base bajo las fotos
  static const stone = Color(0xFF8B897E); // metadatos
  static const cream = Color(0xFFFFFCF6); // tarjeta hueso sobre foto (se usa a .92)
  static const clay = Color(0xFF8A6A4E); // único acento cálido, solo en eyebrow de tarjeta

  // Hueso sobre fondo oscuro — la escala real de jerarquía de texto
  static const bone85 = Color(0xD9F4F2EC); // status bar
  static const bone70 = Color(0xB3F4F2EC); // subtítulo fuerte
  static const bone62 = Color(0x9EF4F2EC); // referencia de versículo
  static const bone55 = Color(0x8CF4F2EC); // meta de fila
  static const bone50 = Color(0x80F4F2EC); // eyebrow
  static const bone45 = Color(0x73F4F2EC); // nav inactiva

  // Tinta sobre hueso (pantallas de lectura)
  static const ink40 = Color(0x66141310);
  static const ink14 = Color(0x24141310); // borde
  static const ink10 = Color(0x1A141310);
  static const ink06 = Color(0x0F141310); // superficie sutil

  // Superficies translúcidas sobre foto
  static const glassFill = Color(0x1FFFFFFF);
  static const glassStroke = Color(0x24FFFFFF);
  static const hairline = Color(0x29FFFFFF); // separador de filas en oscuro
  static const navFill = Color(0x80261618);

  static const cardFill = Color(0xEBFFFCF6); // cream a .92
}

/// Los scrims existen para que el texto sea legible sobre foto.
/// Son los ÚNICOS gradientes permitidos en toda la app.
abstract final class PScrims {
  static const home = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.42, 0.72],
    colors: [Color(0x9E0E0E0C), Color(0xDB0E0E0C), Color(0xF70E0E0C)],
  );

  static const hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.50, 1.0],
    colors: [Color(0x990E0E0C), Color(0x4D0E0E0C), Color(0xBF0E0E0C)],
  );
}

abstract final class PRadius {
  static const nav = 35.0;
  static const card = 30.0; // tarjeta hueso de Home
  static const flip = 32.0; // caras de la tarjeta de declaración
  static const panel = 24.0;
  static const tile = 20.0;
  static const pill = 18.0;
  static const chip = 16.0;
}

abstract final class PSpace {
  static const gutter = 26.0; // padding lateral en pantallas oscuras
  static const gutterLight = 24.0; // en pantallas de lectura
  static const navHeight = 70.0;
  static const navInsetX = 20.0;
  static const navInsetBottom = 24.0;
  static const navClearance = 112.0; // padding inferior del contenido
  static const rowPaddingY = 17.0; // filas de lista
}

abstract final class PShadows {
  static const card = [
    BoxShadow(color: Color(0x401E140A), blurRadius: 40, offset: Offset(0, 14)),
  ];
  static const flip = [
    BoxShadow(color: Color(0x47000000), blurRadius: 50, offset: Offset(0, 20)),
  ];
  static const nav = [
    BoxShadow(color: Color(0x47000000), blurRadius: 36, offset: Offset(0, 12)),
  ];
}

abstract final class PMotion {
  static const flipDuration = Duration(milliseconds: 950);
  static const flipCurve = Cubic(0.22, 0.82, 0.20, 1.00);
  /// CSS blur(24px) ≈ sigma 12 en Flutter. No es 24.
  static const navBlurSigma = 12.0;
}

/// OJO: en CSS el tracking va en em; en Flutter es en px absolutos.
/// Estos valores ya están convertidos. No copiar los .16em del diseño tal cual.
///
/// Spec Hanken Grotesk:
///   Wordmark  — Medium (500), MAYÚSCULAS, tracking +5% → 0.65px a 13px
///   Titulares — Medium (500)
///   Cuerpo/UI — Regular (400)
///   Newsreader se usa solo para textos de Escritura y declaraciones (pesos 200/300).
abstract final class PType {
  // ── Newsreader ── Escritura y lectura devocional ─────────────────────────
  static TextStyle get greeting => GoogleFonts.newsreader(
      fontSize: 32, fontWeight: FontWeight.w200, height: 1.12, color: PColors.bone);

  static TextStyle get display => GoogleFonts.newsreader(
      fontSize: 36, fontWeight: FontWeight.w200, height: 1.0, color: PColors.bone);

  static TextStyle get scripture => GoogleFonts.newsreader(
      fontSize: 24, fontWeight: FontWeight.w300, height: 1.36, color: PColors.bone);

  /// Títulos serif dentro de tarjetas (cardTitle usa Newsreader 300).
  static TextStyle get cardTitle => GoogleFonts.newsreader(
      fontSize: 23, fontWeight: FontWeight.w300, height: 1.15, color: PColors.ink);

  /// Contador de progreso — Newsreader 400 + tracking.
  static TextStyle get counter => GoogleFonts.newsreader(
      fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 1.2, color: PColors.clay);

  // ── Hanken Grotesk ── UI, nav, eyebrow, etiquetas ───────────────────────

  /// Nombre de fila, capítulo, libro. Medium (500).
  static TextStyle get rowTitle => GoogleFonts.hankenGrotesk(
      fontSize: 15, fontWeight: FontWeight.w500, height: 1.0, color: PColors.bone);

  /// Cuerpo editorial. Regular (400).
  static TextStyle get body => GoogleFonts.hankenGrotesk(
      fontSize: 14, fontWeight: FontWeight.w400, height: 1.65, color: PColors.bone70);

  /// Botones y etiquetas de acción. Medium (500).
  static TextStyle get uiStrong => GoogleFonts.hankenGrotesk(
      fontSize: 14, fontWeight: FontWeight.w500, height: 1.0, color: PColors.bone);

  /// Metadatos y stamps secundarios. Regular (400).
  static TextStyle get meta => GoogleFonts.hankenGrotesk(
      fontSize: 12, fontWeight: FontWeight.w400, height: 1.0, color: PColors.bone55);

  /// Wordmark tipográfico "PREGARE". Medium (500), tracking +5% (≈ 0.65px a 13px).
  static TextStyle get wordmark => GoogleFonts.hankenGrotesk(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.65, // +5% de 13px
      color: PColors.bone);

  /// Firma del sistema. Siempre en mayúsculas. Medium (500), tracking amplio.
  /// 9px → .24em = 2.16px de letterSpacing.
  static TextStyle get eyebrow => GoogleFonts.hankenGrotesk(
      fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 2.16, color: PColors.bone50);

  /// Variante de eyebrow a 10px. Medium (500), .16em = 1.6px.
  static TextStyle get eyebrowSmall => GoogleFonts.hankenGrotesk(
      fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.6, color: PColors.bone50);

  /// Etiquetas de navegación. Medium (500), 9px, tracking .08em = 0.72px.
  static TextStyle get navLabel => GoogleFonts.hankenGrotesk(
      fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.72, color: PColors.bone45);
}

abstract final class PTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: PColors.ink,
        colorScheme: const ColorScheme.dark(
          surface: PColors.ink,
          onSurface: PColors.bone,
          primary: PColors.bone,
          onPrimary: PColors.ink,
        ),
        // El diseño no tiene ripples. Material los pone por defecto.
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        dividerColor: PColors.hairline,
        textTheme: GoogleFonts.hankenGroteskTextTheme().apply(
          bodyColor: PColors.bone,
          displayColor: PColors.bone,
        ),
        snackBarTheme: SnackBarThemeData(
          // Charcoal con tinte cálido — visible sobre fondo ink y bone
          backgroundColor: const Color(0xFF2A2722),
          contentTextStyle: GoogleFonts.hankenGrotesk(
            color: PColors.bone,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          actionTextColor: PColors.bone70,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PRadius.chip),
            side: const BorderSide(color: Color(0x33F4F2EC), width: 0.8),
          ),
          elevation: 8,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );

  /// Para el lector, selección de libro/capítulo y detalles de tema y devocional.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: PColors.bone,
        colorScheme: const ColorScheme.light(
          surface: PColors.bone,
          onSurface: PColors.ink,
          primary: PColors.ink,
          onPrimary: PColors.bone,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        dividerColor: PColors.ink14,
        textTheme: GoogleFonts.hankenGroteskTextTheme().apply(
          bodyColor: PColors.ink,
          displayColor: PColors.ink,
        ),
      );
}
