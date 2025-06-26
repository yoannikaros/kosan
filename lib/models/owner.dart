class Owner {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? createdAt;

  Owner({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory Owner.fromMap(Map<String, dynamic> json) => Owner(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'created_at': createdAt,
  };
}
