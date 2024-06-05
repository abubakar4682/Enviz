import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'app_data.db');
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE IF NOT EXISTS Data(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)'
        );
        await db.execute(
            'CREATE TABLE IF NOT EXISTS FirstApiData(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)'
        );
      },
    );
    return db;
  }

  static Future<void> insertData(String data) async {
    final db = await database;
    try {
      int id = await db.insert(
          'Data',
          {'data': data},
          conflictAlgorithm: ConflictAlgorithm.replace
      );
      print("Data inserted with id $id");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  static Future<String?> getData() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
          'Data',
          orderBy: 'id DESC',
          limit: 1
      );
      if (results.isNotEmpty) {
        print("Data retrieved: ${results.first['data']}");
        return results.first['data'] as String;
      } else {
        print("No data found in database.");
        return null;
      }
    } catch (e) {
      print("Error retrieving data: $e");
      return null;
    }
  }

  static Future<void> insertFirstApiData(String data) async {
    final db = await database;
    try {
      int id = await db.insert(
          'FirstApiData',
          {'data': data},
          conflictAlgorithm: ConflictAlgorithm.replace
      );
      print("First API data inserted with id $id");
    } catch (e) {
      print("Error inserting first API data: $e");
    }
  }

  static Future<String?> getFirstApiData() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> results = await db.query(
          'FirstApiData',
          orderBy: 'id DESC',
          limit: 1
      );
      if (results.isNotEmpty) {
        print("First API data retrieved: ${results.first['data']}");
        return results.first['data'] as String;
      } else {
        print("No first API data found in database.");
        return null;
      }
    } catch (e) {
      print("Error retrieving first API data: $e");
      return null;
    }
  }
}
