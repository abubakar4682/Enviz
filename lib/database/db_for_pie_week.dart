import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';




class DatabaseHelperForWeekForPie {
  static final DatabaseHelperForWeekForPie _instance = DatabaseHelperForWeekForPie._internal();
  factory DatabaseHelperForWeekForPie() => _instance;
  static Database? _database;

  DatabaseHelperForWeekForPie._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'week_chart_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE chart_data (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            data TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertChartData(String data) async {
    final db = await database;
    await db.insert('chart_data', {'data': data}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getChartData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chart_data', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first['data'] as String?;
    }
    return null;
  }

  Future<void> clearChartData() async {
    final db = await database;
    await db.delete('chart_data');
  }
}