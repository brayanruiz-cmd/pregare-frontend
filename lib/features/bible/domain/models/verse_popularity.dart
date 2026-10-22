class VersePopularity {
  final int count;
  final int tier; // 0: normal, 1: relevante, 2: muy querido, 3: universal
  final String label;
  final bool isPopular;

  const VersePopularity({
    required this.count,
    required this.tier,
    required this.label,
    required this.isPopular,
  });

  factory VersePopularity.fromJson(Map<String, dynamic> json) {
    return VersePopularity(
      count: json['count'] as int? ?? 0,
      tier: json['tier'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'tier': tier,
        'label': label,
        'isPopular': isPopular,
      };

  static const empty = VersePopularity(
    count: 0,
    tier: 0,
    label: '',
    isPopular: false,
  );
}
