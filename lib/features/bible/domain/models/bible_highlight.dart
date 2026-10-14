class BibleHighlight {
  final String id;
  final String userId;
  final String bookId;
  final int chapter;
  final int verseNumber;
  final String verseText;
  final String version;
  final String colorHex;
  final DateTime createdAt;

  BibleHighlight({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.version,
    required this.colorHex,
    required this.createdAt,
  });

  factory BibleHighlight.fromJson(Map<String, dynamic> json) {
    return BibleHighlight(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      bookId: json['bookId'] as String? ?? json['book_id'] as String? ?? '',
      chapter: json['chapter'] as int? ?? 1,
      verseNumber: json['verseNumber'] as int? ?? json['verse_number'] as int? ?? 1,
      verseText: json['verseText'] as String? ?? json['verse_text'] as String? ?? '',
      version: json['version'] as String? ?? 'RVR1960',
      colorHex: json['colorHex'] as String? ?? json['color_hex'] as String? ?? '#F7EBD2',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'bookId': bookId,
        'chapter': chapter,
        'verseNumber': verseNumber,
        'verseText': verseText,
        'version': version,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
      };
}
