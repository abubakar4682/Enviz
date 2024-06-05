import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseServiceForPieForMonth {
  static final DatabaseServiceForPieForMonth _instance = DatabaseServiceForPieForMonth._internal();
  factory DatabaseServiceForPieForMonth() => _instance;
  static Database? _database;

  DatabaseServiceForPieForMonth._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pie_chart_data.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE PieChartData (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertPieChartData(String data) async {
    final db = await database;
    await db.insert(
      'PieChartData',
      {'data': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPieChartData() async {
    final db = await database;
    final result = await db.query('PieChartData', limit: 1);
    if (result.isNotEmpty) {
      return result.first['data'] as String;
    }
    return null;
  }

  Future<void> clearPieChartData() async {
    final db = await database;
    await db.delete('PieChartData');
  }
}
