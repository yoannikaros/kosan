import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/maintenance.dart';

class MaintenanceRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Maintenance>> getAllMaintenances() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('maintenance');
    return List.generate(maps.length, (i) => Maintenance.fromMap(maps[i]));
  }

  Future<Maintenance?> getMaintenanceById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Maintenance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertMaintenance(Maintenance maintenance) async {
    final db = await dbHelper.database;
    return await db.insert('maintenance', maintenance.toMap());
  }

  Future<int> updateMaintenance(Maintenance maintenance) async {
    final db = await dbHelper.database;
    return await db.update(
      'maintenance',
      maintenance.toMap(),
      where: 'id = ?',
      whereArgs: [maintenance.id],
    );
  }

  Future<int> deleteMaintenance(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Maintenance>> getMaintenanceByRoomId(int roomId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'maintenance',
      'room_id = ?',
      [roomId],
    );
    return List.generate(maps.length, (i) {
      return Maintenance.fromMap(maps[i]);
    });
  }
}
