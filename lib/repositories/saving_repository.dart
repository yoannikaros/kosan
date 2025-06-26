import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/saving.dart';

class SavingRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Saving>> getAllSavings() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('savings');
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<int> insertSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.insert('savings', saving.toMap());
  }

  Future<int> updateSaving(Saving saving) async {
    final db = await dbHelper.database;
    return await db.update(
      'savings',
      saving.toMap(),
      where: 'id = ?',
      whereArgs: [saving.id],
    );
  }

  Future<int> deleteSaving(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Saving>> getSavingsByOwnerId(int ownerId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<List<Saving>> getSavingsByType(int ownerId, String type) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'savings',
      'owner_id = ? AND type = ?',
      [ownerId, type],
    );
    return List.generate(maps.length, (i) {
      return Saving.fromMap(maps[i]);
    });
  }

  Future<Saving?> getSavingById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'savings',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Saving.fromMap(maps.first);
    }
    return null;
  }
}
