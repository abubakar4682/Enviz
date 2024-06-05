import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';


class DatabaseHelperForHistoricalMinMAxAndAvg {
  static final DatabaseHelperForHistoricalMinMAxAndAvg _instance = DatabaseHelperForHistoricalMinMAxAndAvg._internal();
  static Database? _database;

  factory DatabaseHelperForHistoricalMinMAxAndAvg() => _instance;

  DatabaseHelperForHistoricalMinMAxAndAvg._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE firstApiData (
            id INTEGER PRIMARY KEY,
            key TEXT,
            value TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE secondApiData (
            id INTEGER PRIMARY KEY,
            key TEXT,
            value TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    final db = await database;
    data.forEach((key, value) async {
      await db.insert(
        table,
        {'key': key, 'value': value.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<Map<String, dynamic>> getData(String table) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(table);
    return Map.fromIterable(maps, key: (item) => item['key'], value: (item) => item['value']);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }
}
