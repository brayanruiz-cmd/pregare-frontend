import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../primitives/primitives.dart';

/// Minimalist glassmorphism sidebar for web/desktop layout matching PREGARE tokens.
class WebSideNav extends StatefulWidget {
  const WebSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<WebSideNav> createState() => _WebSideNavState();
}

class _WebSideNavState extends State<WebSideNav>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late final AnimationController _animController;
  late final Animation<double> _widthAnim;

  static const double _collapsedW = 68.0;
  static const double _expandedW = 224.0;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.auto_stories_outlined, activeIcon: Icons.auto_stories_rounded, label: 'Bible'),
    _NavItem(icon: Icons.graphic_eq_rounded, activeIcon: Icons.graphic_eq_rounded, label: 'Declare'),
    _NavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'You'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _widthAnim = Tween<double>(begin: _collapsedW, end: _expandedW).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (context, _) {
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              width: _widthAnim.value,
              decoration: const BoxDecoration(
                color: PColors.inkDeep,
                border: Border(
                  right: BorderSide(color: PColors.hairline, width: 0.5),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(),
                    const SizedBox(height: 20),

                    // Nav items
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) => _buildNavItem(index),
                      ),
                    ),

                    // Bottom separator
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      height: 0.5,
                      color: PColors.hairline,
                    ),
                    _buildBottomItem(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          // Toggle button — circular
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PColors.glassFill,
                shape: BoxShape.circle,
                border: Border.all(color: PColors.hairline),
              ),
              child: Icon(
                _expanded ? Icons.chevron_left : Icons.chevron_right,
                size: 18,
                color: PColors.bone,
              ),
            ),
          ),

          if (_widthAnim.value > 120) ...[
            const SizedBox(width: 10),
            Expanded(
              child: AnimatedOpacity(
                opacity: _widthAnim.value > 150 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: const PBrandLogo(
                  isLight: true,
                  height: 22,
                  showWordmark: true,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _items[index];
    final isActive = widget.currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: _expanded ? '' : item.label,
        preferBelow: false,
        waitDuration: const Duration(milliseconds: 500),
        child: GestureDetector(
          onTap: () => widget.onTap(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 46,
            decoration: BoxDecoration(
              color: isActive ? PColors.glassFill : Colors.transparent,
              borderRadius: BorderRadius.circular(PRadius.tile),
              border: isActive ? Border.all(color: PColors.hairline) : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  size: 19,
                  color: isActive ? PColors.bone : PColors.bone45,
                ),
                if (_expanded && _widthAnim.value > 110) ...[
                  const SizedBox(width: 12),
                  AnimatedOpacity(
                    opacity: _widthAnim.value > 130 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      item.label,
                      style: PType.uiStrong.copyWith(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? PColors.bone : PColors.bone62,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Tooltip(
        message: _expanded ? '' : 'Settings',
        child: GestureDetector(
          onTap: () => widget.onTap(4),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: PColors.glassFill,
              borderRadius: BorderRadius.circular(PRadius.tile),
              border: Border.all(color: PColors.hairline),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(
                  Icons.settings_outlined,
                  size: 18,
                  color: PColors.bone45,
                ),
                if (_expanded && _widthAnim.value > 120) ...[
                  const SizedBox(width: 10),
                  AnimatedOpacity(
                    opacity: _widthAnim.value > 130 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      'Settings',
                      style: PType.meta.copyWith(
                        fontSize: 12,
                        color: PColors.bone62,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
