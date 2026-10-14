import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

import 'p_interactive.dart';

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
    if (onTap == null) {
      return _buildCard(isHovered: false);
    }

    return PInteractive(
      onTap: onTap,
      pressedScale: 0.985,
      pressedOpacity: 0.90,
      hoverScale: 1.008,
      builder: (context, isHovered, isPressed) => _buildCard(isHovered: isHovered),
    );
  }

  Widget _buildCard({required bool isHovered}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: isHovered ? PColors.cream : PColors.cardFill,
        borderRadius: BorderRadius.circular(PRadius.card),
        boxShadow: isHovered
            ? [
                const BoxShadow(
                  color: Color(0x551E140A),
                  blurRadius: 46,
                  offset: Offset(0, 18),
                ),
              ]
            : PShadows.card,
      ),
      child: child,
    );
  }
}

