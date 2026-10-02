import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktopMaxContent = 480;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double contentPadding(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 22;
    return 16;
  }

  static double iconSize(BuildContext context, {double mobile = 24, double tablet = 28, double desktop = 32}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static double cardPadding(BuildContext context, {double mobile = 12, double tablet = 16, double desktop = 20}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
