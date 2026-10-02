import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// PREGARE Signature Bottom Navigation Bar
/// 5 tabs: Home, Bible, Declare (3D Golden Glowing Orb), Explore, You
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, this.currentIndex = 0, this.onTap});

  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 4),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: const Color(0xFF16141A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tab 0: Home
                  _RegularNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    isActive: currentIndex == 0,
                    onTap: () => onTap?.call(0),
                  ),

                  // Tab 1: Bible
                  _RegularNavItem(
                    icon: Icons.auto_stories_outlined,
                    activeIcon: Icons.auto_stories_rounded,
                    label: 'Bible',
                    isActive: currentIndex == 1,
                    onTap: () => onTap?.call(1),
                  ),

                  // Tab 2: Declare (Center 3D Glowing Orb)
                  _CenterOrbNavItem(
                    isActive: currentIndex == 2,
                    onTap: () => onTap?.call(2),
                  ),

                  // Tab 3: Explore
                  _RegularNavItem(
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore_rounded,
                    label: 'Explore',
                    isActive: currentIndex == 3,
                    onTap: () => onTap?.call(3),
                  ),

                  // Tab 4: You
                  _RegularNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'You',
                    isActive: currentIndex == 4,
                    onTap: () => onTap?.call(4),
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

class _RegularNavItem extends StatelessWidget {
  const _RegularNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 54,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.white : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isActive ? Colors.white : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Center 3D Glowing Golden Sphere Orb
class _CenterOrbNavItem extends StatelessWidget {
  const _CenterOrbNavItem({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  radius: 0.85,
                  colors: [
                    Color(0xFFFFF9EE), // Specular light highlight
                    Color(0xFFE8C58D), // Warm body gold
                    Color(0xFFC48E4B), // Golden shadow
                    Color(0xFF7E4F20), // Ambient occlusion edge
                  ],
                  stops: [0.0, 0.4, 0.75, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE5A855).withValues(alpha: isActive ? 0.7 : 0.35),
                    blurRadius: isActive ? 14 : 8,
                    spreadRadius: isActive ? 2 : 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Declare',
              style: AppTypography.caption.copyWith(
                color: isActive ? const Color(0xFFE8C58D) : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
