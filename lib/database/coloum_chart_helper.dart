import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//helperfunction for coulum
class DatabaseHelperForWeek {
  static final DatabaseHelperForWeek _instance = DatabaseHelperForWeek._internal();
  factory DatabaseHelperForWeek() => _instance;

  DatabaseHelperForWeek._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_data_week.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE week_chart_data(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)',
        );
      },
    );
  }

  Future<void> insertChartData(String data) async {
    final db = await database;
    await db.insert('week_chart_data', {'data': data});
  }

  Future<String?> getChartData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('week_chart_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String;
    }
    return null;
  }

  Future<void> clearChartData() async {
    final db = await database;
    await db.delete('week_chart_data');
  }
}
