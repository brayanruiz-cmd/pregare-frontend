import 'package:flutter/material.dart';
import '../molecules/ds_quick_card.dart';
import '../../theme/app_breakpoints.dart';

class DSQuickGrid extends StatelessWidget {
  const DSQuickGrid({super.key, required this.items});

  final List<QuickGridItem> items;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final isTablet = AppBreakpoints.isTablet(context);

    final crossAxisCount = isDesktop ? 2 : (isTablet ? 3 : 2);
    final aspectRatio = isDesktop ? 1.45 : (isTablet ? 1.3 : 1.1);
    final spacing = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: aspectRatio,
      children: items
          .map((item) => DSQuickCard(
                icon: item.icon,
                title: item.title,
                subtitle: item.subtitle,
                onTap: item.onTap,
              ))
          .toList(),
    );
  }
}

class QuickGridItem {
  const QuickGridItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
