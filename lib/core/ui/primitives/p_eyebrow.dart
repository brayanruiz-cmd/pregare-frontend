import 'package:flutter/material.dart';
import '../../theme/tokens.dart';

/// PEyebrow — 9-10px, mayúsculas, tracking amplio en px.
/// Es la firma del sistema visual de PREGARE.
class PEyebrow extends StatelessWidget {
  const PEyebrow(
    this.text, {
    super.key,
    this.color,
    this.small = false,
  });

  final String text;
  final Color? color;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final baseStyle = small ? PType.eyebrowSmall : PType.eyebrow;
    final style = color != null ? baseStyle.copyWith(color: color) : baseStyle;

    return Text(
      text.toUpperCase(),
      style: style,
    );
  }
}
