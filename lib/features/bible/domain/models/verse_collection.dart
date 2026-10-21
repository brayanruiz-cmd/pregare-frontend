import 'verse_collection_item.dart';

class VerseCollection {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String colorHex;
  final bool isPrivate;
  final int itemsCount;
  final List<VerseCollectionItem> previewVerses;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VerseCollection({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.colorHex,
    required this.isPrivate,
    required this.itemsCount,
    required this.previewVerses,
    required this.createdAt,
    this.updatedAt,
  });

  factory VerseCollection.fromJson(Map<String, dynamic> json) {
    var rawPreviews = json['previewVerses'] as List? ?? json['items'] as List? ?? [];
    List<VerseCollectionItem> previews = [];
    for (var item in rawPreviews) {
      if (item is Map<String, dynamic>) {
        previews.add(VerseCollectionItem.fromJson(item));
      }
    }

    return VerseCollection(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      colorHex: json['colorHex'] as String? ?? json['color_hex'] as String? ?? '#B58D3D',
      isPrivate: json['isPrivate'] as bool? ?? json['is_private'] as bool? ?? true,
      itemsCount: json['itemsCount'] as int? ?? (json['items'] as List?)?.length ?? 0,
      previewVerses: previews,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  VerseCollection copyWith({
    String? title,
    String? description,
    String? colorHex,
    bool? isPrivate,
    int? itemsCount,
    List<VerseCollectionItem>? previewVerses,
  }) {
    return VerseCollection(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      isPrivate: isPrivate ?? this.isPrivate,
      itemsCount: itemsCount ?? this.itemsCount,
      previewVerses: previewVerses ?? this.previewVerses,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'colorHex': colorHex,
        'isPrivate': isPrivate,
        'itemsCount': itemsCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
