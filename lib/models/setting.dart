class Setting {
  final int? id;
  final int ownerId;
  final String? businessName;
  final String? noteHeader;
  final String? noteFooter;
  final String? updatedAt;

  Setting({
    this.id,
    required this.ownerId,
    this.businessName,
    this.noteHeader,
    this.noteFooter,
    this.updatedAt,
  });

  factory Setting.fromMap(Map<String, dynamic> json) => Setting(
    id: json['id'],
    ownerId: json['owner_id'],
    businessName: json['business_name'],
    noteHeader: json['note_header'],
    noteFooter: json['note_footer'],
    updatedAt: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'owner_id': ownerId,
    'business_name': businessName,
    'note_header': noteHeader,
    'note_footer': noteFooter,
    'updated_at': updatedAt,
  };
}
