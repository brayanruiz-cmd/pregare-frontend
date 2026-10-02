class FocusArea {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final int order;
  final bool isActive;

  FocusArea({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.order = 0,
    this.isActive = true,
  });

  factory FocusArea.fromJson(Map<String, dynamic> json) {
    return FocusArea(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'order': order,
    'isActive': isActive,
  };
}
