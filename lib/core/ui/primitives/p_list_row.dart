import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

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

  @override
  Widget build(BuildContext context) {
    final light = isLight ?? (Theme.of(context).brightness == Brightness.light);
    final borderColor = light ? PColors.ink14 : PColors.hairline;
    final titleColor = light ? PColors.ink : PColors.bone;
    final metaColor = light ? PColors.ink40 : PColors.bone55;
    final chevronColor = light ? PColors.ink40 : PColors.bone62;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: PSpace.rowPaddingY),
      decoration: BoxDecoration(
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
            Icon(
              Icons.chevron_right_rounded,
              color: chevronColor,
              size: 20,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
