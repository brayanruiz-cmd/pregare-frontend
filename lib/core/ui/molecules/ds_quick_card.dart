import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_breakpoints.dart';

/// Premium glassmorphism quick action card with hover scale effect.
class DSQuickCard extends StatefulWidget {
  const DSQuickCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  State<DSQuickCard> createState() => _DSQuickCardState();
}

class _DSQuickCardState extends State<DSQuickCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    lowerBound: 0.94,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppBreakpoints.cardPadding(
      context,
      mobile: 14,
      tablet: 16,
      desktop: 18,
    );
    final iconSize = AppBreakpoints.iconSize(
      context,
      mobile: 22,
      tablet: 26,
      desktop: 28,
    );
    final isDesktop = AppBreakpoints.isDesktop(context);
    final color = widget.accentColor ?? AppColors.accent;

    return GestureDetector(
      onTapDown: (_) => _ac.reverse(),
      onTapUp: (_) {
        _ac.forward();
        widget.onTap();
      },
      onTapCancel: () => _ac.forward(),
      child: AnimatedBuilder(
        animation: _ac,
        builder: (context, child) => Transform.scale(
          scale: _ac.value,
          child: child,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.borderGlass,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow container
                  Container(
                    width: iconSize + 16,
                    height: iconSize + 16,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 14 : 13.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: AppTypography.caption.copyWith(
                      fontSize: isDesktop ? 11.5 : 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
