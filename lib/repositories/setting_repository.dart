import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/setting.dart';

class SettingRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertSetting(Setting setting) async {
    return await dbHelper.insert('settings', setting.toMap());
  }

  Future<Setting?> getSettingByOwnerId(int ownerId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'settings',
      'owner_id = ?',
      [ownerId],
    );
    if (maps.isNotEmpty) {
      return Setting.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSetting(Setting setting) async {
    final existingSetting = await getSettingByOwnerId(setting.ownerId);
    if (existingSetting != null) {
      return await dbHelper.update(
        'settings',
        setting.toMap(),
        'id = ?',
        [existingSetting.id],
      );
    } else {
      return await insertSetting(setting);
    }
  }
}
