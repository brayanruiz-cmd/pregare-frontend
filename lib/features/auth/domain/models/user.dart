class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.gender,
    this.provider = 'email',
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? gender;
  final String provider;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      gender: json['gender'] as String?,
      provider: json['provider'] as String? ?? 'email',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'gender': gender,
      'provider': provider,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? role,
    String? gender,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      provider: provider,
      createdAt: createdAt,
    );
  }
}

