class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.bio,
    this.avatarUrl,
    required this.isOnline,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] ?? '',
      email: map['email'],
      bio: map['bio'],
      avatarUrl: map['avatar_url'],
      isOnline: map['is_online'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'bio': bio,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
    };
  }
}
