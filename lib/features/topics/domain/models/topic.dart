class Topic {
  const Topic({
    required this.id,
    this.uuid,
    required this.tag,
    required this.title,
    this.subtitle,
    required this.description,
    this.scriptureQuote,
    this.scriptureReference,
    required this.supportTips,
    required this.youtubeQuery,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.videoDurationMinutes = 8,
  });

  final int id;
  final String? uuid;
  final String tag;
  final String title;
  final String? subtitle;
  final String description;
  final String? scriptureQuote;
  final String? scriptureReference;
  final List<String> supportTips;
  final String youtubeQuery;
  final String? youtubeUrl;
  final String? youtubeVideoId;
  final int videoDurationMinutes;

  factory Topic.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawUuid = json['uuid'] as String? ?? (rawId is String ? rawId : null);
    final intId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 1;

    List<String> tips = [];
    if (json['supportTips'] != null) {
      tips = List<String>.from(json['supportTips'] as List);
    } else if (json['practices'] != null) {
      tips = (json['practices'] as List)
          .map((p) => p['instructionText']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return Topic(
      id: intId,
      uuid: rawUuid,
      tag: json['tag'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String? ?? '',
      scriptureQuote: json['scriptureQuote'] as String?,
      scriptureReference: json['scriptureReference'] as String?,
      supportTips: tips,
      youtubeQuery: json['youtubeQuery'] as String? ?? '',
      youtubeUrl: json['youtubeUrl'] as String?,
      youtubeVideoId: json['youtubeVideoId'] as String?,
      videoDurationMinutes: json['videoDurationMinutes'] as int? ?? 8,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'tag': tag,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'scriptureQuote': scriptureQuote,
    'scriptureReference': scriptureReference,
    'supportTips': supportTips,
    'youtubeQuery': youtubeQuery,
    'youtubeUrl': youtubeUrl,
    'youtubeVideoId': youtubeVideoId,
    'videoDurationMinutes': videoDurationMinutes,
  };
}
