import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// PBoneCard — Tarjeta hueso sobre foto:
/// radio 30, padding 24, fondo cardFill (#FFFCF6 a .92), sombra PShadows.card.
class PBoneCard extends StatelessWidget {
  const PBoneCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: PColors.cardFill,
        borderRadius: BorderRadius.circular(PRadius.card),
        boxShadow: PShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
