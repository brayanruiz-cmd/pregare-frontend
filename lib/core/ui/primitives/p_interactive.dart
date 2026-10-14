import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// PInteractive — Primitive wrapper for interactive elements across all platforms.
///
/// Provides:
/// - Web / Desktop: `SystemMouseCursors.click` and hover tracking (`isHovered`).
/// - Mobile / Touch: Native tactile press feedback (`isPressed`) with micro-scale
///   or opacity transition, guaranteeing instant recognition on touch devices.
class PInteractive extends StatefulWidget {
  const PInteractive({
    super.key,
    required this.onTap,
    this.child,
    this.builder,
    this.pressedScale = 0.985,
    this.pressedOpacity = 0.85,
    this.hoverScale = 1.0,
    this.borderRadius,
    this.hoverColor,
    this.cursor = SystemMouseCursors.click,
    this.behavior = HitTestBehavior.opaque,
    this.tooltip,
  }) : assert(child != null || builder != null, 'Provide either child or builder');

  final VoidCallback? onTap;
  final Widget? child;
  final Widget Function(BuildContext context, bool isHovered, bool isPressed)? builder;
  final double pressedScale;
  final double pressedOpacity;
  final double hoverScale;
  final BorderRadius? borderRadius;
  final Color? hoverColor;
  final MouseCursor cursor;
  final HitTestBehavior behavior;
  final String? tooltip;

  @override
  State<PInteractive> createState() => _PInteractiveState();
}

class _PInteractiveState extends State<PInteractive> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _onEnter(_) {
    if (widget.onTap != null && mounted) {
      setState(() => _isHovered = true);
    }
  }

  void _onExit(_) {
    if (mounted) {
      setState(() {
        _isHovered = false;
        _isPressed = false;
      });
    }
  }

  void _onTapDown(_) {
    if (widget.onTap != null && mounted) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(_) {
    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null;

    Widget current = widget.builder != null
        ? widget.builder!(context, _isHovered, _isPressed)
        : widget.child!;

    if (widget.hoverColor != null && _isHovered) {
      current = DecoratedBox(
        decoration: BoxDecoration(
          color: widget.hoverColor,
          borderRadius: widget.borderRadius,
        ),
        child: current,
      );
    }

    if (isInteractive) {
      final scale = _isPressed
          ? widget.pressedScale
          : (_isHovered ? widget.hoverScale : 1.0);
      final opacity = _isPressed ? widget.pressedOpacity : 1.0;

      current = AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 100),
          child: current,
        ),
      );
    }

    Widget interactiveWidget = MouseRegion(
      cursor: isInteractive ? widget.cursor : SystemMouseCursors.basic,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        behavior: widget.behavior,
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: current,
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: interactiveWidget,
      );
    }

    return interactiveWidget;
  }
}

/// PLink — Specialized link for text and inline actions.
///
/// Features:
/// - Visual affordance: Includes subtle arrow icon and underline cues.
/// - Web: Changes cursor to pointer and shifts color/underline on hover.
/// - Mobile: Responds instantly with opacity feedback on press and has a comfortable tap target.
class PLink extends StatefulWidget {
  const PLink({
    super.key,
    required this.text,
    required this.onTap,
    this.textStyle,
    this.trailingIcon = Icons.arrow_outward_rounded,
    this.showIcon = true,
    this.iconSize = 12,
    this.underlineOnHover = true,
    this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
  });

  final String text;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final IconData? trailingIcon;
  final bool showIcon;
  final double iconSize;
  final bool underlineOnHover;
  final EdgeInsetsGeometry padding;

  @override
  State<PLink> createState() => _PLinkState();
}

class _PLinkState extends State<PLink> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.textStyle ?? PType.meta.copyWith(color: PColors.bone62);
    final activeColor = _isHovered ? PColors.bone : baseStyle.color ?? PColors.bone62;

    final effectiveStyle = baseStyle.copyWith(
      color: activeColor,
      decoration: (_isHovered && widget.underlineOnHover)
          ? TextDecoration.underline
          : TextDecoration.none,
      decorationColor: activeColor,
    );

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedOpacity(
          opacity: _isPressed ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: Padding(
            padding: widget.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.text,
                    style: effectiveStyle,
                  ),
                ),
                if (widget.showIcon && widget.trailingIcon != null) ...[
                  const SizedBox(width: 4),
                  AnimatedSlide(
                    offset: _isHovered ? const Offset(0.08, -0.08) : Offset.zero,
                    duration: const Duration(milliseconds: 140),
                    child: Icon(
                      widget.trailingIcon,
                      size: widget.iconSize,
                      color: _isHovered ? PColors.bone : PColors.bone45,
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
