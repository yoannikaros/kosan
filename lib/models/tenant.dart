class Tenant {
  final int? id;
  final int? userId;
  final String name;
  final String? email;
  final String? phone;
  final String? identityNumber;
  final String status;
  final String? createdAt;

  Tenant({
    this.id,
    this.userId,
    required this.name,
    this.email,
    this.phone,
    this.identityNumber,
    this.status = 'active',
    this.createdAt,
  });

  factory Tenant.fromMap(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    userId: json['user_id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    identityNumber: json['identity_number'],
    status: json['status'] ?? 'active',
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'email': email,
    'phone': phone,
    'identity_number': identityNumber,
    'status': status,
    'created_at': createdAt,
  };
}
