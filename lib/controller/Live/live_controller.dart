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
          duration: Duration(seconds: 3)
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
    }
    kwData.value = dataList.map((e) => {
      'name': e['name'],
      'time': e['time'],
      'value': e['value'],
    }).toList();
    print("Loaded data from DB: ${kwData.value}");
  }

  Future<void> _saveDataToDB(List<Map<String, dynamic>> data) async {
    final db = await DatabaseHelper.instance.database;
    for (var entry in data) {
      int id = await db.insert('kw_table', {
        'name': entry['name'],
        'time': entry['time'],
        'value': entry['value']
      });
      print("Saved data with ID $id");
    }
  }

  Future<void> fetchDataforlive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
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
          data.forEach((key, values) {
            if (key.endsWith('_[kW]') && values is List && index < values.length) {
              double value = 0.0;
              if (values[index] != null && values[index].toString() != 'NA') {
                value = double.tryParse(values[index].toString()) ?? 0.0;
              }
              kwData.add({
                'name': key,
                'time': timeKey,
                'value': value
              });
            }
          });
          await _saveDataToDB(kwData);

          update();
        }
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
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
    return await openDatabase(path, version: 1, onCreate: _createDB);
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

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}




// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:highcharts_demo/screens/login.dart';
// import 'package:highcharts_demo/screens/summary.dart';
// import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
//
// class LiveDataControllers extends GetxController {
//   RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
//   Map<String, Map<String, double>> dailyItemSumsMap = {};
//   RxBool showPassword = false.obs;
//   RxDouble lastMainKWValue = 0.0.obs;
//   RxBool loading = false.obs;
//   final usernamenameController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   var username = ''.obs;
//   var password = ''.obs;
//
//   Map<String, double> nameAndSumMap = {};
//   final int pakistaniTimeZoneOffset = 10;
//
//   RxString startDate = '2024-01-07'.obs;
//   RxString endDate = '2024-01-07'.obs;
//   RxList<String> result = <String>['0', '0', '0'].obs; // Initialize with zeroes
//
//
//
//
//
//
//   Future<void> fetchDataforlive() async  {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? storedUsername = prefs.getString('username');
//     kwData.clear();
//     final username = usernamenameController.text.toString();
//
//     try {
//       // Get current date in Pakistani time
//       DateTime currentDate = DateTime.now();
//       DateTime pakistaniDateTime = currentDate.toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
//
//       // Calculate starting date (last 24 hours)
//       DateTime startDate = pakistaniDateTime.subtract(Duration(hours: 24));
//
//       // Format dates for the API request
//       String formattedStartDate = startDate.toIso8601String().split('T')[0];
//       String formattedEndDate = pakistaniDateTime.toIso8601String().split('T')[0];
//
//       try {
//         final String apiUrl =
//             "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedStartDate&end=$formattedEndDate";
//         final response = await http.get(Uri.parse(apiUrl));
//         print(apiUrl);
//
//         if (response.statusCode == 200) {
//           Map<String, dynamic> jsonData = json.decode(response.body);
//           Map<String, dynamic> data = jsonData['data'];
//
//           List<Map<String, dynamic>> newData = [];
//           data.forEach((itemName, values) {
//             if (itemName.endsWith("[kW]")) {
//               String prefixName = getMainPart(itemName);
//               List<double> numericValues =
//               (values as List<dynamic>).map((value) {
//                 if (value is num) {
//                   return value.toDouble();
//                 } else if (value is String) {
//                   return double.tryParse(value) ?? 0.0;
//                 } else {
//                   return 0.0;
//                 }
//               }).toList();
//
//               // Take the mean of the last 5 values
//               double meanValue = 0.0;
//               int count = 0;
//               for (int i = numericValues.length - 1; i >= 0 && count < 5; i--) {
//                 meanValue += numericValues[i];
//                 count++;
//               }
//               meanValue /= count;
//
//               newData.add({
//                 'prefixName': prefixName,
//                 'values': numericValues,
//                 'lastIndexValue': meanValue,
//               });
//             }
//           });
//
//           kwData.add({'date': formattedEndDate, 'data': newData});
//         } else {
//           print(
//               'Failed to fetch data for $formattedEndDate. Status code: ${response.statusCode}');
//           print('Response body: ${response.body}');
//         }
//       } catch (error) {
//         print('Error fetching data for $formattedEndDate: $error');
//       }
//     } catch (error) {
//       print('An unexpected error occurred: $error');
//     }
//   }
//
//
//
//   String formatToKW(double value) {
//     double valueInKW = value / 1000.0;
//     return valueInKW.toStringAsFixed(3) + ' k';
//   }
//
//
//   String getMainPart(String fullName) {
//     List<String> parts = fullName.split('_');
//     if (parts.isNotEmpty) {
//       return parts.first;
//     }
//     return fullName;
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// }
