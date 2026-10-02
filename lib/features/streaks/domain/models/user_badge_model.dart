class UserBadgeModel {
  final String code;
  final String title;
  final String description;
  final String icon;
  final String category;
  final bool isUnlocked;
  final String? unlockedAt;
  final double progress;

  const UserBadgeModel({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progress,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🏆',
      category: json['category'] as String? ?? 'general',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
