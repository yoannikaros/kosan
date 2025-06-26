class Facility {
  final int? id;
  final int roomId;
  final String facilityName;
  final String? description;

  Facility({
    this.id,
    required this.roomId,
    required this.facilityName,
    this.description,
  });

  factory Facility.fromMap(Map<String, dynamic> json) => Facility(
    id: json['id'],
    roomId: json['room_id'],
    facilityName: json['facility_name'],
    description: json['description'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'room_id': roomId,
    'facility_name': facilityName,
    'description': description,
  };
}
