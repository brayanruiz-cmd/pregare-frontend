import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../primitives/p_brand_logo.dart';

/// A dynamic, multi-layered organic liquid slime motion widget.
///
/// Transitions smoothly:
///   1. Crisp PREGARE logo
///   2. Melts into a pure circular droplet
///   3. Mutates into an organic, living viscous slime with tactile elasticity
///
/// Features:
///   - Real-time harmonic wave spline interpolation (60/120 FPS)
///   - Multi-layer visual depth (ambient drop shadow, outer viscous halo, solid black body,
///     specular liquid reflection, and secondary internal droplet)
///   - Tactile impulse physics: taps/presses inject a wobbling spring wave
class LiquidLogoMorph extends StatefulWidget {
  const LiquidLogoMorph({
    super.key,
    this.size = 140.0,
    this.solidColor = const Color(0xFF0C0E12),
    this.accentGlow = const Color(0xFF2C2F38),
    this.autoStart = true,
    this.isInteractive = true,
    this.showInitialLogo = true,
    this.onTap,
  });

  /// The diameter/bounding size of the liquid entity.
  final double size;

  /// The primary solid black color for the liquid body.
  final Color solidColor;

  /// Ambient specular/glow color for specular highlights and depth shadows.
  final Color accentGlow;

  /// Whether the logo -> circle -> slime morph animation starts automatically.
  final bool autoStart;

  /// Whether tapping/clicking injects kinetic wobbling impulse waves.
  final bool isInteractive;

  /// Whether to begin in the logo phase. If false, starts directly as living liquid.
  final bool showInitialLogo;

  /// Optional tap callback.
  final VoidCallback? onTap;

  @override
  State<LiquidLogoMorph> createState() => _LiquidLogoMorphState();
}

class _LiquidLogoMorphState extends State<LiquidLogoMorph>
    with TickerProviderStateMixin {
  // Continuous clock for the harmonic wave equations
  late final AnimationController _timeController;

  // Master transition controller: 0.0 = Logo, 0.45 = Circle, 1.0 = Full Slime Fluid
  late final AnimationController _morphController;

  // Kinetic wobble controller triggered on tap/interaction (spring damped impulse)
  late final AnimationController _wobbleController;
  late final Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Continuous wave oscillation clock
    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat();

    // 2. Morph transition sequence (Logo -> Circle -> Slime)
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 3. Tactile impulse wobble (spring damped jiggle)
    _wobbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _wobbleAnimation = CurvedAnimation(
      parent: _wobbleController,
      curve: Curves.elasticOut,
    );

    if (widget.autoStart) {
      if (widget.showInitialLogo) {
        // Give the user a brief moment to register the logo, then morph
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _morphController.forward();
          }
        });
      } else {
        _morphController.value = 1.0;
      }
    } else {
      if (!widget.showInitialLogo) {
        _morphController.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _morphController.dispose();
    _wobbleController.dispose();
    super.dispose();
  }

  void _triggerImpulse() {
    if (!widget.isInteractive) return;
    HapticFeedback.lightImpact();
    _wobbleController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerImpulse,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _timeController,
            _morphController,
            _wobbleAnimation,
          ]),
          builder: (context, _) {
            final time = _timeController.value * 2 * math.pi;
            final morph = _morphController.value;
            final wobble = _wobbleController.isAnimating
                ? (1.0 - _wobbleAnimation.value) * 0.45
                : 0.0;

            // Logo opacity fades out as morph proceeds from 0.0 to 0.42
            final logoOpacity = (1.0 - (morph / 0.42)).clamp(0.0, 1.0);
            final logoScale = (1.0 - (morph * 0.28)).clamp(0.72, 1.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                // Layered organic liquid body (Painter)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _LiquidSlimePainter(
                    time: time,
                    morphProgress: morph,
                    wobbleImpulse: wobble,
                    solidColor: widget.solidColor,
                    accentGlow: widget.accentGlow,
                  ),
                ),

                // Center PREGARE logo during initial phase
                if (logoOpacity > 0.001)
                  Opacity(
                    opacity: logoOpacity,
                    child: Transform.scale(
                      scale: logoScale,
                      child: PBrandLogo(
                        height: widget.size * 0.38,
                        isLight: true,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// High-performance painter computing multi-layered organic fluid dynamics
/// using harmonic Fourier radial modulation and smooth cubic Bézier splines.
class _LiquidSlimePainter extends CustomPainter {
  const _LiquidSlimePainter({
    required this.time,
    required this.morphProgress,
    required this.wobbleImpulse,
    required this.solidColor,
    required this.accentGlow,
  });

  final double time;
  final double morphProgress;
  final double wobbleImpulse;
  final Color solidColor;
  final Color accentGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = (size.width / 2) * 0.72;

    // Fluid activity scales up after morphing past the logo phase
    // 0.0 = minimal wave (circle), 1.0 = rich viscous slime
    final fluidActivity = ((morphProgress - 0.25) / 0.75).clamp(0.0, 1.0);
    final waveAmplitude = (0.13 * fluidActivity) + wobbleImpulse;

    // ─────────────────────────────────────────────────────────────────────────
    // Layer 1: Ambient Drop Shadow & Viscous Occlusion
    // ─────────────────────────────────────────────────────────────────────────
    final shadowPath = _buildHarmonicSplinePath(
      center: center + const Offset(0, 10),
      baseRadius: baseRadius * 1.02,
      amplitude: waveAmplitude * 0.85,
      frequencyShift: 0.15,
      time: time * 0.8,
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.48 * morphProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18.0);
    canvas.drawPath(shadowPath, shadowPaint);

    // ─────────────────────────────────────────────────────────────────────────
    // Layer 2: Outer Viscous Halo (Slightly larger, leading the fluid motion)
    // ─────────────────────────────────────────────────────────────────────────
    if (fluidActivity > 0.05) {
      final haloPath = _buildHarmonicSplinePath(
        center: center,
        baseRadius: baseRadius * 1.045,
        amplitude: waveAmplitude * 1.15,
        frequencyShift: 0.45,
        time: time * 1.15,
      );

      final haloPaint = Paint()
        ..color = solidColor.withValues(alpha: 0.22 * fluidActivity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(haloPath, haloPaint);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Layer 3: Main Solid Black Liquid Body (Slime Nucleus)
    // ─────────────────────────────────────────────────────────────────────────
    final mainSlimePath = _buildHarmonicSplinePath(
      center: center,
      baseRadius: baseRadius,
      amplitude: waveAmplitude,
      frequencyShift: 0.0,
      time: time,
    );

    final bodyPaint = Paint()
      ..color = solidColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(mainSlimePath, bodyPaint);

    // Outer edge definition stroke (gives tactile rim clarity)
    final rimPaint = Paint()
      ..color = accentGlow.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(mainSlimePath, rimPaint);

    // ─────────────────────────────────────────────────────────────────────────
    // Layer 4: Specular Liquid Sheen (Viscous Top-Left Highlight)
    // ─────────────────────────────────────────────────────────────────────────
    if (morphProgress > 0.2) {
      canvas.save();
      // Clip to main slime body so the highlight stays naturally contained
      canvas.clipPath(mainSlimePath);

      final highlightCenter = center + Offset(-baseRadius * 0.26, -baseRadius * 0.28);
      final highlightRadius = baseRadius * 0.52;

      final highlightPath = _buildHarmonicSplinePath(
        center: highlightCenter,
        baseRadius: highlightRadius,
        amplitude: waveAmplitude * 0.7,
        frequencyShift: 1.2,
        time: time * 0.95,
      );

      final highlightPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.22 * fluidActivity),
            Colors.white.withValues(alpha: 0.06 * fluidActivity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: highlightCenter, radius: highlightRadius));

      canvas.drawPath(highlightPath, highlightPaint);
      canvas.restore();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Layer 5: Secondary Internal Droplet (Floating organically inside)
    // ─────────────────────────────────────────────────────────────────────────
    if (fluidActivity > 0.1) {
      final innerOrbitRadius = baseRadius * 0.22;
      final innerAngle = time * 0.75;
      final innerCenter = center +
          Offset(
            math.cos(innerAngle) * innerOrbitRadius,
            math.sin(innerAngle * 1.3) * (innerOrbitRadius * 0.65),
          );

      final innerPath = _buildHarmonicSplinePath(
        center: innerCenter,
        baseRadius: baseRadius * 0.38,
        amplitude: waveAmplitude * 0.9,
        frequencyShift: 2.1,
        time: time * 1.4,
      );

      final innerPaint = Paint()
        ..color = accentGlow.withValues(alpha: 0.16 * fluidActivity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(innerPath, innerPaint);
    }
  }

  /// Generates a perfectly smooth, closed Bézier spline path using 12 radial
  /// harmonic sample points modulated by harmonic sinusoidal frequencies.
  Path _buildHarmonicSplinePath({
    required Offset center,
    required double baseRadius,
    required double amplitude,
    required double frequencyShift,
    required double time,
  }) {
    const int numPoints = 12;
    final List<Offset> points = [];

    for (int i = 0; i < numPoints; i++) {
      final double theta = (2 * math.pi * i) / numPoints;

      // Harmonic Fourier wave components:
      //  - Harmonic 2: Elliptical stretch
      //  - Harmonic 3: Triangular gelatinous flow
      //  - Harmonic 5: Micro-viscous surface ripples
      final double wave1 = math.sin((2 * theta) + time + frequencyShift);
      final double wave2 = math.cos((3 * theta) - (time * 1.2) + (frequencyShift * 1.5));
      final double wave3 = math.sin((5 * theta) + (time * 1.8) - frequencyShift);

      // Combined organic modulation factor
      final double modulation = (wave1 * 0.52) + (wave2 * 0.33) + (wave3 * 0.15);
      final double radius = baseRadius * (1.0 + (amplitude * modulation));

      final double px = center.dx + (radius * math.cos(theta));
      final double py = center.dy + (radius * math.sin(theta));
      points.add(Offset(px, py));
    }

    final path = Path();
    if (points.isEmpty) return path;

    // Use midpoint quadratic Bézier splines to guarantee C1 tangent continuity
    // throughout the entire perimeter (no corners, perfectly fluid).
    final Offset firstMid = Offset(
      (points[0].dx + points[1].dx) / 2,
      (points[0].dy + points[1].dy) / 2,
    );
    path.moveTo(firstMid.dx, firstMid.dy);

    for (int i = 1; i <= numPoints; i++) {
      final curr = points[i % numPoints];
      final next = points[(i + 1) % numPoints];
      final mid = Offset((curr.dx + next.dx) / 2, (curr.dy + next.dy) / 2);

      path.quadraticBezierTo(curr.dx, curr.dy, mid.dx, mid.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _LiquidSlimePainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.morphProgress != morphProgress ||
        oldDelegate.wobbleImpulse != wobbleImpulse;
  }
}
