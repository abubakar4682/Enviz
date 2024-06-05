import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'analytics_database.db');
    return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE firstApiData(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT
          )
        ''');
          await db.execute('''
          CREATE TABLE secondApiData(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keys TEXT,
            data TEXT
          )
        ''');
        },
        onOpen: (db) async {
          // Ensure tables are created
          await db.execute('''
          CREATE TABLE IF NOT EXISTS firstApiData(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT
          )
        ''');
          await db.execute('''
          CREATE TABLE IF NOT EXISTS secondApiData(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            keys TEXT,
            data TEXT
          )
        ''');
        }
    );
  }

  Future<void> insertFirstApiData(String jsonData) async {
    final db = await database;
    await db.insert(
      'firstApiData',
      {'data': jsonData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertSecondApiData(List<String> keys, String jsonData) async {
    final db = await database;
    String keysString = jsonEncode(keys);
    await db.insert(
      'secondApiData',
      {'keys': keysString, 'data': jsonData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFirstApiData() async {
    final db = await database;
    return db.query('firstApiData');
  }

  Future<List<Map<String, dynamic>>> getSecondApiData(List<String> keys) async {
    final db = await database;
    String keysString = jsonEncode(keys);
    return db.query(
      'secondApiData',
      where: 'keys = ?',
      whereArgs: [keysString],
    );
  }
}
