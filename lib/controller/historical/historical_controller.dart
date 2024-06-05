import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/area_chart_helper_func.dart';
import '../../database/db_helper_min_max.dart';
import '../../database/heat_map_helper.dart';

class HistoricalController extends GetxController {
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  var chartData = ''.obs;
  var isLoading = true.obs;
  RxMap<String, dynamic>? firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic>? secondApiData = <String, dynamic>{}.obs;

  RxList<String> result = <String>['0', '0', '0'].obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  final DatabaseHelperForAreaChart dbHelper = DatabaseHelperForAreaChart();
  final DatabaseHelperForMinMax _databaseHelper = DatabaseHelperForMinMax();
  @override
  void onInit() {
    checkInitialData();
    updateDateRange();
  // fetchMainKWData();
    super.onInit();
  }
 void updateDateRange() {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    // Format dates to a string in 'yyyy-MM-dd' format
    startDate.value = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    endDate.value = DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {

      endDate(picked.toLocal().toString().split(' ')[0]);
      await fetchSecondApiData();
      fetchMainKWData();
      // kwData.clear();
      fetchData();
    }
  }
  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      startDate(picked.toLocal().toString().split(' ')[0]);
      kwData.clear();
    }
  }
  String getChartData() {
    List<Map<String, dynamic>> seriesData = [];
    kwData.forEach((item) {
      String prefixName = item['prefixName'].replaceAll('_', '');
      if (prefixName == 'Main') {
        prefixName = 'Usage';
      }
      List<double> values = item['values'];
      List<List<dynamic>> dataForSeries = [];
      DateTime startDate = DateTime.parse(this.startDate.value);
      DateTime endDate = DateTime.parse(this.endDate.value);
      int numberOfHours = endDate.difference(startDate).inHours;

      for (int i = 0; i <= numberOfHours; i++) {
        DateTime dateTime = startDate.add(Duration(hours: i));
        DateTime pakistaniDateTime = dateTime.toUtc().add(Duration(hours: 5));
        if (dateTime.isAfter(startDate) && dateTime.isBefore(endDate)) {
          if (i < values.length) {
            dataForSeries.add([
              _getEpochMillis(pakistaniDateTime),
              values[i],
            ]);
          }
        }
      }

      seriesData.add({
        'name': prefixName,
        'data': dataForSeries,
        'visible': prefixName == 'Usage',
      });
    });

    return jsonEncode(seriesData);
  }


  int _getEpochMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  Future<void> fetchFirstApiDataforheatmap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    try {
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        firstApiData!.value = responseData;
        await DatabaseHelper.insertFirstApiData(json.encode(responseData));
        print("First API data fetched and stored locally.");
      } else {
        throw Exception('Failed to load data from the first API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching first API data: $e");
      String? localFirstApiData = await DatabaseHelper.getFirstApiData();
      if (localFirstApiData != null) {
        firstApiData!.value = json.decode(localFirstApiData);
        print("Loaded first API data from local storage.");
      } else {
        print("No first API data available in local storage.");
        Get.snackbar("Error", "Failed to fetch data and no local data available.");
      }
    }
  }

  // void checkDataAvailability() async {
  //   isLoading(true);
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? storedUsername = prefs.getString('username');
  //     // Assuming you have a user or a mechanism to select the current username dynamically
  //     // Replace with actual dynamic username if needed
  //     final url = Uri.parse(
  //         'http://203.135.63.47:8000/buildingmap?username=$storedUsername');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       fetchMainKWData();
  //     } else {
  //       print(
  //           'Failed to check data availability. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('An error occurred while checking data availability: $e');
  //   } finally {
  //     isLoading(false);
  //   }
  // }

  // Method to fetch and process data for heatmap chart visualization
  Future<void> fetchMainKWData() async {
    isLoading(true);
    await ensureTablesExist();
    await fetchFirstApiDataforheatmap();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("No internet connection. Checking local data.");
      await loadLocalData();
    } else {
      print("Internet connection available. Fetching data from the internet.");
      await fetchDataFromInternet();
    }
    isLoading(false);
  }

  Future<void> ensureTablesExist() async {
    final db = await DatabaseHelper.database;
    await db.execute('CREATE TABLE IF NOT EXISTS Data(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS FirstApiData(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)');
    print("Tables checked/created.");
  }
  // void fetchMainKWData() async {
  //   isLoading(true);
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.none) {
  //     // No internet connection
  //     String? localData = await DatabaseHelper.getData();
  //     if (localData != null) {
  //       chartData.value = localData;
  //       Get.snackbar(
  //           "Offline Mode",
  //           "Showing local data. Connect to the internet to get the latest updates.",
  //           snackPosition: SnackPosition.BOTTOM,
  //           duration: Duration(seconds: 8)
  //       );
  //     } else {
  //       print("No local data available.");
  //       Get.snackbar("Offline", "No local data available. Please check your internet connection.");
  //       chartData.value = '';
  //     }
  //   } else {
  //     // There is internet connection
  //     fetchDataFromInternet();
  //   }
  //   isLoading(false);
  // }
  Future<void> fetchDataFromInternet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    try {
      final url = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        await processDataAndSave(data);
        print("Data fetched from the internet and processed.");
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching data from internet: $e");
      await loadLocalData();
    }
  }
  Future<void> loadLocalData() async {
    String? localData = await DatabaseHelper.getData();
    if (localData != null) {
      chartData.value = localData;
      Get.snackbar(
          "Offline Mode",
          "Showing local data. Connect to the internet to get the latest updates.",
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 8)
      );
      print("Loaded chart data from local storage.");
    } else {
      chartData.value = '';
      Get.snackbar("Offline", "No local data available. Please check your internet connection.");
      print("No local data available.");
    }
  }
  // void fetchDataFromInternet() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     String? storedUsername = prefs.getString('username');
  //     final url = Uri.parse(
  //         'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}');
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body)['data'];
  //       await _processDataAndSave(data); // Process and save data
  //     } else {
  //       throw Exception('Failed to load data. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('An error occurred while fetching data from internet: $e');
  //     String? localData = await DatabaseHelper.getData();
  //     if (localData != null) {
  //       chartData.value = localData;
  //     } else {
  //       Get.snackbar("Error", "Failed to fetch data and no local data available.");
  //     }
  //   }
  // }
  Future<void> processDataAndSave(Map<String, dynamic> data) async {
    List<dynamic> mainKWList;

    if (data.containsKey('Main_[kW]')) {
      mainKWList = data['Main_[kW]'];
    } else {
      List<String> dynamicKeys = firstApiData!.keys
          .map((key) => '${key}_[kW]')
          .toList();

      List<dynamic> validDataLists = dynamicKeys
          .where((key) => data.containsKey(key))
          .map((key) => data[key])
          .toList();

      if (validDataLists.isEmpty) {
        Get.snackbar("Data Error", "Required data keys are missing.");
        mainKWList = List.empty();
      } else {
        mainKWList = List.generate(validDataLists.first.length, (index) => 0.0);

        for (var dataList in validDataLists) {
          for (int i = 0; i < dataList.length; i++) {
            double value = double.tryParse(dataList[i].toString()) ?? 0.0;
            mainKWList[i] += value;
          }
        }
      }
    }

    if (mainKWList.isNotEmpty) {
      List<List<dynamic>> chunks = [];
      for (int i = 0; i < mainKWList.length; i += 24) {
        chunks.add(mainKWList.sublist(i, i + 24 > mainKWList.length ? mainKWList.length : i + 24));
      }

      List<String> xyValues = [];
      for (int day = 0; day < chunks.length; day++) {
        for (int hour = 0; hour < chunks[day].length; hour++) {
          double value = (chunks[day][hour] == null || chunks[day][hour] == "NA") ? 0.0 : double.parse(chunks[day][hour].toString());
          xyValues.add('{"x": $day, "y": $hour, "value": $value}');
        }
      }

      String jsonData = '[${xyValues.join(",")}]';
      chartData.value = jsonData;
      await DatabaseHelper.insertData(jsonData);
      print("Processed data saved locally.");
    } else {
      print("No valid data found to process.");
    }
  }

//   Future<void> _processDataAndSave(Map<String, dynamic> data) async {
//     List<dynamic> mainKWList;
//
//     if (data.containsKey('Main_[kW]')) {
//       mainKWList = data['Main_[kW]'];
//     } else {
//       List<dynamic> firstFloorList = data['1st Floor_[kW]'];
//       List<dynamic> groundFloorList = data['Ground Floor_[kW]'];
//       mainKWList = List.generate(
//           firstFloorList.length, (index) => 0.0); // Initialize with zeroes
//
//       for (int i = 0; i < firstFloorList.length; i++) {
//         // Sum the values index-wise from both keys
//         double firstFloorValue =
//             double.tryParse(firstFloorList[i].toString()) ?? 0.0;
//         double groundFloorValue =
//             double.tryParse(groundFloorList[i].toString()) ?? 0.0;
//         mainKWList[i] = firstFloorValue + groundFloorValue;
//       }
//     }
// //haruto
//     // Process the data for visualization
//     List<List<dynamic>> chunks = [];
//     for (int i = 0; i < mainKWList.length; i += 24) {
//       chunks.add(mainKWList.sublist(
//           i, i + 24 > mainKWList.length ? mainKWList.length : i + 24));
//     }
//
//     List<String> xyValues = [];
//     for (int day = 0; day < chunks.length; day++) {
//       for (int hour = 0; hour < chunks[day].length; hour++) {
//         double value =
//         (chunks[day][hour] == null || chunks[day][hour] == "NA")
//             ? 0.0
//             : double.parse(chunks[day][hour].toString());
//         xyValues.add('{"x": $day, "y": $hour, "value": $value}');
//       }
//     }
//
//     String jsonData = '[${xyValues.join(",")}]';
//     chartData.value = jsonData;
//     await DatabaseHelper.insertData(jsonData); // Store processed data in local database
//     // String jsonData = jsonEncode(mainKWList);
//     // chartData.value = jsonData;
//     // await DatabaseHelper.insertData(jsonData);
//   }
  Future<void> checkInitialData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      await loadOfflineData();
    } else {
      await fetchFirstApiData();
      await fetchSecondApiData();
    }
  }
  Future<void> loadOfflineData() async {
    isLoading.value = true;
    final storedFirstApiData = await _databaseHelper.getFirstApiData();
    final storedSecondApiData = await _databaseHelper.getSecondApiData();

    if (storedFirstApiData.isNotEmpty) {
      firstApiData!.value = storedFirstApiData.map((key, value) => MapEntry(key, json.decode(value)));
    }
    if (storedSecondApiData.isNotEmpty) {
      secondApiData!.value = storedSecondApiData.map((key, value) => MapEntry(key, json.decode(value)));
    }
    isLoading.value = false;
  }



  Future<void> fetchFirstApiData() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    try {
      final response = await http.get(Uri.parse(
          'http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        firstApiData!.value = responseData;

        // Store data in SQLite
        responseData.forEach((key, value) async {
          await _databaseHelper.insertFirstApiData(key, json.encode(value));
        });
      } else {
        throw Exception('Failed to load data from the first API');
      }
    } catch (e) {
      // Handle error (optionally log the error)
    }
    isLoading.value = false;
  }


  Future<void> fetchSecondApiData() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    try {
      final response = await http.get(Uri.parse(
          'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> secondApiResponse = json.decode(response.body);
        final Map<String, dynamic> filteredData = {};

        secondApiResponse['data'].forEach((key, value) {
          if (value.isEmpty) {
            filteredData[key] = List<double>.filled(24, 0.0);
          } else {
            filteredData[key] = value.map<double>((v) => parseDouble(v)).toList();
          }
        });

        secondApiData!.value = filteredData;

        // Store data in SQLite
        filteredData.forEach((key, value) async {
          await _databaseHelper.insertSecondApiData(key, json.encode(value));
        });
      } else {
        throw Exception('Failed to load data from the second API');
      }
    } catch (e) {
      // Handle error (optionally log the error)
    }
    isLoading.value = false;
  }




  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final String appuril =
          'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}';
      final response = await http.get(Uri.parse(appuril));

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = json.decode(response.body);
        Map<String, dynamic> data = jsonData['data'];

        data.forEach((itemName, values) {
          if (itemName.endsWith("[kW]")) {
            String prefixName = itemName.substring(0, itemName.length - 4);
            List<double> numericValues =
            (values as List<dynamic>).map((value) {
              if (value is num) {
                return value.toDouble() / 1000.0;
              } else if (value is String) {
                return (double.tryParse(value) ?? 0.0) / 1000.0;
              } else {
                return 0.0;
              }
            }).toList();

            kwData.add({'prefixName': prefixName, 'values': numericValues});
            dbHelper.insertKwData(prefixName, numericValues); // Store data locally
          }
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
        _loadDataFromLocalDb(); // Load data from local database if fetch fails
      }
    } catch (error) {
      print('An unexpected error occurred: $error');
      _loadDataFromLocalDb(); // Load data from local database if an error occurs
    }
  }
  Future<void> _loadDataFromLocalDb() async {
    List<Map<String, dynamic>> localData = await dbHelper.getKwData();
    kwData.clear();
    localData.forEach((item) {
      List<double> values = (item['dataValues'] as String)
          .split(',')
          .map((value) => double.tryParse(value) ?? 0.0)
          .toList();
      kwData.add({'prefixName': item['prefixName'], 'values': values});
    });
  }


  void resetController() {
    // Reset to initial end date
    firstApiData!.value = <String, dynamic>{}; // Clear the data
    secondApiData!.value = <String, dynamic>{}; // Clear the data
    result.value = <String>['0', '0', '0']; // Reset the result
    kwData.clear(); // Clear the kW data list
  }

  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double calculateTotalSum(List<double> sums) =>
      sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) =>
      sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) =>
      sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) => sums.isEmpty
      ? 0.0
      : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) => value >= 1000
      ? '${(value / 1000).toStringAsFixed(2)}kW'
      : '${(value / 1000).toStringAsFixed(2)}kW';

  String formatValued(double value) => (value / 1000).toStringAsFixed(2); //
  // Add this method in HistoricalController
  double getLastIndexValue(List<double> values) {
    // Check if the list is empty to avoid errors
    if (values.isNotEmpty) {
      return values.last;
    }
    // Return 0.0 or an appropriate default value if the list is empty
    return 0.0;
  }
}

