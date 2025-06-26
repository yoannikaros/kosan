import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/owner.dart';

class OwnerRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertOwner(Owner owner) async {
    return await dbHelper.insert('owners', owner.toMap());
  }

  Future<List<Owner>> getAllOwners() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('owners');
    return List.generate(maps.length, (i) {
      return Owner.fromMap(maps[i]);
    });
  }

  Future<Owner?> getOwnerById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'owners',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Owner.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateOwner(Owner owner) async {
    return await dbHelper.update(
      'owners',
      owner.toMap(),
      'id = ?',
      [owner.id],
    );
  }

  Future<int> deleteOwner(int id) async {
    return await dbHelper.delete(
      'owners',
      'id = ?',
      [id],
    );
  }
}
