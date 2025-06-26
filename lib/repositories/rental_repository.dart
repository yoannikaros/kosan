import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/rental.dart';

class RentalRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertRental(Rental rental) async {
    return await dbHelper.insert('rentals', rental.toMap());
  }

  Future<List<Rental>> getAllRentals() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('rentals');
    return List.generate(maps.length, (i) {
      return Rental.fromMap(maps[i]);
    });
  }

  Future<List<Rental>> getActiveRentals() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rentals',
      'status = ?',
      ['active'],
    );
    return List.generate(maps.length, (i) {
      return Rental.fromMap(maps[i]);
    });
  }

  Future<List<Rental>> getRentalsByTenantId(int tenantId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rentals',
      'tenant_id = ?',
      [tenantId],
    );
    return List.generate(maps.length, (i) {
      return Rental.fromMap(maps[i]);
    });
  }

  Future<List<Rental>> getRentalsByRoomId(int roomId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rentals',
      'room_id = ?',
      [roomId],
    );
    return List.generate(maps.length, (i) {
      return Rental.fromMap(maps[i]);
    });
  }

  Future<Rental?> getRentalById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rentals',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Rental.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRental(Rental rental) async {
    return await dbHelper.update(
      'rentals',
      rental.toMap(),
      'id = ?',
      [rental.id],
    );
  }

  Future<int> updateRentalStatus(int id, String status) async {
    return await dbHelper.update(
      'rentals',
      {'status': status},
      'id = ?',
      [id],
    );
  }

  Future<int> deleteRental(int id) async {
    return await dbHelper.delete(
      'rentals',
      'id = ?',
      [id],
    );
  }
}
