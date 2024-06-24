import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../database/coloum_chart_helper.dart';


class WeekDataControllerss extends GetxController {
  var isLoading = true.obs;
  var chartData = ''.obs;
  var errorMessage = ''.obs;
  var hasError = false.obs;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 1));

  final DatabaseHelperForWeek _dbHelper = DatabaseHelperForWeek();

  @override
  void onInit() {
    super.onInit();
    fetchChartData();
  }

  void resetController() {
    isLoading(true);
    chartData('');
    errorMessage('');
    startDate = DateTime.now().subtract(Duration(days: 1));
  }

  void fetchChartData() async {
    errorMessage.value = '';
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _loadDataFromLocalDb();
      Get.snackbar(
        "Offline Mode",
        "Kindly connect your mobile to the internet.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      _fetchDataFromApi();
     // Get.snackbar('', 'Getting data from the internet');
    }
  }

  void _loadDataFromLocalDb() async {
    isLoading(true);
    try {
      String? storedData = await _dbHelper.getChartData();
      if (storedData != null) {
        chartData(storedData);
      } else {
        errorMessage.value = "No data available locally.";
        debugPrint("No data available locally.");
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data from local DB: $e';
      debugPrint('Failed to load data from local DB: $e');
    } finally {
      isLoading(false);
    }
  }

  void _fetchDataFromApi() async {
    isLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      errorMessage.value = "No username found in preferences.";
      debugPrint("No username found in preferences.");
      isLoading(false);
      return;
    }

    DateTime endDate = DateTime.now().toUtc().add(Duration(hours: 5));
    DateTime startDate = DateTime.now().subtract(Duration(days: 7));
    String formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.get(Uri.parse('http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String chartDataString = parseChartData(jsonResponse);
        chartData(chartDataString);

        await _dbHelper.clearChartData();
        await _dbHelper.insertChartData(chartDataString);
      } else {
        errorMessage.value = 'Failed to load data with status code: ${response.statusCode}';
        hasError(true);
        debugPrint('Failed to load data with status code: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data from API: $e';
      hasError(true);
      debugPrint('Failed to load data from API: $e');
    } finally {
      isLoading(false);
    }
  }

  String parseChartData(Map<String, dynamic> jsonResponse) {
    List<String> categories = List<String>.from(jsonResponse['data']['Date & Time']);
    List<dynamic> series = [];
    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        List convertedData = (value as List).map((item) => item is int ? item.toDouble() : item / 1000).toList();
        series.add({'name': key.replaceAll('_[kW]', ''), 'data': convertedData, "visible": !(key.startsWith('Main') || key.startsWith('Generator'))});
      }
    });

    return json.encode({'categories': categories, 'series': series});
  }
}