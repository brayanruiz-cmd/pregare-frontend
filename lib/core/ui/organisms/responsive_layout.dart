import 'package:flutter/material.dart';
import '../../theme/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.centerContent = false,
    this.maxContentWidth = AppBreakpoints.desktopMaxContent,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final bool centerContent;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content;

        if (constraints.maxWidth >= AppBreakpoints.tablet && desktop != null) {
          content = desktop!;
        } else if (constraints.maxWidth >= AppBreakpoints.mobile && tablet != null) {
          content = tablet!;
        } else {
          content = mobile;
        }

        if (centerContent && constraints.maxWidth > maxContentWidth) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
