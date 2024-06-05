// lib/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  static Database? _database;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'org_chart.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE OrgChart(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)',
        );
      },
    );
  }

  Future<void> insertData(String data) async {
    final db = await database;
    await db.insert(
      'OrgChart',
      {'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> fetchData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('OrgChart', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'];
    }
    return null;
  }
}
