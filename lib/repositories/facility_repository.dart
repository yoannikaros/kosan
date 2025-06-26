import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/facility.dart';

class FacilityRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertFacility(Facility facility) async {
    return await dbHelper.insert('facilities', facility.toMap());
  }

  Future<List<Facility>> getAllFacilities() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('facilities');
    return List.generate(maps.length, (i) {
      return Facility.fromMap(maps[i]);
    });
  }

  Future<List<Facility>> getFacilitiesByRoomId(int roomId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'facilities',
      'room_id = ?',
      [roomId],
    );
    return List.generate(maps.length, (i) {
      return Facility.fromMap(maps[i]);
    });
  }

  Future<Facility?> getFacilityById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'facilities',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Facility.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFacility(Facility facility) async {
    return await dbHelper.update(
      'facilities',
      facility.toMap(),
      'id = ?',
      [facility.id],
    );
  }

  Future<int> deleteFacility(int id) async {
    return await dbHelper.delete(
      'facilities',
      'id = ?',
      [id],
    );
  }

  Future<int> deleteFacilitiesByRoomId(int roomId) async {
    return await dbHelper.delete(
      'facilities',
      'room_id = ?',
      [roomId],
    );
  }
}
