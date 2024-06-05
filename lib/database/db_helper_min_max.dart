import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';






class DatabaseHelperForMinMax {
  static final DatabaseHelperForMinMax _instance = DatabaseHelperForMinMax._internal();
  factory DatabaseHelperForMinMax() => _instance;
  DatabaseHelperForMinMax._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'api_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE firstApiData (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE secondApiData (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> insertFirstApiData(String key, String value) async {
    final db = await database;
    await db.insert(
      'firstApiData',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSecondApiData(String key, String value) async {
    final db = await database;
    await db.insert(
      'secondApiData',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getFirstApiData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('firstApiData');
    return Map.fromIterable(maps, key: (e) => e['key'], value: (e) => e['value']);
  }

  Future<Map<String, String>> getSecondApiData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('secondApiData');
    return Map.fromIterable(maps, key: (e) => e['key'], value: (e) => e['value']);
  }
}
