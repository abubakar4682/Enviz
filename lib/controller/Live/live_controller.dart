import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LiveDataControllers extends GetxController {
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  final int pakistaniTimeZoneOffset = 5;  // Assuming PKT is UTC+5
  RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDataforlives();
  }

  Future<void> fetchDataforlives() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      isOnline.value = false;
      Get.snackbar(
        "Offline Mode",
        "Kindly connect your mobile to the internet.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      await _loadDataFromDB();
    } else {
      isOnline.value = true;
      await fetchDataforlive();
    }
  }

  Future<void> _loadDataFromDB() async {
    final db = await DatabaseHelper.instance.database;
    final dataList = await db.query('kw_table');
    if (dataList.isEmpty) {
      print("No data found in local database.");
    } else {
      kwData.value = dataList.map((e) => {
        'name': e['name'],
        'time': e['time'],
        'value': e['value'],
      }).toList();
      print("Loaded data from DB: ${kwData.value}");
    }
  }

  Future<void> _saveDataToDB(List<Map<String, dynamic>> data) async {
    final db = await DatabaseHelper.instance.database;
    for (var entry in data) {
      await db.insert(
        'kw_table',
        {
          'name': entry['name'],
          'time': entry['time'],
          'value': entry['value'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    print("Data saved to DB");
  }

  Future<void> fetchDataforlive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      print('Username not found in shared preferences');
      return;
    }

    DateTime now = DateTime.now().toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
    String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    String apiUrl = "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        Map<String, dynamic> data = jsonData['data'];
        List<dynamic> timeData = data['Date & Time'];
        int hour = now.hour;
        String timeKey = "$formattedDate ${hour.toString().padLeft(2, '0')}:00:00";
        int index = timeData.indexOf(timeKey);

        if (index != -1) {
          List<Map<String, dynamic>> fetchedData = [];
          data.forEach((key, values) {
            if (key.endsWith('_[kW]') && values is List && index < values.length) {
              double value = 0.0;
              if (values[index] != null && values[index].toString() != 'NA') {
                value = double.tryParse(values[index].toString()) ?? 0.0;
              }
              fetchedData.add({
                'name': key,
                'time': timeKey,
                'value': value,
              });
            }
          });
          kwData.value = fetchedData;
          await _saveDataToDB(fetchedData);
        }
        update();
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> cleardb() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear shared preferences
    await DatabaseHelper.instance.clearDatabase();  // Clear database
    kwData.clear();  // Clear in-memory data
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('livedata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE kw_table (
        id $idType,
        name $textType,
        time $textType,
        value $doubleType
      )
    ''');
  }

  Future<void> clearDatabase() async {
    final db = await instance.database;
    await db.delete('kw_table');  // Clear all data from the table
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
