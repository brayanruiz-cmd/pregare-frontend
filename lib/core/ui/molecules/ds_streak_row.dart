import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_breakpoints.dart';

/// Premium streak row with animated fire glow and glassmorphism card.
class DSStreakRow extends StatefulWidget {
  const DSStreakRow({
    super.key,
    required this.days,
    this.message,
  });

  final int days;
  final String? message;

  @override
  State<DSStreakRow> createState() => _DSStreakRowState();
}

class _DSStreakRowState extends State<DSStreakRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fireAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final Animation<double> _fireScale = Tween<double>(begin: 0.9, end: 1.1)
      .animate(CurvedAnimation(parent: _fireAc, curve: Curves.easeInOut));

  @override
  void dispose() {
    _fireAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final padding = isDesktop ? 20.0 : 14.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGlass, width: 0.8),
          ),
          child: Row(
            children: [
              // Animated fire emoji
              AnimatedBuilder(
                animation: _fireScale,
                builder: (context, child) => Transform.scale(
                  scale: _fireScale.value,
                  child: child,
                ),
                child: Text(
                  '🔥',
                  style: TextStyle(fontSize: isDesktop ? 26 : 22),
                ),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.days > 0
                          ? '${widget.days} day${widget.days > 1 ? 's' : ''} in a row'
                          : 'Start your streak today',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isDesktop ? 14 : 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message ??
                          (widget.days > 0
                              ? 'Come back tomorrow to keep your streak'
                              : 'Open the app tomorrow to begin'),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),

              // Days badge
              if (widget.days > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${widget.days}d',
                    style: AppTypography.label.copyWith(
                      fontSize: 12,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
