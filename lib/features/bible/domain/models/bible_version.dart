class BibleVersion {
  const BibleVersion({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
  });

  final String id;
  final String name;
  final String abbreviation;
  final String language;

  factory BibleVersion.fromJson(Map<String, dynamic> json) {
    return BibleVersion(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      language: json['language'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'abbreviation': abbreviation,
    'language': language,
  };
}
