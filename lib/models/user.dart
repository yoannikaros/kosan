class User {
  final int? id;
  final int? ownerId;
  final String username;
  final String password;
  final String role;
  final String? email;
  final String? createdAt;

  User({
    this.id,
    this.ownerId,
    required this.username,
    required this.password,
    required this.role,
    this.email,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'] as int?,
    ownerId: json['owner_id'] as int?,
    username: json['username'] as String,
    password: json['password'] as String,
    role: json['role'] as String? ?? 'tenant',
    email: json['email'] as String?,
    createdAt: json['created_at'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'username': username,
    'password': password,
    'role': role,
    'email': email,
    'created_at': createdAt,
  };
}
