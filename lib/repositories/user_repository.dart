import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/user.dart';

class UserRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertUser(User user) async {
    return await dbHelper.insert('users', user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  Future<User?> getUserById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'users',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByUsername(String username) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'users',
      'username = ?',
      [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> login(String username, String password) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'users',
      'username = ? AND password = ?',
      [username, password],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    return await dbHelper.update(
      'users',
      user.toMap(),
      'id = ?',
      [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    return await dbHelper.delete(
      'users',
      'id = ?',
      [id],
    );
  }
}
