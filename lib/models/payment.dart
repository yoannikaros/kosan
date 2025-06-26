class Payment {
  final int? id;
  final int rentalId;
  final String paymentDate;
  final double amount;
  final String? paymentMethod;
  final String? note;
  final String? createdAt;

  Payment({
    this.id,
    required this.rentalId,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod,
    this.note,
    this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> json) => Payment(
    id: json['id'],
    rentalId: json['rental_id'],
    paymentDate: json['payment_date'],
    amount: json['amount'],
    paymentMethod: json['payment_method'],
    note: json['note'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'rental_id': rentalId,
    'payment_date': paymentDate,
    'amount': amount,
    'payment_method': paymentMethod,
    'note': note,
    'created_at': createdAt,
  };
}
