import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// Official PREGARE brand logo widget using the updated brand mark assets.
class PBrandLogo extends StatelessWidget {
  const PBrandLogo({
    super.key,
    this.width,
    this.height = 32,
    this.isLight = true,
    this.showWordmark = false,
  });

  final double? width;
  final double height;
  final bool isLight;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final logoAsset = isLight
        ? 'assets/brand-logo-light.png'
        : 'assets/brand-logo-dark.png';

    final logo = Image.asset(
      logoAsset,
      height: height,
      width: width,
      fit: BoxFit.contain,
    );

    if (!showWordmark) {
      // Wrap in a SizedBox so it never overflows its parent.
      return SizedBox(
        height: height,
        width: width,
        child: FittedBox(fit: BoxFit.contain, child: logo),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: height,
          child: FittedBox(fit: BoxFit.contain, child: logo),
        ),
        const SizedBox(width: 10),
        Text(
          'PREGARE',
          style: PType.wordmark.copyWith(
            color: isLight ? PColors.bone : PColors.ink,
            letterSpacing: 2.8,
            fontSize: (height * 0.55).clamp(13.0, 20.0),
          ),
        ),
      ],
    );
  }
}
