class Transaction {
  final int? id;
  final int ownerId;
  final String transactionDate;
  final String description;
  final double amount;
  final String type;
  final String? category;
  final String? note;

  Transaction({
    this.id,
    required this.ownerId,
    required this.transactionDate,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'transaction_date': transactionDate,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      ownerId: map['owner_id'] as int,
      transactionDate: map['transaction_date'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      type: map['type'] as String,
      category: map['category'] as String?,
      note: map['note'] as String?,
    );
  }
}
