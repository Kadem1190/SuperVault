enum UserRole { admin, staff }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.staff,
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'staff',
      'avatar_url': avatarUrl,
    };
  }
}
