import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kosan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const realType = 'REAL';
    const integerType = 'INTEGER';

    // Tabel Owners (pemilik usaha)
    await db.execute('''
    CREATE TABLE owners (
      id $idType,
      name $textType NOT NULL,
      email $textType UNIQUE,
      phone $textType,
      address $textType,
      created_at $textType DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    // Tabel Users (login & register)
    await db.execute('''
    CREATE TABLE users (
      id $idType,
      owner_id $integerType,
      username $textType UNIQUE NOT NULL,
      password $textType NOT NULL,
      email $textType,
      role $textType DEFAULT 'tenant',
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (owner_id) REFERENCES owners(id)
    )
    ''');

    // Tabel Tenants (penyewa)
    await db.execute('''
    CREATE TABLE tenants (
      id $idType,
      user_id $integerType,
      name $textType NOT NULL,
      email $textType UNIQUE,
      phone $textType,
      identity_number $textType,
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
    ''');

    // Tabel Rooms (kamar kost/kontrakan)
    await db.execute('''
    CREATE TABLE rooms (
      id $idType,
      owner_id $integerType NOT NULL,
      room_number $textType NOT NULL,
      floor $integerType,
      price $realType NOT NULL,
      description $textType,
      status $textType DEFAULT 'available',
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (owner_id) REFERENCES owners(id)
    )
    ''');

    // Tabel Facilities (fasilitas kamar)
    await db.execute('''
    CREATE TABLE facilities (
      id $idType,
      room_id $integerType NOT NULL,
      facility_name $textType NOT NULL,
      description $textType,
      FOREIGN KEY (room_id) REFERENCES rooms(id)
    )
    ''');

    // Tabel Rentals (kontrak sewa)
    await db.execute('''
    CREATE TABLE rentals (
      id $idType,
      tenant_id $integerType NOT NULL,
      room_id $integerType NOT NULL,
      start_date $textType NOT NULL,
      end_date $textType NOT NULL,
      rent_price $realType NOT NULL,
      status $textType DEFAULT 'active',
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (tenant_id) REFERENCES tenants(id),
      FOREIGN KEY (room_id) REFERENCES rooms(id)
    )
    ''');

    // Tabel Payments (pembayaran sewa)
    await db.execute('''
    CREATE TABLE payments (
      id $idType,
      rental_id $integerType NOT NULL,
      payment_date $textType NOT NULL,
      amount $realType NOT NULL,
      payment_method $textType,
      note $textType,
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (rental_id) REFERENCES rentals(id)
    )
    ''');

    // Tabel Maintenance (perawatan kamar)
    await db.execute('''
    CREATE TABLE maintenance (
      id $idType,
      room_id $integerType NOT NULL,
      description $textType NOT NULL,
      cost $realType,
      maintenance_date $textType NOT NULL,
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (room_id) REFERENCES rooms(id)
    )
    ''');

    // Tabel Transactions (catatan pemasukan dan pengeluaran)
    await db.execute('''
    CREATE TABLE transactions (
      id $idType,
      owner_id $integerType NOT NULL,
      type $textType NOT NULL,
      category $textType,
      amount $realType NOT NULL,
      description $textType,
      transaction_date $textType NOT NULL,
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (owner_id) REFERENCES owners(id)
    )
    ''');

    // Tabel Savings (tabungan pemasukan dan pengeluaran)
    await db.execute('''
    CREATE TABLE savings (
      id $idType,
      owner_id $integerType NOT NULL,
      saving_date $textType NOT NULL,
      description $textType NOT NULL,
      amount $realType NOT NULL,
      target_amount $realType,
      status $textType,
      note $textType,
      created_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (owner_id) REFERENCES owners(id)
    )
    ''');

    // Tabel Settings (pengaturan nama usaha, header dan footer nota)
    await db.execute('''
    CREATE TABLE settings (
      id $idType,
      owner_id $integerType NOT NULL,
      business_name $textType,
      note_header $textType,
      note_footer $textType,
      updated_at $textType DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (owner_id) REFERENCES owners(id)
    )
    ''');

    // Tambahkan data awal untuk admin
    await db.insert('owners', {
      'name': 'Admin',
      'email': 'admin@example.com',
      'phone': '08123456789',
      'address': 'Jl. Admin No. 1'
    });

    final ownerId = await db.rawQuery('SELECT last_insert_rowid() as id');
    final int id = (ownerId.isNotEmpty && ownerId.first['id'] != null) ? ownerId.first['id'] as int : 0;

    await db.insert('users', {
      'owner_id': id,
      'username': 'admin',
      'password': 'admin123',
      'role': 'admin'
    });
  }

  // Metode umum untuk CRUD
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(String table, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.query(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> row, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.update(table, row, where: whereClause, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String whereClause, List<dynamic> whereArgs) async {
    Database db = await instance.database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String query, [List<dynamic>? arguments]) async {
    Database db = await instance.database;
    return await db.rawQuery(query, arguments);
  }

  Future<int> updateUsername(int userId, String newUsername) async {
    final db = await database;
    return await db.update(
      'users',
      {'username': newUsername},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> checkUserPassword(int userId, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, password],
    );
    return result.isNotEmpty;
  }

  Future<int> updatePassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
