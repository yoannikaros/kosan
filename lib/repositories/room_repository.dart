import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/room.dart';

class RoomRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertRoom(Room room) async {
    return await dbHelper.insert('rooms', room.toMap());
  }

  Future<List<Room>> getAllRooms() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('rooms');
    return List.generate(maps.length, (i) {
      return Room.fromMap(maps[i]);
    });
  }

  Future<List<Room>> getAvailableRooms() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rooms',
      'status = ?',
      ['available'],
    );
    return List.generate(maps.length, (i) {
      return Room.fromMap(maps[i]);
    });
  }

  Future<Room?> getRoomById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'rooms',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Room.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateRoom(Room room) async {
    return await dbHelper.update(
      'rooms',
      room.toMap(),
      'id = ?',
      [room.id],
    );
  }

  Future<int> updateRoomStatus(int id, String status) async {
    return await dbHelper.update(
      'rooms',
      {'status': status},
      'id = ?',
      [id],
    );
  }

  Future<int> deleteRoom(int id) async {
    return await dbHelper.delete(
      'rooms',
      'id = ?',
      [id],
    );
  }
}
