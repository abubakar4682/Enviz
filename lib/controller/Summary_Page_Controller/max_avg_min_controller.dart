import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/current_value_helper_db.dart';

class MinMaxAvgValueController extends GetxController {
  final RxList<Map<String, dynamic>> kwData = <Map<String, dynamic>>[].obs;
  final RxBool loading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> firstApiData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> secondApiData = <String, dynamic>{}.obs;
  final RxList<String> result = <String>['0', '0', '0'].obs;
  final int pakistaniTimeZoneOffset = 5;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await _loadDataFromLocalDb();
      errorMessage.value = "No internet connection available.";
    } else {
      await _fetchApiData();
    }
  }

  Future<void> _fetchApiData() async {
    try {
      await _clearOldData();
      await _fetchFirstApiData();
      await _fetchSecondApiData();
    } catch (e) {
      _handleApiError('Error fetching data: $e');
    }
  }

  Future<void> _fetchFirstApiData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/buildingmap?username=$storedUsername'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        firstApiData.value = responseData;
        await _dbHelper.insertFirstApiData(json.encode(responseData));
        print('First API data fetched and stored locally.');
      } else {
        _handleApiError('Failed to load data from the first API');
      }
    } catch (e) {
      _handleApiError('Error fetching first API data: $e');
    }
  }

  Future<void> _fetchSecondApiData() async {
    try {
      DateTime currentDate = DateTime.now().toUtc().add(Duration(hours: pakistaniTimeZoneOffset));
      String formattedDate = currentDate.toLocal().toString().split(' ')[0];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUsername = prefs.getString('username');
      final String apiUrl = "http://203.135.63.47:8000/data?username=$storedUsername&mode=hour&start=$formattedDate&end=$formattedDate";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _processSecondApiResponse(responseData);
      } else {
        _handleApiError('Failed to load data from the second API');
      }
    } catch (e) {
      _handleApiError('Error fetching second API data: $e');
    }
  }

  Future<void> _processSecondApiResponse(Map<String, dynamic> data) async {
    if (data.containsKey('data') && data['data'] is Map) {
      final Map<String, dynamic> filteredData = _filterSecondApiData(data['data']);
      secondApiData.value = filteredData;
      await _dbHelper.insertSecondApiData(json.encode(filteredData));
      print('Second API data fetched and stored locally.');
    } else {
      _handleApiError('Unexpected data structure from the second API');
    }
  }

  Map<String, dynamic> _filterSecondApiData(Map<String, dynamic> data) {
    final Map<String, dynamic> filteredData = {};
    int currentHour = DateTime.now().hour;

    data.forEach((key, value) {
      if (value is List) {
        List<dynamic> hourValues = value;
        List<double> parsedValues = hourValues.take(currentHour + 1)
            .map((v) => double.tryParse(v.toString()) ?? 0.0).toList();
        filteredData[key] = parsedValues;
      }
    });
    return filteredData;
  }

  Future<void> _loadDataFromLocalDb() async {
    try {
      String? storedFirstApiData = await _dbHelper.getFirstApiData();
      String? storedSecondApiData = await _dbHelper.getSecondApiData();

      if (storedFirstApiData != null) {
        firstApiData.value = json.decode(storedFirstApiData);
        print('First API data loaded from local DB.');
      } else {
        errorMessage.value = "No first API data available locally.";
        print('No first API data available locally.');
      }

      if (storedSecondApiData != null) {
        secondApiData.value = json.decode(storedSecondApiData);
        print('Second API data loaded from local DB.');
      } else {
        errorMessage.value = "No second API data available locally.";
        print('No second API data available locally.');
      }
    } catch (e) {
      _handleApiError('Failed to load data from local DB: $e');
    }
  }

  Future<void> _clearOldData() async {
    await _dbHelper.clearFirstApiData();
    await _dbHelper.clearSecondApiData();
    print('Old data cleared.');
  }

  Future<void> clearAllStoredData() async {
    await _clearOldData();
    await _dbHelper.clearDatabase();
    print('All stored data cleared.');
  }

  void _handleApiError(String message) {
    errorMessage.value = message;
    print(message);
  }

  double parseDouble(dynamic value) {
    if (value == null || value == "NA") {
      return 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  String formatValue(double value) => (value / 1000).toStringAsFixed(2);

  double getCurrentHourValue(List<double> values) {
    int currentHour = DateTime.now().hour;
    return (values.isNotEmpty && currentHour < values.length) ? values[currentHour] : 0.0;
  }

  void processData(Map<String, dynamic> jsonData) {
    if (jsonData.containsKey("Main_[kW]")) {
      _showMainKwValues(jsonData["Main_[kW]"]);
    } else {
      _showOtherKwValues(jsonData);
    }
  }

  void _showMainKwValues(List<dynamic> mainKwValues) {
    List<double> numericValues = mainKwValues
        .where((value) => value is num || (value is String && double.tryParse(value) != null))
        .map((value) => value is num ? value.toDouble() : double.parse(value))
        .toList();

    if (numericValues.isNotEmpty) {
      double minValue = numericValues.reduce((value, element) => value < element ? value : element);
      double maxValue = numericValues.reduce((value, element) => value > element ? value : element);
      double averageValue = numericValues.reduce((a, b) => a + b) / numericValues.length;
      double totalValue = numericValues.reduce((a, b) => a + b);
      result.assignAll([
        '$minValue',
        '$maxValue',
        '$averageValue',
        'Total MainKW: $totalValue',
      ]);
    } else {
      _assignNoDataFound();
    }
  }

  void _showOtherKwValues(Map<String, dynamic> jsonData) {
    Map<String, double> sumValuesMap = {};

    jsonData.forEach((key, value) {
      if (key.endsWith("[kW]") && value is List) {
        double sum = 0;
        for (var item in value) {
          if (item is num) {
            sum += item.toDouble();
          }
        }
        sumValuesMap[key] = sum;
      }
    });

    if (sumValuesMap.isNotEmpty) {
      result.assignAll(sumValuesMap.entries
          .map((entry) => '${entry.key}: Sum = ${entry.value}')
          .toList());
    } else {
      _assignNoDataFound();
    }
  }

  void _assignNoDataFound() {
    result.assignAll([
      'No matching keys found.',
      'No matching keys found.',
      'No matching keys found.'
    ]);
  }

  String formatToKW(double value) {
    return (value / 1000.0).toStringAsFixed(3) + ' k';
  }

  String getMainPart(String fullName) {
    List<String> parts = fullName.split('_');
    return parts.isNotEmpty ? parts.first : fullName;
  }
}
