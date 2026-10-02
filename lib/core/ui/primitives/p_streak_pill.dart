import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

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
    final pillWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: PColors.glassFill,
        borderRadius: BorderRadius.circular(PRadius.pill),
        border: Border.all(color: PColors.glassStroke, width: 1.0),
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

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: pillWidget,
      );
    }

    return pillWidget;
  }
}
