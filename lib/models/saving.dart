class Saving {
  final int? id;
  final int ownerId;
  final String savingDate;
  final String description;
  final double amount;
  final double? targetAmount;
  final String? status;
  final String? note;

  Saving({
    this.id,
    required this.ownerId,
    required this.savingDate,
    required this.description,
    required this.amount,
    this.targetAmount,
    this.status,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'saving_date': savingDate,
      'description': description,
      'amount': amount,
      'target_amount': targetAmount,
      'status': status,
      'note': note,
    };
  }

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      savingDate: map['saving_date'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      targetAmount: map['target_amount'] as double?,
      status: map['status'] as String?,
      note: map['note'] as String?,
    );
  }
}
