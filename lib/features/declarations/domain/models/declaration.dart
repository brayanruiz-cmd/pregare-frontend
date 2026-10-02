class Declaration {
  const Declaration({
    required this.id,
    required this.gender,
    required this.topics,
    required this.text,
    required this.reference,
    required this.verse,
  });

  final dynamic id;
  final String gender;
  final List<String> topics;
  final String text;
  final String reference;
  final String verse;

  factory Declaration.fromJson(Map<String, dynamic> json) {
    return Declaration(
      id: json['id'] ?? '',
      gender: json['gender'] as String? ?? 'todos',
      topics: json['topics'] != null
          ? List<String>.from(json['topics'] as List)
          : [],
      text: json['text'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      verse: json['verse'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gender': gender,
    'topics': topics,
    'text': text,
    'reference': reference,
    'verse': verse,
  };
}
