class StreakActivityLog {
  const StreakActivityLog({
    required this.date,
    required this.declarationsRead,
    required this.chaptersRead,
    required this.devotionalCompleted,
  });

  final String date;
  final int declarationsRead;
  final int chaptersRead;
  final bool devotionalCompleted;

  factory StreakActivityLog.fromJson(Map<String, dynamic> json) {
    return StreakActivityLog(
      date: json['date'] as String? ?? '',
      declarationsRead: json['declarationsRead'] as int? ?? 0,
      chaptersRead: json['chaptersRead'] as int? ?? 0,
      devotionalCompleted: json['devotionalCompleted'] as bool? ?? false,
    );
  }
}

class MonthActivity {
  const MonthActivity({
    required this.year,
    required this.month,
    required this.monthName,
    required this.activeDaysCount,
    required this.totalDaysInMonth,
    required this.activeDates,
    required this.logs,
  });

  final int year;
  final int month;
  final String monthName;
  final int activeDaysCount;
  final int totalDaysInMonth;
  final List<String> activeDates;
  final List<StreakActivityLog> logs;

  factory MonthActivity.fromJson(Map<String, dynamic> json) {
    final rawLogs = json['logs'] as List? ?? [];
    final rawDates = json['activeDates'] as List? ?? [];

    return MonthActivity(
      year: json['year'] as int? ?? DateTime.now().year,
      month: json['month'] as int? ?? DateTime.now().month,
      monthName: json['monthName'] as String? ?? '',
      activeDaysCount: json['activeDaysCount'] as int? ?? 0,
      totalDaysInMonth: json['totalDaysInMonth'] as int? ?? 30,
      activeDates: rawDates.map((e) => e.toString()).toList(),
      logs: rawLogs
          .map((e) => StreakActivityLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
