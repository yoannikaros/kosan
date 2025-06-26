class Room {
  final int? id;
  final int ownerId;
  final String roomNumber;
  final int? floor;
  final double price;
  final String? description;
  final String status;
  final String? createdAt;

  Room({
    this.id,
    required this.ownerId,
    required this.roomNumber,
    this.floor,
    required this.price,
    this.description,
    this.status = 'available',
    this.createdAt,
  });

  factory Room.fromMap(Map<String, dynamic> json) => Room(
    id: json['id'],
    ownerId: json['owner_id'],
    roomNumber: json['room_number'],
    floor: json['floor'],
    price: json['price'],
    description: json['description'],
    status: json['status'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'room_number': roomNumber,
    'floor': floor,
    'price': price,
    'description': description,
    'status': status,
    'created_at': createdAt,
  };
}
