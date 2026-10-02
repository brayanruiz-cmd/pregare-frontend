class Book {
  const Book({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });

  final String id;
  final String name;
  final String testament;
  final int chapters;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      name: json['name'] as String,
      testament: json['testament'] as String,
      chapters: json['chapters'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'testament': testament,
    'chapters': chapters,
  };

  bool get isOldTestament => testament == 'OT';
  bool get isNewTestament => testament == 'NT';
}
