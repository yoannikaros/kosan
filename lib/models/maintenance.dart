class Maintenance {
  final int? id;
  final int roomId;
  final String maintenanceDate;
  final String description;
  final double? cost;
  final String? status;
  final String? note;

  Maintenance({
    this.id,
    required this.roomId,
    required this.maintenanceDate,
    required this.description,
    this.cost,
    this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'maintenance_date': maintenanceDate,
      'description': description,
      'cost': cost,
      'status': status,
      'note': note,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      maintenanceDate: map['maintenance_date'] as String,
      description: map['description'] as String,
      cost: map['cost'] as double?,
      status: map['status'] as String?,
      note: map['note'] as String?,
    );
  }
}
