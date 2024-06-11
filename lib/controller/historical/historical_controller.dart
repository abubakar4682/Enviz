import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/area_chart_helper_func.dart';
import '../../database/db_helper_min_max.dart';
import '../../database/heat_map_helper.dart';

class HistoricalController extends GetxController {
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  var chartData = ''.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;  // Added errorMessage variable
  RxMap<String, dynamic> firstApiData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> secondApiData = <String, dynamic>{}.obs;
  RxList<String> result = <String>['0', '0', '0'].obs;
  RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;

  final DatabaseHelperForAreaChart dbHelper = DatabaseHelperForAreaChart();
  final DatabaseHelperForMinMax _databaseHelper = DatabaseHelperForMinMax();
  final Logger logger = Logger();  // Initialize the logger

  @override
  void onInit() {
    super.onInit();
    updateDateRange();
    fetchData();
  }

  void updateDateRange() {
    DateTime now = DateTime.now();
    DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

    startDate.value = DateFormat('yyyy-MM-dd').format(sevenDaysAgo);
    endDate.value = DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> selectStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      startDate.value = DateFormat('yyyy-MM-dd').format(picked);
      kwData.clear();
    }
  }

  Future<void> selectEndDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      endDate.value = DateFormat('yyyy-MM-dd').format(picked);
      await fetchData();
    }
  }

  int _getEpochMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await checkInitialData();
      await fetchDataForAreaChart();
      await fetchDataForHeatmap();
    } catch (e) {
      logger.e("Error fetching data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDataForHeatmap() async {
    logger.d('Getting Data For Heatmap');

    await _fetchAndProcessHeatmapData();
  }

  Future<void> _fetchAndProcessHeatmapData() async {
    await fetchFirstApiDataForHeatmap();

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      logger.d("No internet connection. Checking local data.");
      await loadLocalData();
    } else {
      logger.d("Internet connection available. Fetching data from the internet.");
      await fetchDataFromInternet();
    }
  }

  Future<void> fetchFirstApiDataForHeatmap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    try {
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        firstApiData.value = responseData;
        await DatabaseHelper.insertFirstApiData(json.encode(responseData));
        logger.d("First API data fetched and stored locally.");
      } else {
        throw Exception('Failed to load data from the first API. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e("Error fetching first API data: $e");
      String? localFirstApiData = await DatabaseHelper.getFirstApiData();
      if (localFirstApiData != null) {
        firstApiData.value = json.decode(localFirstApiData);
        logger.d("Loaded first API data from local storage.");
      } else {
        logger.e("No first API data available in local storage.");
        Get.snackbar("Error", "Failed to fetch data and no local data available.");
      }
    }
  }

  Future<void> fetchMainKWDataForHeatMap() async {
    await ensureTablesExist();
    await fetchFirstApiDataForHeatmap();

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      logger.d("No internet connection. Checking local data.");
      await loadLocalData();
    } else {
      logger.d("Internet connection available. Fetching data from the internet.");
      await fetchDataFromInternet();
    }
  }

  Future<void> ensureTablesExist() async {
    final db = await DatabaseHelper.database;
    await db.execute('CREATE TABLE IF NOT EXISTS Data(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)');
    await db.execute('CREATE TABLE IF NOT EXISTS FirstApiData(id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT)');
    logger.d("Tables checked/created.");
  }

  Future<void> fetchDataFromInternet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    try {
      final url = Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        await processDataAndSave(data);
        logger.d("Data fetched from the internet and processed.");
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e("Error fetching data from internet: $e");
      await loadLocalData();
    }
  }

  Future<void> loadLocalData() async {
    String? localData = await DatabaseHelper.getData();
    if (localData != null) {
      chartData.value = localData;
      Get.snackbar("Offline Mode", "Showing local data. Connect to the internet to get the latest updates.", snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 8));
      logger.d("Loaded chart data from local storage.");
    } else {
      chartData.value = '';
      Get.snackbar("Offline", "No local data available. Please check your internet connection.");
      logger.e("No local data available.");
    }
  }

  Future<void> processDataAndSave(Map<String, dynamic> data) async {
    List<dynamic> mainKWList = data.containsKey('Main_[kW]') ? data['Main_[kW]'] : _getDynamicKeysData(data);

    if (mainKWList.isNotEmpty) {
      List<List<dynamic>> chunks = _chunkData(mainKWList, 24);
      String jsonData = _prepareJsonData(chunks);
      chartData.value = jsonData;
      await DatabaseHelper.insertData(jsonData);
      logger.d("Processed data saved locally.");
    } else {
      logger.e("No valid data found to process.");
    }
  }

  List<dynamic> _getDynamicKeysData(Map<String, dynamic> data) {
    List<String> dynamicKeys = firstApiData.keys.map((key) => '${key}_[kW]').toList();
    List<dynamic> validDataLists = dynamicKeys.where((key) => data.containsKey(key)).map((key) => data[key]).toList();

    if (validDataLists.isEmpty) {
      Get.snackbar("Data Error", "Required data keys are missing.");
      return [];
    } else {
      List<dynamic> mainKWList = List.generate(validDataLists.first.length, (index) => 0.0);
      for (var dataList in validDataLists) {
        for (int i = 0; i < dataList.length; i++) {
          double value = double.tryParse(dataList[i].toString()) ?? 0.0;
          mainKWList[i] += value;
        }
      }
      return mainKWList;
    }
  }

  List<List<dynamic>> _chunkData(List<dynamic> data, int chunkSize) {
    List<List<dynamic>> chunks = [];
    for (int i = 0; i < data.length; i += chunkSize) {
      chunks.add(data.sublist(i, i + chunkSize > data.length ? data.length : i + chunkSize));
    }
    return chunks;
  }

  String _prepareJsonData(List<List<dynamic>> chunks) {
    List<String> xyValues = [];
    for (int day = 0; day < chunks.length; day++) {
      for (int hour = 0; hour < chunks[day].length; hour++) {
        double value = (chunks[day][hour] == null || chunks[day][hour] == "NA") ? 0.0 : double.parse(chunks[day][hour].toString());
        xyValues.add('{"x": $day, "y": $hour, "value": $value}');
      }
    }
    return '[${xyValues.join(",")}]';
  }

  Future<void> checkInitialData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
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
      firstApiData.value = storedFirstApiData.map((key, value) => MapEntry(key, json.decode(value)));
    }
    if (storedSecondApiData.isNotEmpty) {
      secondApiData.value = storedSecondApiData.map((key, value) => MapEntry(key, json.decode(value)));
    }
    isLoading.value = false;
  }

  Future<void> fetchFirstApiData() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    try {
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        firstApiData.value = responseData;

        responseData.forEach((key, value) async {
          await _databaseHelper.insertFirstApiData(key, json.encode(value));
        });
      } else {
        throw Exception('Failed to load data from the first API');
      }
    } catch (e) {
      logger.e("Error fetching first API data: $e");
    }
    isLoading.value = false;
  }

  Future<void> fetchSecondApiData() async {
    isLoading.value = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    try {
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> secondApiResponse = json.decode(response.body);
        final Map<String, dynamic> filteredData = _filterSecondApiData(secondApiResponse['data']);

        secondApiData.value = filteredData;

        filteredData.forEach((key, value) async {
          await _databaseHelper.insertSecondApiData(key, json.encode(value));
        });
      } else {
        throw Exception('Failed to load data from the second API');
      }
    } catch (e) {
      logger.e("Error fetching second API data: $e");
    }
    isLoading.value = false;
  }

  Map<String, dynamic> _filterSecondApiData(Map<String, dynamic> data) {
    final Map<String, dynamic> filteredData = {};
    data.forEach((key, value) {
      if (value.isEmpty) {
        filteredData[key] = List<double>.filled(24, 0.0);
      } else {
        filteredData[key] = value.map<double>((v) => parseDouble(v)).toList();
      }
    });
    return filteredData;
  }

  Future<void> fetchDataForAreaChart() async {
    try {
      errorMessage.value = '';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      if (storedUsername == null) {
        throw Exception("Username not found in SharedPreferences");
      }

      final String appUrl = 'http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=${startDate.value}&end=${endDate.value}';
      final response = await http.get(Uri.parse(appUrl));

      if (response.statusCode == 200) {
        kwData.clear();
        dbHelper.clearKwData();  // Clear existing data before inserting new data
        Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['data'] == null) {
          throw Exception("No data found in the response");
        }

        _processAreaChartData(jsonData['data']);
      } else {
        throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } on SocketException {
      errorMessage.value = 'No Internet Connection';
      Get.snackbar("Error", errorMessage.value);
      await _loadDataFromLocalDb();
    } on FormatException {
      errorMessage.value = 'Data format error';
      Get.snackbar("Error", errorMessage.value);
      await _loadDataFromLocalDb();
    } catch (error) {
      errorMessage.value = 'An unexpected error occurred: $error';
      Get.snackbar("Error", errorMessage.value);
      await _loadDataFromLocalDb();
    }
  }

  void _processAreaChartData(Map<String, dynamic> data) {
    data.forEach((itemName, values) {
      if (itemName.endsWith("[kW]")) {
        String prefixName = itemName.substring(0, itemName.length - 4);
        List<double> numericValues = (values as List<dynamic>).map((value) {
          return parseDouble(value) / 1000.0;
        }).toList();

        kwData.add({'prefixName': prefixName, 'values': numericValues});
        dbHelper.insertKwData(prefixName, numericValues);
      }
    });
  }

  String getChartDataForAreaChart() {
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

  Future<void> _loadDataFromLocalDb() async {
    List<Map<String, dynamic>> localData = await dbHelper.getKwData();
    kwData.clear();
    for (var item in localData) {
      List<double> values = (item['dataValues'] as String).split(',').map((value) => double.tryParse(value) ?? 0.0).toList();
      kwData.add({'prefixName': item['prefixName'], 'values': values});
    }
  }

  Future<void> clearAllData() async {
    kwData.clear();
    await dbHelper.clearKwData();
  }

  void resetController() {
    firstApiData.value = <String, dynamic>{};
    secondApiData.value = <String, dynamic>{};
    result.value = <String>['0', '0', '0'];
    kwData.clear();
    clearAllData();
  }

  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double calculateTotalSum(List<double> sums) => sums.reduce((total, current) => total + current);

  double calculateMin(List<double> sums) => sums.reduce((min, current) => min < current ? min : current);

  double calculateMax(List<double> sums) => sums.reduce((max, current) => max > current ? max : current);

  double calculateAverage(List<double> sums) => sums.isEmpty ? 0.0 : sums.reduce((sum, current) => sum + current) / sums.length;

  String formatValue(double value) => value >= 1000 ? '${(value / 1000).toStringAsFixed(2)}kW' : '${(value / 1000).toStringAsFixed(2)}kW';

  String formatValued(double value) => (value / 1000).toStringAsFixed(2);

  double getLastIndexValue(List<double> values) {
    if (values.isNotEmpty) {
      return values.last;
    }
    return 0.0;
  }
}
