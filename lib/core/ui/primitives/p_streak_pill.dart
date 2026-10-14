import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

import 'p_interactive.dart';

/// PStreakPill — Punto de 7px + número, radio 18, glassFill con borde glassStroke.
/// Sin iconos, sin fuego, sin confeti. La racha se nombra con sobriedad.
class PStreakPill extends StatelessWidget {
  const PStreakPill({
    super.key,
    required this.streak,
    this.onTap,
  });

  final int streak;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return _buildPill(isHovered: false);
    }

    return PInteractive(
      onTap: onTap,
      tooltip: 'Ver racha de crecimiento',
      builder: (context, isHovered, isPressed) => _buildPill(isHovered: isHovered),
    );
  }

  Widget _buildPill({required bool isHovered}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHovered ? PColors.glassFill.withValues(alpha: 0.22) : PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.pill),
        border: Border.all(
          color: isHovered ? PColors.bone50 : PColors.glassStroke,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: PColors.bone,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: PType.uiStrong.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

