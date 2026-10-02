class Verse {
  const Verse({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  static String cleanVerseText(String raw) {
    var s = raw;
    s = s.replaceAll(RegExp(r'<S[^>]*>[\s\S]*?<\/S>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<sub[^>]*>[\s\S]*?<\/sub>', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    s = s.replaceAll(RegExp(r'([A-Za-z])\d{3,5}\b'), r'$1');
    s = s.replaceAll(RegExp(r'\b\d{3,5}\b'), '');
    s = s.replaceAll(RegExp(r'\s+([,.;:!?])'), r'$1');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      number: json['number'] as int,
      text: cleanVerseText(json['text'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'text': text,
  };
}
