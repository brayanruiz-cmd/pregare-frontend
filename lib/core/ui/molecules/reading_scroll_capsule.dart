import 'dart:ui';
import 'package:flutter/material.dart';

/// ReadingScrollCapsule — Indicador flotante en cápsula para progreso de lectura.
///
/// Inspirado en lectores editoriales prémium:
/// - Contenedor en cápsula vertical translúcido con desenfoque de fondo.
/// - Puntos de guía (track dots) espaciados verticalmente.
/// - Thumb blanco deslizante que mapea en tiempo real la posición del scroll.
/// - Soporte para arrastre táctil directo (drag-to-scroll).
class ReadingScrollCapsule extends StatefulWidget {
  const ReadingScrollCapsule({
    super.key,
    required this.scrollController,
    this.capsuleHeight = 110,
    this.capsuleWidth = 18,
    this.thumbHeight = 32,
    this.dotCount = 4,
    this.thumbColor = Colors.white,
    this.backgroundColor,
  });

  final ScrollController scrollController;
  final double capsuleHeight;
  final double capsuleWidth;
  final double thumbHeight;
  final int dotCount;
  final Color thumbColor;
  final Color? backgroundColor;

  @override
  State<ReadingScrollCapsule> createState() => _ReadingScrollCapsuleState();
}

class _ReadingScrollCapsuleState extends State<ReadingScrollCapsule> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ReadingScrollCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (!widget.scrollController.hasClients) return;
    final position = widget.scrollController.position;
    if (position.maxScrollExtent <= 0) {
      if (_progress != 0.0) setState(() => _progress = 0.0);
      return;
    }
    final newProgress = (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
    if ((newProgress - _progress).abs() > 0.001) {
      setState(() => _progress = newProgress);
    }
  }

  void _handleDrag(DragUpdateDetails details) {
    if (!widget.scrollController.hasClients) return;
    final position = widget.scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    final availableTravel = widget.capsuleHeight - widget.thumbHeight - 8;
    if (availableTravel <= 0) return;

    final deltaRatio = details.delta.dy / availableTravel;
    final targetPixels = (position.pixels + deltaRatio * position.maxScrollExtent)
        .clamp(0.0, position.maxScrollExtent);
    widget.scrollController.jumpTo(targetPixels);
  }

  @override
  Widget build(BuildContext context) {
    final availableTravel = widget.capsuleHeight - widget.thumbHeight - 8;
    final thumbTop = 4 + (_progress * availableTravel);

    return GestureDetector(
      onVerticalDragUpdate: _handleDrag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.capsuleWidth / 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: widget.capsuleWidth,
            height: widget.capsuleHeight,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? const Color(0x9924182E),
              borderRadius: BorderRadius.circular(widget.capsuleWidth / 2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 0.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Puntos guía del track
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.dotCount, (index) {
                    return Container(
                      width: 3.5,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.32),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),

                // Thumb deslizante
                Positioned(
                  top: thumbTop,
                  child: Container(
                    width: widget.capsuleWidth - 8,
                    height: widget.thumbHeight,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: BorderRadius.circular((widget.capsuleWidth - 8) / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
