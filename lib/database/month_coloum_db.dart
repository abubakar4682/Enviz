import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelperForMonthColoum {
  static final DatabaseHelperForMonthColoum _instance = DatabaseHelperForMonthColoum._internal();
  factory DatabaseHelperForMonthColoum() => _instance;

  DatabaseHelperForMonthColoum._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_data_month.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE month_chart_data(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)',
        );
      },
    );
  }

  Future<void> insertChartData(String data) async {
    final db = await database;
    await db.insert('month_chart_data', {'data': data});
  }

  Future<String?> getChartData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('month_chart_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String;
    }
    return null;
  }

  Future<void> clearChartData() async {
    final db = await database;
    await db.delete('month_chart_data');
  }
}
