class Devotional {
  const Devotional({
    required this.id,
    required this.day,
    required this.title,
    required this.verse,
    required this.text,
    required this.prayer,
    this.uuid,
    this.durationMinutes = 3,
    this.verseReference,
    this.isCompleted = false,
  });

  final int id;
  final int day;
  final String title;
  final String verse;
  final String text;
  final String prayer;
  final String? uuid;
  final int durationMinutes;
  final String? verseReference;
  final bool isCompleted;

  /// Returns the Bible reference (e.g. "Proverbs 27:17" or "2 Corinthians 5:17")
  String get effectiveVerseReference {
    if (verseReference != null && verseReference!.trim().isNotEmpty) {
      return verseReference!.trim();
    }
    // Try extracting from parentheses at the end of verse: "(2 Corinthians 5:17)"
    final match = RegExp(r'\(([^)]+)\)\s*$').firstMatch(verse);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return '';
  }

  /// Returns the verse text without the trailing parenthetical reference if present
  String get cleanVerseText {
    final match = RegExp(r'\(([^)]+)\)\s*$').firstMatch(verse);
    if (match != null) {
      final stripped = verse.substring(0, match.start).trim();
      if (stripped.isNotEmpty) return stripped;
    }
    return verse;
  }

  Devotional copyWith({
    int? id,
    int? day,
    String? title,
    String? verse,
    String? text,
    String? prayer,
    String? uuid,
    int? durationMinutes,
    String? verseReference,
    bool? isCompleted,
  }) {
    return Devotional(
      id: id ?? this.id,
      day: day ?? this.day,
      title: title ?? this.title,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      prayer: prayer ?? this.prayer,
      uuid: uuid ?? this.uuid,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      verseReference: verseReference ?? this.verseReference,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Devotional.fromJson(Map<String, dynamic> json) {
    return Devotional(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ??
              (json['day'] as int? ?? 1),
      day: json['day'] as int? ?? (json['day_number'] as int? ?? 1),
      title: json['title'] as String? ?? '',
      verse: json['verse'] as String? ?? '',
      text: json['text'] as String? ?? '',
      prayer: json['prayer'] as String? ?? '',
      uuid: json['uuid'] as String?,
      durationMinutes: json['durationMinutes'] as int? ?? 3,
      verseReference: (json['verseReference'] ?? json['verse_reference']) as String?,
      isCompleted: (json['isCompleted'] ?? json['is_completed']) as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'day': day,
    'title': title,
    'verse': verse,
    'text': text,
    'prayer': prayer,
    'uuid': uuid,
    'durationMinutes': durationMinutes,
    'verseReference': verseReference,
    'isCompleted': isCompleted,
  };
}
