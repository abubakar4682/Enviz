import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'summary_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('CREATE TABLE first_api_data(id INTEGER PRIMARY KEY, data TEXT)');
        db.execute('CREATE TABLE second_api_data(id INTEGER PRIMARY KEY, data TEXT)');
      },
    );
  }

  Future<void> insertFirstApiData(String data) async {
    final db = await database;
    await db.insert('first_api_data', {'data': data});
  }

  Future<void> insertSecondApiData(String data) async {
    final db = await database;
    await db.insert('second_api_data', {'data': data});
  }

  Future<String?> getFirstApiData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('first_api_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String;
    }
    return null;
  }

  Future<String?> getSecondApiData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('second_api_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String;
    }
    return null;
  }

  Future<void> clearFirstApiData() async {
    final db = await database;
    await db.delete('first_api_data');
  }

  Future<void> clearSecondApiData() async {
    final db = await database;
    await db.delete('second_api_data');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('first_api_data');
    await db.delete('second_api_data');
  }
}
