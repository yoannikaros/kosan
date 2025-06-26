import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/payment.dart';

class PaymentRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertPayment(Payment payment) async {
    return await dbHelper.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getAllPayments() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('payments');
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<List<Payment>> getPaymentsByRentalId(int rentalId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'payments',
      'rental_id = ?',
      [rentalId],
    );
    return List.generate(maps.length, (i) {
      return Payment.fromMap(maps[i]);
    });
  }

  Future<Payment?> getPaymentById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'payments',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Payment.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePayment(Payment payment) async {
    return await dbHelper.update(
      'payments',
      payment.toMap(),
      'id = ?',
      [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    return await dbHelper.delete(
      'payments',
      'id = ?',
      [id],
    );
  }
}
