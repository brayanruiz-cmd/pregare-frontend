class NotificationPreferences {
  const NotificationPreferences({
    required this.userId,
    required this.dailyVerse,
    required this.declarations,
    required this.streakReminder,
    required this.reminderTime,
  });

  final String userId;
  final bool dailyVerse;
  final bool declarations;
  final bool streakReminder;
  final String reminderTime;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      userId: json['userId'] as String,
      dailyVerse: json['dailyVerse'] as bool,
      declarations: json['declarations'] as bool,
      streakReminder: json['streakReminder'] as bool,
      reminderTime: json['reminderTime'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'dailyVerse': dailyVerse,
    'declarations': declarations,
    'streakReminder': streakReminder,
    'reminderTime': reminderTime,
  };

  NotificationPreferences copyWith({
    bool? dailyVerse,
    bool? declarations,
    bool? streakReminder,
    String? reminderTime,
  }) {
    return NotificationPreferences(
      userId: userId,
      dailyVerse: dailyVerse ?? this.dailyVerse,
      declarations: declarations ?? this.declarations,
      streakReminder: streakReminder ?? this.streakReminder,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
