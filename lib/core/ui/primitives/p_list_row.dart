import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

import 'p_interactive.dart';

/// PListRow — Sin cajas ni fondos:
/// Solo un borde superior de 1px (hairline en oscuro, ink14 en claro),
/// padding vertical 17, título rowTitle, meta meta, chevron a bone62.
/// Sustituye a cualquier Card, ListTile con fondo o ExpansionTile decorado.
class PListRow extends StatelessWidget {
  const PListRow({
    super.key,
    required this.title,
    this.meta,
    this.prefix,
    this.trailing,
    this.showChevron = true,
    this.showTopBorder = true,
    this.showBottomBorder = false,
    this.onTap,
    this.isLight,
    this.isDimmed = false,
  });

  final String title;
  final String? meta;
  final Widget? prefix;
  final Widget? trailing;
  final bool showChevron;
  final bool showTopBorder;
  final bool showBottomBorder;
  final VoidCallback? onTap;
  final bool? isLight;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final light = isLight ?? (Theme.of(context).brightness == Brightness.light);

    if (onTap == null) {
      return _buildContent(context, light: light, isHovered: false);
    }

    return PInteractive(
      onTap: onTap,
      pressedScale: 0.99,
      pressedOpacity: 0.80,
      builder: (context, isHovered, isPressed) =>
          _buildContent(context, light: light, isHovered: isHovered),
    );
  }

  Widget _buildContent(BuildContext context, {required bool light, required bool isHovered}) {
    final borderColor = light ? PColors.ink14 : PColors.hairline;
    final titleColor = isDimmed
        ? (light ? PColors.ink.withValues(alpha: 0.38) : PColors.bone.withValues(alpha: 0.38))
        : light
            ? (isHovered ? PColors.ink : PColors.ink.withValues(alpha: 0.85))
            : (isHovered ? PColors.bone : PColors.bone.withValues(alpha: 0.92));
    final metaColor = isDimmed
        ? (light ? PColors.ink40.withValues(alpha: 0.5) : PColors.bone45)
        : light
            ? PColors.ink40
            : (isHovered ? PColors.bone70 : PColors.bone55);
    final chevronColor = light ? PColors.ink40 : (isHovered ? PColors.bone : PColors.bone62);
    final hoverBg = light
        ? (isHovered ? PColors.ink06 : Colors.transparent)
        : (isHovered ? PColors.glassFill.withValues(alpha: 0.12) : Colors.transparent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(vertical: PSpace.rowPaddingY, horizontal: 4),
      decoration: BoxDecoration(
        color: hoverBg,
        border: Border(
          top: showTopBorder ? BorderSide(color: borderColor, width: 1.0) : BorderSide.none,
          bottom: showBottomBorder ? BorderSide(color: borderColor, width: 1.0) : BorderSide.none,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (prefix != null) ...[
            prefix!,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: PType.rowTitle.copyWith(color: titleColor),
                ),
                if (meta != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    meta!,
                    style: PType.meta.copyWith(color: metaColor),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron)
            AnimatedSlide(
              offset: isHovered ? const Offset(0.12, 0) : Offset.zero,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.chevron_right_rounded,
                color: chevronColor,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

