class Streak {
  const Streak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    required this.totalDaysActive,
    this.declarationsSpoken = 0,
    this.chaptersRead = 0,
    this.savedDeclarationsCount = 0,
    this.highlightsCount = 0,
    this.completedDevotionalsCount = 0,
  });

  final String userId;
  final int currentStreak;
  final int longestStreak;
  final String? lastCheckInDate;
  final int totalDaysActive;
  final int declarationsSpoken;
  final int chaptersRead;
  final int savedDeclarationsCount;
  final int highlightsCount;
  final int completedDevotionalsCount;

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      userId: json['userId'] as String? ?? 'default',
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastCheckInDate: json['lastCheckInDate'] as String?,
      totalDaysActive: json['totalDaysActive'] as int? ?? 0,
      declarationsSpoken: json['declarationsSpoken'] as int? ?? (json['declarations_spoken_count'] as int? ?? 0),
      chaptersRead: json['chaptersRead'] as int? ?? (json['chapters_read_count'] as int? ?? 0),
      savedDeclarationsCount: json['savedDeclarationsCount'] as int? ?? 0,
      highlightsCount: json['highlightsCount'] as int? ?? 0,
      completedDevotionalsCount: json['completedDevotionalsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastCheckInDate': lastCheckInDate,
    'totalDaysActive': totalDaysActive,
    'declarationsSpoken': declarationsSpoken,
    'chaptersRead': chaptersRead,
    'savedDeclarationsCount': savedDeclarationsCount,
    'highlightsCount': highlightsCount,
    'completedDevotionalsCount': completedDevotionalsCount,
  };
}
