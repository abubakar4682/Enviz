import 'package:get/get.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../database/pie_chart_for_month.dart';

class MonthDataControllerForPieChart extends GetxController {
  var pieChartData = ''.obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChartData();
  }

  void clearUserData() {
    pieChartData.value = '';
    errorMessage.value = '';
    hasError(false);
    isLoading(false);
  }

  void fetchChartData() async {
    errorMessage.value = '';
    hasError(false);
    isLoading(true);

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      await _loadOfflineData();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');
    if (storedUsername == null) {
      errorMessage.value = "No username found in preferences.";
      isLoading(false);
      return;
    }

    DateTime now = DateTime.now();
    DateTime endDate = DateTime(now.year, now.month,
        now.day); // Ensures the time is set to 00:00:00 of today
    // Set startDate to the first day of the current month
    DateTime startDate = DateTime(now.year, now.month, 1);

    // Format the dates to 'YYYY-MM-DD' format
    String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.get(Uri.parse(
          'http://203.135.63.47:8000/data?username=$storedUsername&mode=day&start=$formattedStartDate&end=$formattedEndDate'));
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        String parsedData = jsonEncode(parsePieChartData(jsonResponse));
        pieChartData.value = parsedData;
        await DatabaseServiceForPieForMonth()
            .insertPieChartData(parsedData); // Save to SQLite
      } else {
        errorMessage.value =
            'Failed to load data with status code: ${response.statusCode}';
        hasError(true);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load data with error: $e';
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  List<Map<String, dynamic>> parsePieChartData(
      Map<String, dynamic> jsonResponse) {
    List<Map<String, dynamic>> data = [];
    double total = 0;

    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum =
            (value as List).fold(0, (prev, item) => prev + (item / 1000));
        total += sum;
      }
    });

    jsonResponse['data'].forEach((key, value) {
      if (key.endsWith('_[kW]')) {
        double sum =
            (value as List).fold(0, (prev, item) => prev + (item / 1000));
        double percentage = (sum / total) * 100;
        data.add({
          'name': key.replaceAll('_[kW]', ''),
          'y': sum,
          'percentage': percentage
        });
      }
    });

    return data;
  }

  Future<void> _loadOfflineData() async {
    String? storedData =
        await DatabaseServiceForPieForMonth().getPieChartData();
    if (storedData != null) {
      pieChartData.value = storedData;
    } else {
      errorMessage.value = "No offline data available.";
      hasError(true);
    }
    isLoading(false);
  }
}
