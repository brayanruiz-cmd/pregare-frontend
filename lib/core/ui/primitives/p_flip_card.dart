import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import 'p_brand_logo.dart';

/// PFlipCard — El componente héroe del sistema PREGARE.
///
/// Tarjeta 3D interactiva que voltea al tocar entre rotateY(0) y rotateY(pi).
/// - Duración: 950ms con PMotion.flipCurve.
/// - Altura responsiva que se adapta sin desbordamientos.
/// - Cara frontal: fondo PColors.bone, texto PColors.ink, radio 32, padding 32, sombra PShadows.flip.
/// - Cara trasera: fondo PColors.ink, texto PColors.bone, radio 32, padding 32, sombra PShadows.flip.
/// - Culling manual con Matrix4 perspective setEntry(3, 2, 0.001) y rotación adicional pi en cara B
///   para evitar espejado en todas las plataformas (iOS, Android y Web).
class PFlipCard extends StatefulWidget {
  const PFlipCard({
    super.key,
    required this.scriptureText,
    required this.scriptureRef,
    required this.declarationText,
    required this.topic,
    this.scriptureEyebrow = 'SCRIPTURE',
    this.declarationEyebrow = 'TODAY I DECLARE',
    this.frontPrompt = 'Tap to read the declaration',
    this.backPrompt = 'Tap to return to Scripture',
    this.onFlipChanged,
    this.height = 530.0,
    this.initialFlipped = false,
  });

  final String scriptureText;
  final String scriptureRef;
  final String declarationText;
  final String topic;
  final String scriptureEyebrow;
  final String declarationEyebrow;
  final String frontPrompt;
  final String backPrompt;
  final ValueChanged<bool>? onFlipChanged;
  final double height;
  final bool initialFlipped;

  @override
  State<PFlipCard> createState() => _PFlipCardState();
}

class _PFlipCardState extends State<PFlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late bool _isFront;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isFront = !widget.initialFlipped;
    _controller = AnimationController(
      vsync: this,
      duration: PMotion.flipDuration,
      value: widget.initialFlipped ? 1.0 : 0.0,
    );

    _animation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: PMotion.flipCurve,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isFront = false;
        widget.onFlipChanged?.call(false);
      } else if (status == AnimationStatus.dismissed) {
        _isFront = true;
        widget.onFlipChanged?.call(true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scriptureText != widget.scriptureText ||
        oldWidget.declarationText != widget.declarationText) {
      if (!_isFront) {
        _controller.reset();
        _isFront = true;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableH = constraints.maxHeight.isFinite ? constraints.maxHeight : widget.height;
        // Restar altura de etiqueta y padding para que nunca desborde
        final cardH = max(200.0, availableH - 34.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Tarjeta 3D con Culling Manual y soporte Web/Touch ───────────
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTap: _toggleFlip,
                behavior: HitTestBehavior.opaque,
                child: AnimatedScale(
                  scale: _isHovered ? 1.012 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    height: cardH,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) {
                        final angle = _animation.value;
                        final isUnder = angle >= (pi / 2);

                        final transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // Perspectiva 3D
                          ..rotateY(angle);

                        return Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: isUnder
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi), // Despejar cara B
                                  child: _buildBackFace(cardH),
                                )
                              : _buildFrontFace(cardH),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Etiqueta de estado bajo la tarjeta ─────────────────────────────
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final isBack = _animation.value >= (pi / 2);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sync_rounded,
                      size: 13,
                      color: _isHovered ? PColors.bone : PColors.bone45,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBack ? widget.backPrompt : widget.frontPrompt,
                      style: PType.meta.copyWith(
                        color: _isHovered ? PColors.bone : PColors.bone55,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
          ],
        );

      },
    );
  }

  /// Cara Frontal (Cara A) — Fondo BONE, Texto INK (Escritura)
  Widget _buildFrontFace(double cardHeight) {
    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: PColors.bone,
        borderRadius: BorderRadius.circular(PRadius.flip),
        boxShadow: PShadows.flip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Cara A
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.scriptureEyebrow.toUpperCase(),
                style: PType.eyebrow.copyWith(
                  color: PColors.clay,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.sync_rounded,
                color: PColors.ink40,
                size: 18,
              ),
            ],
          ),

          const Spacer(),

          // Texto Sagrado (Newsreader 300)
          Text(
            widget.scriptureText,
            style: PType.scripture.copyWith(
              color: PColors.ink,
              fontSize: 22,
              height: 1.38,
            ),
          ),

          const SizedBox(height: 14),

          // Referencia Bíblica
          Text(
            widget.scriptureRef,
            style: PType.meta.copyWith(
              color: PColors.ink40,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          // Indicador de marca sutil
          const Center(
            child: PBrandLogo(
              isLight: false,
              height: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Cara Trasera (Cara B) — Fondo INK, Texto BONE (Declaración de Fe)
  Widget _buildBackFace(double cardHeight) {
    return Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: PColors.ink,
        borderRadius: BorderRadius.circular(PRadius.flip),
        border: Border.all(color: PColors.hairline, width: 1.0),
        boxShadow: PShadows.flip,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Cara B
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.declarationEyebrow.toUpperCase(),
                style: PType.eyebrow.copyWith(
                  color: PColors.bone50,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.sync_rounded,
                color: PColors.bone50,
                size: 18,
              ),
            ],
          ),

          const Spacer(),

          // Texto de Declaración (Newsreader 300)
          Text(
            widget.declarationText,
            style: PType.scripture.copyWith(
              color: PColors.bone,
              fontSize: 22,
              height: 1.38,
            ),
          ),

          const SizedBox(height: 14),

          // Tópico y metadatos
          Text(
            '${widget.topic} · ${widget.scriptureRef}',
            style: PType.meta.copyWith(
              color: PColors.bone55,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          // Subtle brand mark
          const Center(
            child: PBrandLogo(
              height: 24,
              isLight: true,
            ),
          ),
        ],
      ),
    );
  }
}
