import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum DSBadgeVariant { gold, male, female, neutral }

class DSBadge extends StatelessWidget {
  const DSBadge({
    super.key,
    required this.label,
    this.variant = DSBadgeVariant.gold,
  });

  final String label;
  final DSBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      DSBadgeVariant.gold => (AppColors.gold.withValues(alpha: 0.15), AppColors.gold),
      DSBadgeVariant.male => (AppColors.maleBg, AppColors.male),
      DSBadgeVariant.female => (AppColors.femaleBg, AppColors.female),
      DSBadgeVariant.neutral => (AppColors.surfaceVariant, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.label.copyWith(color: fg, fontSize: 10),
      ),
    );
  }
}
