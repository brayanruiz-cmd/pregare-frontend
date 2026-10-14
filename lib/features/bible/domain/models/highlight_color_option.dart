import 'package:flutter/material.dart';

class HighlightColorOption {
  final String id;
  final String name;
  final String hex;
  final Color fill;
  final Color accent;

  const HighlightColorOption({
    required this.id,
    required this.name,
    required this.hex,
    required this.fill,
    required this.accent,
  });

  static const List<HighlightColorOption> options = [
    HighlightColorOption(
      id: 'amber',
      name: 'Amber',
      hex: '#F7EBD2',
      fill: Color(0xFFF7EBD2),
      accent: Color(0xFFD4A346),
    ),
    HighlightColorOption(
      id: 'sage',
      name: 'Sage',
      hex: '#E2EBD8',
      fill: Color(0xFFE2EBD8),
      accent: Color(0xFF5E946E),
    ),
    HighlightColorOption(
      id: 'sky',
      name: 'Sky',
      hex: '#DDE8F4',
      fill: Color(0xFFDDE8F4),
      accent: Color(0xFF4A7BB0),
    ),
    HighlightColorOption(
      id: 'rose',
      name: 'Rose',
      hex: '#F7DFDC',
      fill: Color(0xFFF7DFDC),
      accent: Color(0xFFB8554E),
    ),
    HighlightColorOption(
      id: 'lavender',
      name: 'Lavender',
      hex: '#E8E0F2',
      fill: Color(0xFFE8E0F2),
      accent: Color(0xFF7E5E9E),
    ),
  ];

  static HighlightColorOption fromHex(String? hex) {
    if (hex == null || hex.isEmpty) return options.first;
    final normalized = hex.toUpperCase();
    for (final opt in options) {
      if (opt.hex.toUpperCase() == normalized) return opt;
    }
    // Fallback: parse custom hex if not in preset
    try {
      final clean = hex.replaceAll('#', '');
      final val = int.parse('FF$clean', radix: 16);
      return HighlightColorOption(
        id: 'custom',
        name: 'Custom',
        hex: hex,
        fill: Color(val),
        accent: Color(val),
      );
    } catch (_) {
      return options.first;
    }
  }
}
