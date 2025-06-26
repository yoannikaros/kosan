import 'package:kosan/helpers/database_helper.dart';
import 'package:kosan/models/tenant.dart';

class TenantRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insertTenant(Tenant tenant) async {
    return await dbHelper.insert('tenants', tenant.toMap());
  }

  Future<List<Tenant>> getAllTenants() async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryAllRows('tenants');
    return List.generate(maps.length, (i) {
      return Tenant.fromMap(maps[i]);
    });
  }

  Future<Tenant?> getTenantById(int id) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'tenants',
      'id = ?',
      [id],
    );
    if (maps.isNotEmpty) {
      return Tenant.fromMap(maps.first);
    }
    return null;
  }

  Future<Tenant?> getTenantByUserId(int userId) async {
    final List<Map<String, dynamic>> maps = await dbHelper.queryWhere(
      'tenants',
      'user_id = ?',
      [userId],
    );
    if (maps.isNotEmpty) {
      return Tenant.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTenant(Tenant tenant) async {
    return await dbHelper.update(
      'tenants',
      tenant.toMap(),
      'id = ?',
      [tenant.id],
    );
  }

  Future<int> deleteTenant(int id) async {
    return await dbHelper.delete(
      'tenants',
      'id = ?',
      [id],
    );
  }
}
