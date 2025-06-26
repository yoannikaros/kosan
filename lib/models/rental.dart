class Rental {
  final int? id;
  final int tenantId;
  final int roomId;
  final String startDate;
  final String endDate;
  final double rentPrice;
  final String status;
  final String? createdAt;

  Rental({
    this.id,
    required this.tenantId,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.rentPrice,
    this.status = 'active',
    this.createdAt,
  });

  factory Rental.fromMap(Map<String, dynamic> json) => Rental(
    id: json['id'],
    tenantId: json['tenant_id'],
    roomId: json['room_id'],
    startDate: json['start_date'],
    endDate: json['end_date'],
    rentPrice: json['rent_price'],
    status: json['status'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'tenant_id': tenantId,
    'room_id': roomId,
    'start_date': startDate,
    'end_date': endDate,
    'rent_price': rentPrice,
    'status': status,
    'created_at': createdAt,
  };
}
