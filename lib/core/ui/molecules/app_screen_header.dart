import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_breakpoints.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final padding = AppBreakpoints.contentPadding(context);
    final buttonSize = AppBreakpoints.isDesktop(context) ? 44.0 : 40.0;
    final iconSize = AppBreakpoints.isDesktop(context) ? 22.0 : 20.0;
    final spacing = AppBreakpoints.isDesktop(context) ? 16.0 : 14.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, AppSpacing.md, padding, 0),
      child: Row(
        children: [
          if (showBack) ...[
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceSolid,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(Icons.arrow_back, size: iconSize),
              ),
            ),
            SizedBox(width: spacing),
          ],
          Expanded(
            child: Text(title, style: AppTypography.subheading),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
