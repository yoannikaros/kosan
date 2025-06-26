import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/transaction.dart';

class TransactionRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertTransaction(Transaction transaction) async {
    return await dbHelper.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('transactions');
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<List<Transaction>> getTransactionsByOwnerId(int ownerId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'transactions',
      'owner_id = ?',
      [ownerId],
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<List<Transaction>> getTransactionsByType(int ownerId, String type) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'transactions',
      'owner_id = ? AND type = ?',
      [ownerId, type],
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<Transaction?> getTransactionById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'transactions',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Transaction.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    return await dbHelper.update(
      'transactions',
      transaction.toMap(),
      'id = ?',
      [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    return await dbHelper.delete(
      'transactions',
      'id = ?',
      [id],
    );
  }
}
