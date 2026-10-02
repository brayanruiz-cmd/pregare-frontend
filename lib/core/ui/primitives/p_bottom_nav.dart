import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import 'p_brand_logo.dart';

/// PBottomNav — Barra de navegación flotante del sistema PREGARE.
/// Flotante con left/right: 20, bottom: 24, alto 70, radio 35, blur sigma 12
/// sobre PColors.navFill con borde glassStroke y sombra PShadows.nav.
///
/// Cinco columnas iguales: Home · Bible · Declare · Explore · You.
/// Declare is centered (not a FAB): uses PBrandLogo at 24px with label at .8 scale.
class PBottomNav extends StatelessWidget {
  const PBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: PSpace.navInsetX,
      right: PSpace.navInsetX,
      bottom: PSpace.navInsetBottom,
      height: PSpace.navHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PRadius.nav),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PMotion.navBlurSigma,
            sigmaY: PMotion.navBlurSigma,
          ),
          child: Container(
            height: PSpace.navHeight,
            decoration: BoxDecoration(
              color: PColors.navFill,
              borderRadius: BorderRadius.circular(PRadius.nav),
              border: Border.all(color: PColors.glassStroke, width: 1.0),
              boxShadow: PShadows.nav,
            ),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  label: 'Bible',
                ),
                _buildDeclareItem(
                  index: 2,
                  label: 'Declare',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Explore',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'You',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final color = isActive ? PColors.bone : PColors.bone45;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: PType.navLabel.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeclareItem({
    required int index,
    required String label,
  }) {
    final isActive = currentIndex == index;
    final labelColor = isActive ? PColors.bone : PColors.bone70;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PBrandLogo(
              isLight: true,
              height: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: PType.navLabel.copyWith(
                color: labelColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
