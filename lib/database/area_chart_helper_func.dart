import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperForAreaChart {
  static final DatabaseHelperForAreaChart _instance = DatabaseHelperForAreaChart._internal();
  factory DatabaseHelperForAreaChart() => _instance;

  DatabaseHelperForAreaChart._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kw_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kw_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prefixName TEXT,
            dataValues TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertKwData(String prefixName, List<double> values) async {
    final db = await database;
    await db.insert(
      'kw_data',
      {'prefixName': prefixName, 'dataValues': values.join(',')},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getKwData() async {
    final db = await database;
    return await db.query('kw_data');
  }

  Future<void> clearKwData() async {
    final db = await database;
    await db.delete('kw_data');
  }
}
