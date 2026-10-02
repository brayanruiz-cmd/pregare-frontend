class DailyVerse {
  const DailyVerse({
    required this.text,
    required this.reference,
    required this.version,
    this.devotionalId,
    this.devotionalDay,
    this.devotionalTitle,
  });

  final String text;
  final String reference;
  final String version;
  /// UUID of today's devotional in the DB
  final String? devotionalId;
  /// Day number of today's devotional (1–365)
  final int? devotionalDay;
  final String? devotionalTitle;

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      text: json['text'] as String,
      reference: json['reference'] as String,
      version: json['version'] as String? ?? 'NIV',
      devotionalId: json['devotionalId'] as String?,
      devotionalDay: json['devotionalDay'] as int?,
      devotionalTitle: json['devotionalTitle'] as String?,
    );
  }
}

class DailyDevotionalSummary {
  const DailyDevotionalSummary({
    required this.id,
    required this.title,
    required this.durationMinutes,
  });

  final int id;
  final String title;
  final int durationMinutes;

  factory DailyDevotionalSummary.fromJson(Map<String, dynamic> json) {
    return DailyDevotionalSummary(
      id: json['id'] as int? ?? 1,
      title: json['title'] as String? ?? "Today's devotional",
      durationMinutes: json['durationMinutes'] as int? ?? 2,
    );
  }
}

class HomeData {
  const HomeData({
    required this.greeting,
    required this.emoji,
    required this.dailyVerse,
    this.dailyDevotional,
  });

  final String greeting;
  final String emoji;
  final DailyVerse dailyVerse;
  final DailyDevotionalSummary? dailyDevotional;

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final verse = json['dailyVerse'] as Map<String, dynamic>;
    final devJson = json['dailyDevotional'] as Map<String, dynamic>?;

    return HomeData(
      greeting: json['greeting'] as String,
      emoji: json['emoji'] as String,
      dailyVerse: DailyVerse.fromJson(verse['verse'] as Map<String, dynamic>),
      dailyDevotional: devJson != null ? DailyDevotionalSummary.fromJson(devJson) : null,
    );
  }
}
