import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelperForLiveColoum {
  static final DatabaseHelperForLiveColoum _instance = DatabaseHelperForLiveColoum._internal();
  factory DatabaseHelperForLiveColoum() => _instance;

  DatabaseHelperForLiveColoum._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE chart_data(id INTEGER PRIMARY KEY, data TEXT)',
        );
      },
    );
  }

  Future<void> insertChartData(String data) async {
    final db = await database;
    await db.insert('chart_data', {'data': data});
  }

  Future<String?> getChartData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chart_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String;
    }
    return null;
  }

  Future<void> clearChartData() async {
    final db = await database;
    await db.delete('chart_data');
  }
}

