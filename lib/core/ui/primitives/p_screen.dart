import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/tokens.dart';

enum PScreenBackgroundType { photo, ink, bone }

class PScreenBackground {
  final PScreenBackgroundType type;
  final String? imageAsset;
  final Gradient? scrim;

  const PScreenBackground.ink()
      : type = PScreenBackgroundType.ink,
        imageAsset = null,
        scrim = null;

  const PScreenBackground.bone()
      : type = PScreenBackgroundType.bone,
        imageAsset = null,
        scrim = null;

  const PScreenBackground.photo(
    String this.imageAsset, {
    this.scrim = PScrims.home,
  }) : type = PScreenBackgroundType.photo;
}

/// PScreen — El andamio de pantalla oficial del sistema PREGARE.
///
/// Gestiona:
/// 1. El tratamiento de fondo con significado: Foto+Scrim, Tinta plana (#141310), Hueso (#F4F2EC).
/// 2. El `SystemUiOverlayStyle` adecuado según el fondo (claro sobre foto y tinta, oscuro sobre hueso).
/// 3. El gutter lateral estricto (26px en tinta/foto, 24px en hueso).
/// 4. El clearance inferior (112px) cuando la pantalla lleva PBottomNav flotante.
class PScreen extends StatelessWidget {
  const PScreen({
    super.key,
    required this.body,
    this.background = const PScreenBackground.ink(),
    this.header,
    this.hasNav = false,
    this.extendBodyBehindAppBar = true,
    this.padding,
    this.floatingWidget,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  final Widget body;
  final PScreenBackground background;
  final Widget? header;
  final bool hasNav;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingWidget;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    final isBone = background.type == PScreenBackgroundType.bone;
    final isPhoto = background.type == PScreenBackgroundType.photo;

    // Overlay style para la barra de estado
    final overlayStyle = isBone
        ? const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: PColors.bone,
            systemNavigationBarIconBrightness: Brightness.dark,
          )
        : const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: PColors.ink,
            systemNavigationBarIconBrightness: Brightness.light,
          );

    final gutter = isBone ? PSpace.gutterLight : PSpace.gutter;
    final effectivePadding = padding ??
        EdgeInsets.only(
          left: gutter,
          right: gutter,
          bottom: hasNav ? PSpace.navClearance : 0,
        );

    final scaffoldBg = switch (background.type) {
      PScreenBackgroundType.photo => PColors.inkDeep,
      PScreenBackgroundType.ink => PColors.ink,
      PScreenBackgroundType.bone => PColors.bone,
    };

    Widget content = Padding(
      padding: effectivePadding,
      child: body,
    );

    if (header != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header!,
          Expanded(child: content),
        ],
      );
    }

    Widget mainScaffold = Scaffold(
      backgroundColor: scaffoldBg,
      extendBody: hasNav,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Tratamiento de Fondo
            if (isPhoto && background.imageAsset != null) ...[
              Positioned.fill(
                child: Image.asset(
                  background.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const ColoredBox(color: PColors.inkDeep),
                ),
              ),
              if (background.scrim != null)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: background.scrim,
                    ),
                  ),
                ),
            ],

            // Contenido con SafeArea
            SafeArea(
              top: safeAreaTop,
              bottom: safeAreaBottom && !hasNav,
              child: content,
            ),

            // Elemento flotante (PBottomNav, etc.)
            ?floatingWidget,
          ],
        ),
      ),
    );

    // Si es pantalla BONE, aplicamos el tema light para que los textos hereden ink por defecto
    if (isBone) {
      return Theme(
        data: PTheme.light,
        child: mainScaffold,
      );
    }

    return Theme(
      data: PTheme.dark,
      child: mainScaffold,
    );
  }
}
